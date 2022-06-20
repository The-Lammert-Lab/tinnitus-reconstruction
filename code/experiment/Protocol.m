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

function Protocol(options)

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
    
    % Generate the experiment ID
    expID = get_experiment_ID(config);
    
    % Instantiate the stimulus generation object
    stimuli_object = eval([config.stimuli_type, 'StimulusGeneration()']);
    stimuli_object = stimuli_object.from_config(config);
    
    % Compute the total trials done
    total_trials_done = 0;
    d = dir(pathlib.join(config.data_dir, [expID '_responses*.csv']));

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
    
    %% Generate initial files and stimuli
    [stimuli_matrix, Fs, filename_responses, ~, filename_meta, this_hash] = create_files_and_stimuli(config, stimuli_object, hash_prefix);
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

        % Present Target (if A-X protocol)
        if ~isempty(target_sound)
            soundsc(target_sound, target_fs)
            pause(length(target_sound) / target_fs + 0.3) % ACL added (5MAY2022) to add 300ms pause between target and stimulus
        end


        % Present Stimulus
        soundsc(stimuli_matrix(:, counter), Fs)
        pause(length(stimuli_matrix(:, counter)) / Fs)
            
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

        % Write the meta file
        meta = {expID, this_hash, this_datetime, total_trials_done};
        meta_labels = {'expID', 'hash', 'datetime', 'total_trials_done'};
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

            % Generate new stimuli and files
            [stimuli_matrix, Fs, filename_responses, ~, filename_meta, this_hash] = create_files_and_stimuli(config, stimuli_object, hash_prefix);
            fid_responses = fopen(filename_responses, 'w');

        else % continue with block
            % pause(1)
        end
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %eof
end