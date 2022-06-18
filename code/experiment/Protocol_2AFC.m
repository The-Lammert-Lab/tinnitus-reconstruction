%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Reverse Correlation Protocol for 
%        Cognitive Representations of Speech
%
% Author: Adam C. Lammert
% Begun: 29.JAN.2021
% 
% 
%   Protocol()
%   Protocol('config', 'path2config')

function Protocol_2AFC(options)

    arguments
        options.config char = []
    end

    this_datetime = datetime();

    % Is a config file provided?
    %   If so, read it.
    %   If not, open a GUI dialog window to find it.
    config = parse_config(options.config);
    config.n_trials = config.n_trials_per_block;

    % Try to create the data directory if it doesn't exist
    mkdir(config.data_dir);

    %% Setup

    % Useful variables
    project_dir = pathlib.strip(mfilename('fullpath'), 2);
    
    % Determine the stimulus generation function
    if isfield(config, 'stimuli_type') && ~isempty(config.stimuli_type)
        % There is a weird feature/bug where putting `stimuli_type: white`
        % in the config file returns a 256x3 matrix of ones.
        if all(config.stimuli_type(:) == 1)
            config.stimuli_type = 'UniformNoiseNoBins';
        end
    else
        % Default to 'custom' stimulus generation
        config.stimuli_type = 'GaussianPrior';
    end

    % Instantiate the stimulus generation object
    stimuli_object = eval([config.stimuli_type, 'StimulusGeneration()']);
    stimuli_object = stimuli_object.from_config(config);
    
    % Compute the total trials done
    total_trials_done = 0;
    d = dir(pathlib.join(config.data_dir, [config.subjectID '_responses*.csv']));

    for ii = 1:length(d)
        responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
        total_trials_done = total_trials_done + length(responses);
    end
    fprintf(['# of trials completed: ', num2str(total_trials_done) '\n'])

    % Create files needed for saving the data
    uuid = char(java.util.UUID.randomUUID);
    filename_responses = pathlib.join(config.data_dir, [config.subjectID, '_', 'responses', '_', uuid, '.csv']);
    filename_stimuli = pathlib.join(config.data_dir, [config.subjectID, '_', 'stimuli', '_', uuid, '.csv']);
    filename_meta = pathlib.join(config.data_dir, [config.subjectID, '_', 'meta', '_', uuid, '.csv']);

    fid_responses = fopen(filename_responses, 'w');

    % Is this an A-X experiment protocol?
    %   If it's an A-X experiment protocol,
    %   then we should play a target sound before each stimulus
    %   for each trial.
    %   Whether we are doing an A-X protocol or an X protocol
    %   is determined by the config file.
    if isfield(config, 'target_audio_filepath') && ~isempty(config.target_audio_filepath)
        % Load the sound file.
        [target_sound, target_fs] = audioread(config.target_audio_filepath);
    else
        target_sound = [];
    end

    target_sound = target_sound(1:floor(target_fs*0.5)); %ACL added (5MAY2022) to shorten target sound to 500ms

    %% Load Presentations Screens

    Screen1 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide1B.png'));
    Screen2 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide2B.png'));
    Screen3 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide3B.png'));
    Screen4 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide4.png'));

    %% Generate stimuli

    % Generate a block of stimuli
    % [stimuli_matrix, Fs, nfft] = stimuli_object.custom_generate_stimuli_matrix();
    [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = stimuli_object.generate_stimuli_matrix();

    % Write the stimuli to file
    switch config.stimuli_save_type
    case 'waveform'
        writematrix(stimuli_matrix, filename_stimuli);
    case 'spectrum'
        writematrix(spect_matrix, filename_stimuli);
    case 'bins'
        writematrix(binned_repr_matrix, filename_stimuli);
    otherwise
        error(['Stimuli save type: ', config.stimuli_save_type, ' not recognized.'])
    end

    %% Intro Screen & Start

    imshow(Screen1);
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter')); % f - 102
    while (value ~= 102)
        k = waitforbuttonpress;
        value = double(get(gcf,'CurrentCharacter'));
    end

    %% Run Trials

    counter = 0;
    while (1)
        counter = counter + 2;

        % Reminder Screen
        imshow(Screen2);

        % Present Target (if A-X protocol)
        if ~isempty(target_sound)
            soundsc(target_sound, target_fs)
            pause(length(target_sound) / target_fs + 0.3) % ACL added (5MAY2022) to add 300ms pause between target and stimulus
        end


        % Present First Stimulus
        soundsc(stimuli_matrix(:, counter), Fs)
        pause(length(stimuli_matrix(:, counter)) / Fs)
       
      
        pause(0.25)
        % Present Target Again (if A-X protocol)
        if ~isempty(target_sound)
            soundsc(target_sound, target_fs)
            pause(length(target_sound) / target_fs + 0.3) % ACL added (5MAY2022) to add 300ms pause between target and stimulus
        end

        % Present Second Stimulus
        soundsc(stimuli_matrix(:, counter+1), Fs)
        pause(length(stimuli_matrix(:, counter+1)) / Fs)
        
        % Obtain Response
        k = waitforbuttonpress;
        value = double(get(gcf,'CurrentCharacter')); % f - 102, j - 106
        while isempty(value) || (value ~= 102) && (value ~= 106)
            k = waitforbuttonpress;
            value = double(get(gcf,'CurrentCharacter'));
        end
        
        % Save Response to File (1 for first stim, 2 for second)
        respnum = 0;
        switch value
            case 106
                respnum = 1;
            case 102
                respnum = 2;
        end

        % Write the response to file
        fprintf(fid_responses, [num2str(respnum) '\n']);

        % Update the number of trials done in this block
        total_trials_done = total_trials_done + 2;

        % Write the meta file
        meta = {config.subjectID, uuid, this_datetime, total_trials_done};
        meta_labels = {'subjectID', 'uuid', 'datetime', 'total_trials_done'};
        writetable(cell2table(meta, 'VariableNames', meta_labels), filename_meta);
            
        % Decide How To Continue
        if total_trials_done >= config.n_trials_per_block * config.n_blocks
            fclose(fid_responses);
            % end, all trials complete
            imshow(Screen4)
            return
        elseif mod(total_trials_done, config.n_trials_per_block) == 0 % give rest before proceeding to next block
            fclose(fid_responses);

            % reset counter
            counter = 0;
            imshow(Screen3)
            k = waitforbuttonpress;
            value = double(get(gcf,'CurrentCharacter')); % f - 102
            while (value ~= 102)
                k = waitforbuttonpress;
                value = double(get(gcf,'CurrentCharacter'));
            end

            % Generate new UUID
            uuid = char(java.util.UUID.randomUUID);

            % Generate new files
            filename_responses = pathlib.join(config.data_dir, [config.subjectID, '_', 'responses', '_', uuid, '.csv']);
            filename_stimuli = pathlib.join(config.data_dir, [config.subjectID, '_', 'stimuli', '_', uuid, '.csv']);
            filename_meta = pathlib.join(config.data_dir, [config.subjectID, '_', 'meta', '_', uuid, '.csv']);

            fid_responses = fopen(filename_responses, 'w');

            % Generate stimuli for next block
            [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = stimuli_object.generate_stimuli_matrix();

            % Save stimuli to file
            switch config.stimuli_save_type
            case 'waveform'
                writematrix(stimuli_matrix, filename_stimuli);
            case 'spectrum'
                writematrix(spect_matrix, filename_stimuli);
            case 'bins'
                writematrix(binned_repr_matrix, filename_stimuli);
            otherwise
                error(['Stimuli save type: ', config.stimuli_save_type, ' not recognized.'])
            end
            fprintf(['# of trials completed: ', num2str(total_trials_done) '\n'])

        else % continue with block
            % pause(1)
        end
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %eof
end