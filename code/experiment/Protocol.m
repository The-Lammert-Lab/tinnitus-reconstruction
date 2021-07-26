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

function Protocol(varargin)

    options = struct;
    options.config = [];

    if ~isempty(varargin)
        options = corelib.parseNameValueArguments(options, varargin);
    end

    today = datestr(date,'yyyymmdd'); % today's date (for filenames)
    thetime = datestr(now,'HHMMSS'); % today's date (for filenames)

    % open a UI to get the config file for this set of trials
    % parse the config file to get options
    if isempty(options.config)
        [file, abs_path] = uigetfile();
        config = ReadYaml(pathlib.join(abs_path, file));
    else
        config.subjectID = 'M1';
        config.datadir = './Data';
        config.n_trials = 80;
        config.n_blocks = 20;
        config.minfreq = 100; % minimum frequency for synthesis
        config.maxfreq = 22000; % maximum frequency for synthesis
        config.nbins_freq = 100; % number of frequency bins
        config.bindur = 0.5; % duration of the time bins in seconds
        config.totaldur = 0.30; % total dur of signal in seconds
        config.probfact = 0.40; % "percent" t-f bins filled
    end

    % Stimulus Configuration

    nbins_time = config.totaldur/config.bindur;

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

    % Record Meta Data
    fprintf(fid,[config.subjectID ',' num2str(today) ',' num2str(thetime) ',' num2str(tottrials) '\n']);
    fclose(fid);

    % Load Presentations Screens
    Screen1 = imread('fixationscreen/Slide1B.png');
    Screen2 = imread('fixationscreen/Slide2B.png');
    Screen3 = imread('fixationscreen/Slide3B.png');
    Screen4 = imread('fixationscreen/Slide4.png');

    % Create Data Files
    filename_stim = [config.datadir '/' config.subjectID '_' num2str(iter) '_stim.csv'];
    fid_stim = fopen(filename_stim,'w+');
    filename_resp = [config.datadir '/' config.subjectID '_' num2str(iter) '_resp.csv'];
    fid_resp = fopen(filename_resp,'w+');

    % Intro Screen & Start
    imshow(Screen1);
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter')); % f - 102
    while (value ~= 102)
        k = waitforbuttonpress;
        value = double(get(gcf,'CurrentCharacter'));
    end

    % Run Trials
    first_trial = true;
    while (1)
        
        % Generate Stimulus
        % [stim, stim_tf, Fs, nfft, nframes] = reprstimgen(minfreq,maxfreq,nbins_freq,bindur,totaldur,probfact);
        if first_trial == true
            [stim, Fs, nfft] = generate_stimuli(config.minfreq, config.maxfreq, config.nbins_freq, config.bindur, config.probfact);
            first_trial = false;
        end
        % Reminder Screen
        imshow(Screen2);
        
        % Save Stimulus to File
        for stor = 1:nfft
            fprintf(fid_stim,[num2str(stim(stor)) ',']);
        end
        fprintf(fid_stim,'\n');
        
        % Present Stimulus
        soundsc(stim,Fs)

        if first_trial == false
            [stim, Fs, nfft] = generate_stimuli(config.minfreq, config.maxfreq, config.nbins_freq, config.bindur, config.probfact);

            % Save Stimulus to File
            for stor = 1:nfft
                fprintf(fid_stim,[num2str(stim(stor)) ',']);
            end
            fprintf(fid_stim,'\n');
        end
            
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
            imshow(Screen3)
            k = waitforbuttonpress;
            value = double(get(gcf,'CurrentCharacter')); % f - 102
            while (value ~= 102)
                k = waitforbuttonpress;
                value = double(get(gcf,'CurrentCharacter'));
            end
        else % continue with block
            pause(1)
        end
        
    end

    % Close Files
    fclose(fid);
    fclose(fid_stim);
    fclose(fid_resp);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %eof
end