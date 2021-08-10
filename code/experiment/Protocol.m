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

    today = datestr(date,'yyyymmdd'); % today's date (for filenames)
    thetime = datestr(now,'HHMMSS'); % today's date (for filenames)

    % open a UI to get the config file for this set of trials
    % parse the config file to get options
    if isempty(options.config)
        [file, abs_path] = uigetfile();
        config = ReadYaml(pathlib.join(abs_path, file));
    else
        config = ReadYaml(options.config);
    end

    %% Stimulus Configuration

    % nbins_time = config.total_duration/config.bin_duration;

    % Create Meta File, checking for most recent files under this subjectID
    iter = 1;
    filename = [config.datadir '/' config.subjectID '_' num2str(iter) '_meta.csv'];
    fid = fopen(filename,'r');
    while fid>0
        fclose(fid);
        iter = iter + 1;
        filename = [config.datadir '/' config.subjectID '_' num2str(iter) '_meta.csv'];
        fid = fopen(filename,'r');
    end
    fid = fopen(filename,'w+');

    % Determine # Completed Trials, read prior meta data, if existing
    if iter < 2
        tottrials = 0;
    else
        filename_prev = [config.datadir '/' config.subjectID '_' num2str(iter-1) '_meta.csv'];
        fid_prev = fopen(filename_prev,'r');
        tline = fgetl(fid_prev);
        out1 = regexp(tline,',(\d)+$','tokens');
        out1 = out1{:};
        tottrials = str2num(out1{1});
        fclose(fid_prev);
    end

    %% Record Meta Data
    fprintf(fid,[config.subjectID ',' num2str(today) ',' num2str(thetime) ',' num2str(tottrials) '\n']);
    fclose(fid);

    %% Load Presentations Screens
    Screen1 = imread('fixationscreen/Slide1B.png');
    Screen2 = imread('fixationscreen/Slide2B.png');
    Screen3 = imread('fixationscreen/Slide3B.png');
    Screen4 = imread('fixationscreen/Slide4.png');

    %% Create Data Files
    filename_stim = [config.datadir '/' config.subjectID '_' num2str(iter) '_stim.csv'];
    fid_stim = fopen(filename_stim,'w+');
    filename_resp = [config.datadir '/' config.subjectID '_' num2str(iter) '_resp.csv'];
    fid_resp = fopen(filename_resp,'w+');

    %% Generate stimuli

    [stimuli_matrix, Fs, nfft] = generate_stimuli_matrix(...
        'min_freq', config.min_freq, ...
        'max_freq', config.max_freq, ...
        'n_bins', config.n_bins, ...
        'bin_duration', config.bin_duration, ...
        'prob_f', config.prob_f, ...
        'n_trials', config.n_trials);

    % TODO: fix stimuli saving
    % % save stimuli to file
    % for ii = 1:size(stimuli_matrix, 2)
    %     for stor = 1:nfft
    %         fprintf(fid_stim, [num2str(stimuli_matrix(stor, ii)) ',']);
    %     end
    %     fprintf(fid_stim,'\n');
    % end

    %% Intro Screen & Start
    imshow(Screen1);
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter')); % f - 102
    while (value ~= 102)
        k = waitforbuttonpress;
        value = double(get(gcf,'CurrentCharacter'));
    end

    %% Run Trials
    counter = 0
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
        fprintf(fid_resp,[num2str(respnum) '\n']);
        
        % Increment Trial Counter, here and in metadata file
        tottrials = tottrials + 1;
        filename = [config.datadir '/' config.subjectID '_' num2str(iter) '_meta.csv'];
        fid = fopen(filename,'w+');
        fprintf(fid,[config.subjectID ',' num2str(today) ',' num2str(thetime) ',' num2str(tottrials) '\n']);
        fclose(fid);
            
        % Decide How To Continue
        if tottrials >= config.n_trials*config.n_blocks % end, all trials complete
            imshow(Screen4)
            return
        elseif mod(tottrials,config.n_trials) == 0 % give rest before proceeding to next block
            % reset counter
            counter = 0;
            imshow(Screen3)
            k = waitforbuttonpress;
            value = double(get(gcf,'CurrentCharacter')); % f - 102
            while (value ~= 102)
                k = waitforbuttonpress;
                value = double(get(gcf,'CurrentCharacter'));
            end

            % generate stimuli for next block
            [stimuli_matrix, Fs, nfft] = generate_stimuli_matrix(...
                'min_freq', config.min_freq, ...
                'max_freq', config.max_freq, ...
                'n_bins', config.n_bins, ...
                'bin_duration', config.bin_duration, ...
                'prob_f', config.prob_f, ...
                'n_trials', config.n_trials);

            % % save stimuli to file
            % for ii = 1:size(stimuli_matrix, 2)
            %     for stor = 1:nfft
            %         fprintf(fid_stim, [num2str(stimuli_matrix(stor, ii)) ',']);
            %     end
            %     fprintf(fid_stim,'\n');
            % end
        else % continue with block
            % pause(1)
        end
        
    end

    %% Close Files
    fclose(fid);
    fclose(fid_stim);
    fclose(fid_resp);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %eof
end