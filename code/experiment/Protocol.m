%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title: Reverse Correlation Protocol for 
%        Cognitive Representations of Speech
%
% Author: Adam C. Lammert
% Begun: 29.JAN.2021

% % Setup
% subjectID = 'M1'; % subject identifier
% datadir = './Data'; % directory to locate responses
% today = datestr(date,'yyyymmdd'); % today's date (for filenames)
% thetime = datestr(now,'HHMMSS'); % today's date (for filenames)
% numtrials = 80; % number of trials
% numblocks = 20; % number of blocks

function Protocol(options)

    arguments
        options.config char = []
    end

    this_datetime = datetime();

    % open a UI to get the config file for this set of trials
    % parse the config file to get options
    if isempty(options.config)
        [file, abs_path] = uigetfile();
        config = ReadYaml(pathlib.join(abs_path, file));
    else
        config = ReadYaml(options.config);
    end

    %% Setup
    
    % Compute the total trials done
    total_trials_done = 0;
    d = dir(pathlib.join(config.datadir, [config.subjectID '_responses*.csv']));

    for ii = 1:length(d)
        responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
        total_trials_done = total_trials_done + length(responses);
    end
    fprintf(['# of trials completed: ', num2str(total_trials_done) '\n'])

    % Create files needed for saving the data
    uuid = char(java.util.UUID.randomUUID);
    filename_responses = pathlib.join(config.datadir, [config.subjectID, '_', 'responses', '_', uuid, '.csv']);
    filename_stimuli = pathlib.join(config.datadir, [config.subjectID, '_', 'stimuli', '_', uuid, '.csv']);
    filename_meta = pathlib.join(config.datadir, [config.subjectID, '_', 'meta', '_', uuid, '.csv']);

    fid_responses = fopen(filename_responses, 'w');


    %% Load Presentations Screens

    Screen1 = imread('fixationscreen/Slide1B.png');
    Screen2 = imread('fixationscreen/Slide2B.png');
    Screen3 = imread('fixationscreen/Slide3B.png');
    Screen4 = imread('fixationscreen/Slide4.png');

    %% Generate stimuli

    % Generate a block of stimuli
    [stimuli_matrix, Fs, nfft] = generate_stimuli_matrix(...
        'min_freq', config.min_freq, ...
        'max_freq', config.max_freq, ...
        'n_bins', config.n_bins, ...
        'n_trials', config.n_trials_per_block, ...
        'bin_duration', config.bin_duration, ...
        'n_bins_filled_mean', config.n_bins_filled_mean, ...
        'n_bins_filled_var', config.n_bins_filled_var);

    % Write the stimuli to file
    writematrix(stimuli_matrix, filename_stimuli);

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

        % Reminder Screen
        imshow(Screen2);

        % Present Stimulus
        counter = counter + 1;
        soundsc(stimuli_matrix(:, counter), Fs)
            
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
            filename_responses = pathlib.join(config.datadir, [config.subjectID, '_', 'responses', '_', uuid, '.csv']);
            filename_stimuli = pathlib.join(config.datadir, [config.subjectID, '_', 'stimuli', '_', uuid, '.csv']);
            filename_meta = pathlib.join(config.datadir, [config.subjectID, '_', 'meta', '_', uuid, '.csv']);

            fid_responses = fopen(filename_responses, 'w');

            % Generate stimuli for next block
            [stimuli_matrix, Fs, nfft] = generate_stimuli_matrix(...
                'min_freq', config.min_freq, ...
                'max_freq', config.max_freq, ...
                'n_bins', config.n_bins, ...
                'n_trials', config.n_trials_per_block, ...
                'bin_duration', config.bin_duration, ...
                'n_bins_filled_mean', config.n_bins_filled_mean, ...
                'n_bins_filled_var', config.n_bins_filled_var);

            % Save stimuli to file
            writematrix(stimuli_matrix, filename_stimuli)
            fprintf(['# of trials completed: ', num2str(total_trials_done) '\n'])

        else % continue with block
            % pause(1)
        end
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %eof
end