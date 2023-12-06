%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% Reverse Correlation Protocol for Cognitive Representations of Speech
%
% This function runs the "Two Alternative Forced Choice" experimental procedure of this project.
% 
% It can be called in two ways:
% ```matlab
% Protocol_2AFC() or Protocol_2AFC('config', 'path2config')
% ```
% Where `'path2config'` is the file path to the desired config file.
% 
% If `Protocol_2AFC()` is invoked, a GUI is automatically opened for the user to select the proper config file.
% 
% End of documentation
% Author: Adam C. Lammert
% Begun: 29.JAN.2021

function RevCorr_2AFC(options)

    arguments
        options.config_file char = []
    end

    % Get the datetime and posix time
    % for the start of the experiment
    this_datetime = datetime('now', 'Timezone', 'local');
    posix_time = num2str(floor(posixtime(this_datetime)));

    % Is a config file provided?
    %   If so, read it.
    %   If not, open a GUI dialog window to find it.
    config = parse_config(options.config_file);

    % Hash the config struct to get a unique string representation
    % Get the hash before modifying the config at all
    config_hash = get_hash(config);

    % Get the hash prefix for file naming
    hash_prefix = [config_hash, '_', posix_time];

    % Add additional config fields here
    config.n_trials = config.n_trials_per_block;

    % Try to create the data directory if it doesn't exist
    mkdir(config.data_dir);

    %% Setup
    
    % Useful variables
    project_dir = pathlib.strip(mfilename('fullpath'), 3);
    
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
    
    % Generate the experiment ID
    expID = get_experiment_ID(config);
    
    % Instantiate the stimulus generation object
    stimuli_object = eval([config.stimuli_type, 'StimulusGeneration()']);
    stimuli_object = stimuli_object.from_config(config);
    
    % Compute the total trials done
    total_trials_done = 0;
    d = dir(pathlib.join(config.data_dir, ['responses_', config_hash, '*.csv']));

    for ii = 1:length(d)
        responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
        total_trials_done = total_trials_done + length(responses);
    end
    fprintf(['# of trials completed: ', num2str(total_trials_done) '\n'])

    % Is this an A-X experiment protocol?
    %   If it's an A-X experiment protocol,
    %   then we should play a target sound before each stimulus
    %   for each trial.
    %   Whether we are doing an A-X protocol or an X protocol
    %   is determined by the config file.
    if isfield(config, 'target_signal_filepath') && ~isempty(config.target_signal_filepath)
        % Load the sound file.
        [target_sound, target_fs] = audioread(config.target_signal_filepath);
    else
        target_sound = [];
    end

    target_sound = target_sound(1:floor(target_fs*0.5)); %ACL added (5MAY2022) to shorten target sound to 500ms

    %% Load Presentations Screens

    Screen1 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide1B.png'));
    Screen2 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide2B.png'));
    Screen3 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide3B.png'));
    Screen4 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide4.png'));
    
    %% Generate initial files and stimuli
    [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, ~, ~, filename_meta_1, filename_meta_2, this_hash_1, this_hash_2] = create_files_and_stimuli_2AFC(config, stimuli_object, hash_prefix);
    fid_responses = fopen(filename_responses, 'w');

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
        counter = counter + 1;

        % Reminder Screen
        imshow(Screen2);

        %% Play the stimuli
        play_stimuli(stimuli_matrix_1, stimuli_matrix_2, Fs, counter, target_sound, target_fs, 0.3)
            
        % Obtain Response
        k = waitforbuttonpress;
        value = double(get(gcf,'CurrentCharacter')); % f - 102, j - 106
        while isempty(value) || (value ~= 102) && (value ~= 106)
            k = waitforbuttonpress;
            value = double(get(gcf,'CurrentCharacter'));
        end
        
        % Save Response to File
        respnum = 0;
        switch value
            case 106
                respnum = 1;
            case 102
                respnum = -1;
        end

        % Write the response to file
        fprintf(fid_responses, [num2str(respnum) '\n']);

        % Update the number of trials done in this block
        total_trials_done = total_trials_done + 1;

        % Write the meta files
        meta = {expID, this_hash_1, this_datetime, total_trials_done};
        meta_labels = {'expID', 'hash', 'datetime', 'total_trials_done'};
        writetable(cell2table(meta, 'VariableNames', meta_labels), filename_meta_1);

        meta = {expID, this_hash_2, this_datetime, total_trials_done};
        meta_labels = {'expID', 'hash', 'datetime', 'total_trials_done'};
        writetable(cell2table(meta, 'VariableNames', meta_labels), filename_meta_2);
            
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

            % Generate new stimuli and files
            [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, ~, ~, filename_meta_1, filename_meta_2, this_hash_1, this_hash_2] = create_files_and_stimuli_2AFC(config, stimuli_object, hash_prefix);
            fid_responses = fopen(filename_responses, 'w');

        else % continue with block
            % pause(1)
        end
        
    end

end % Protocol_2AFC


function [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, filename_stimuli_1, filename_stimuli_2, filename_meta_1, filename_meta_2, file_hash_1, file_hash_2] = create_files_and_stimuli_2AFC(config, stimuli_object, hash_prefix)
    % Create files for the stimuli, responses, and metadata
    % and create the stimuli.
    % Write the stimuli into the stimuli file.

    arguments
        config (1,1) struct
        stimuli_object (1,1) AbstractStimulusGenerationMethod
        hash_prefix (1,:) char
    end

    % Generate the stimuli
    [stimuli_matrix_1, ~, spect_matrix_1, binned_repr_matrix_1] = stimuli_object.generate_stimuli_matrix();
    [stimuli_matrix_2, Fs, spect_matrix_2, binned_repr_matrix_2] = stimuli_object.generate_stimuli_matrix();
    
    % Hash the stimuli
    stimuli_hash_1 = DataHash(spect_matrix_1);
    stimuli_hash_1 = stimuli_hash_1(1:8);
    
    stimuli_hash_2 = DataHash(spect_matrix_2);
    stimuli_hash_2 = stimuli_hash_2(1:8);

    % Create the files needed for saving the data
    file_hash_1 = [hash_prefix, '_', stimuli_hash_1];
    file_hash_2 = [hash_prefix, '_', stimuli_hash_2];

    filename_responses    = pathlib.join(config.data_dir, ['responses_', file_hash_1, '.csv']);
    filename_stimuli_1    = pathlib.join(config.data_dir, ['stimuli_1_', file_hash_1, '.csv']);
    filename_stimuli_2    = pathlib.join(config.data_dir, ['stimuli_2_', file_hash_2, '.csv']);
    filename_meta_1       = pathlib.join(config.data_dir, ['meta_1_', file_hash_1, '.csv']);
    filename_meta_2       = pathlib.join(config.data_dir, ['meta_2_', file_hash_2, '.csv']);

    % Write the stimuli to file
    switch config.stimuli_save_type
    case 'waveform'
        writematrix(stimuli_matrix_1, filename_stimuli_1);
        writematrix(stimuli_matrix_2, filename_stimuli_2);
    case 'spectrum'
        writematrix(spect_matrix_1, filename_stimuli_1);
        writematrix(spect_matrix_2, filename_stimuli_2);
    case 'bins'
        writematrix(binned_repr_matrix_1, filename_stimuli_1);
        writematrix(binned_repr_matrix_2, filename_stimuli_2);
    otherwise
        error(['Stimuli save type: ', config.stimuli_save_type, ' not recognized.'])
    end

end % create_files_and_stimuli