function PitchMatch(options)
    arguments
        options.config_file char = []
        options.verbose (1,1) {mustBeNumericOrLogical} = true
    end
    
    % Get the datetime and posix time
    % for the start of the experiment
    this_datetime = datetime('now', 'Timezone', 'local');
    posix_time = num2str(floor(posixtime(this_datetime)));
    
    % Is a config file provided?
    %   If so, read it.
    %   If not, open a GUI dialog window to find it.
    [config, config_path] = parse_config(options.config_file);
    
    % Hash the config struct to get a unique string representation
    % Get the hash before modifying the config at all
    config_hash = get_hash(config);

    % If < 5 PM phases have been completed already, don't do more.
    total_phases_done = length(dir(fullfile(config.data_dir, ['PM_responses_', config_hash, '*.csv'])));
    if total_phases_done > 4
        corelib.verb(options.verbose, 'INFO PitchMatch', 'At least 5 phases have been completed. Exiting...')
        return
    end
    
    % Get the hash prefix for file naming
    hash_prefix = [config_hash, '_', posix_time];
    
    % Try to create the data directory if it doesn't exist
    mkdir(config.data_dir);
    
    % Add config file to data directory
    try
        copyfile(config_path, config.data_dir);
    catch
        warning('Config file already exists in data directory');
    end
    %% Setup
    
    % Useful variables
    project_dir = pathlib.strip(mfilename('fullpath'), 3);
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    Fs = 44100;

    % Break octave up into how many steps?
    if isfield(config,'in_oct_steps') && ~isempty(config.in_oct_steps)
        in_oct_steps = config.in_oct_steps;
    else
        in_oct_steps = 10;
    end

    % Starting frequencies
    freqL = 3180;
    freqH = 4000;

    % Flag and counter
    in_oct = false;
    counter = 0;
    in_oct_counter = 0;
    
    % Generate filenames
    file_hash = [hash_prefix '_', rand_str()];

    filename_responses  = fullfile(config.data_dir, ['PM_responses_', file_hash, '.csv']);
    filename_stimuli    = fullfile(config.data_dir, ['PM_stimuli_', file_hash, '.csv']);
    filename_octave     = fullfile(config.data_dir, ['PM_octave_', file_hash, '.csv']);
    filename_oct_resp   = fullfile(config.data_dir, ['PM_octave_responses_', file_hash, '.csv']);

    % Open files
    fid_responses = fopen(filename_responses,'w');
    fid_stimuli = fopen(filename_stimuli,'w');
    fid_oct_resp = fopen(filename_oct_resp,'w');
    
    %% Load Presentations Screens
    ScreenInit = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideInit.png'));
    ScreenA = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideA.png'));
    ScreenB = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideB.png'));
    ScreenChoose = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideC.png'));
    
    %% Intro Screen & Start
    
    % Show the startup screen
    hFig = figure('Numbertitle','off',...
        'Position', [0 0 screenWidth screenHeight],...
        'Color',[0.5 0.5 0.5],...
        'Toolbar','none', ...
        'MenuBar','none');
    hFig.CloseRequestFcn = {@closeRequest hFig};
    
    disp_fullscreen(ScreenInit, hFig);
    
    % Press "F" to start
    k = waitforkeypress();
    if k < 0
        corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
        return
    end
    value = double(get(gcf,'CurrentCharacter')); % f - 102
    
    % Check the value, if "F" then continue
    while (value ~= 102)
        k = waitforkeypress();
        if k < 0
            corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
            return
        end
        value = double(get(gcf,'CurrentCharacter'));
    end

    %% Run 2AFC PM using Henry's Binary method
    while (true)
        % Generate stimuli
        stimL = pure_tone(freqL,config.duration,Fs);
        stimH = pure_tone(freqH,config.duration,Fs);

        % Show first pitch screen
        disp_fullscreen(ScreenA, hFig);
        soundsc(stimL,Fs);

        pause(1);

        % Show second pitch screen
        disp_fullscreen(ScreenB, hFig);
        soundsc(stimH,Fs);

        % Show response screen
        disp_fullscreen(ScreenChoose, hFig);

        % Collect response
        k = waitforkeypress();
        if k < 0
            corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
            break
        end
        value = double(get(gcf,'CurrentCharacter')); % f - 102, j - 106
        while isempty(value) || (value ~= 102) && (value ~= 106)
            k = waitforkeypress();
            if k < 0
                corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
                break
            end
            value = double(get(gcf,'CurrentCharacter'));
        end

        % Save previous response to check for reversal
        if counter > 1
            if in_oct_counter == 1
                % Set previous response such that if curr respnum is 0
                % and first in_oct respnum is 1, the exp doesn't end
                prev_respnum = 1;
            else
                prev_respnum = respnum;
            end
        end

        % Convert response to binary
        respnum = -1;
        switch value
            case 106
                respnum = 1;
            case 102
                respnum = 0;
        end

        % write stimuli and response to file
        fprintf(fid_stimuli, [num2str(freqL), ',', num2str(freqH), '\n']);
        fprintf(fid_responses, [num2str(respnum), '\n']);

         % Decide on next 2AFC stimuli frequencies
         % Make sure stimuli are within bounds
         % If not, their choise is irrelevant b/c min or max is hit
         % Switch if reversal, too
         if freqL / 2 < config.min_freq || freqH * 2 > config.max_freq || (counter > 1 && prev_respnum ~= respnum)
             if in_oct
                 % This only hits on reversal
                 break
             else
                 % Can hit on any condition

                 % TODO: consider octave bounds
                 % (oct_min = (freqL+freqH)/2;
                 % oct_max = oct_min*2;)?
%                  oct_max = freqH;

                 % Take the octave and break it into set fractions

                 %%%%% CHANGE TO WHOLE STEPS
                 in_oct_freqs = zeros(13,1);
                 in_oct_freqs(1) = freqL;
                 for ii = 2:13
                    in_oct_freqs(ii) = 2^(1/12)*in_oct_freqs(ii-1);
                 end
                 in_oct_freqs = in_oct_freqs(1:2:end);

                 freqH = in_oct_freqs(2);

                 %  Move to in-octave phase
                 in_oct = true;
             end
         else
             if in_oct
                 % B/c range is fixed, a reversal is the final choice,
                 % and will be caught in above logic

                 % Reached the high end of possible in octave stimuli
                 if in_oct_counter == in_oct_steps
                     break
                 else
                     % This is > 1st in-octave stimulus
                     freqL = freqH;
                     freqH = in_oct_freqs(in_oct_counter+2);
                 end
             else
                 switch respnum
                     case 1 % Higher freq chosen
                         freqL = freqH;
                         freqH = freqH * 2;
                     case 0 % Lower freq chosen
                         freqH = freqL;
                         freqL = freqL / 2;
                 end
             end
         end
         counter = counter + 1;
         if in_oct
             in_oct_counter = in_oct_counter + 1;
         end
    end % while

    %% Run octave confusion
    % Identify chosen tinnitus tone by last response
    chosen_tone = 0;
    switch respnum
        case 0
            chosen_tone = freqL;
        case 1
            chosen_tone = freqH;
    end
    oct_conf_tones = [chosen_tone, chosen_tone / 2; ...
                      chosen_tone, chosen_tone * 2];

    % Save octave confusion stimuli
    writematrix(oct_conf_tones,filename_octave);

    for ii = 1:size(oct_conf_tones,1)
        stimA = pure_tone(oct_conf_tones(ii,1),config.duration,Fs);
        stimB = pure_tone(oct_conf_tones(ii,2),config.duration,Fs);

        % Show first pitch screen
        disp_fullscreen(ScreenA, hFig);
        soundsc(stimA,Fs);

        pause(1);

        % Show second pitch screen
        disp_fullscreen(ScreenB, hFig);
        soundsc(stimB,Fs);

        % Show response screen
        disp_fullscreen(ScreenChoose, hFig);

        % Collect response
        k = waitforkeypress();
        if k < 0
            corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
            break
        end
        value = double(get(gcf,'CurrentCharacter')); % f - 102, j - 106
        while isempty(value) || (value ~= 102) && (value ~= 106)
            k = waitforkeypress();
            if k < 0
                corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
                break
            end
            value = double(get(gcf,'CurrentCharacter'));
        end

        % Convert response to binary
        respnum = -1;
        switch value
            case 106
                respnum = 1;
            case 102
                respnum = 0;
        end

        fprintf(fid_oct_resp, [num2str(respnum), '\n']);
    end % for

    %% Close files and figure
    fclose(fid_stimuli);
    fclose(fid_responses);
    fclose(fid_oct_resp);
    
    delete(hFig)
end % PitchMatch

%% Local functions
% Present confirmation box on figure exit 
function closeRequest(~,~,hFig)
    ButtonName = questdlg('Are you sure you want to end the experiment?',...
        'Confirm Close', ...
        'Yes', 'No', 'No');
    switch ButtonName
        case 'Yes'
            delete(hFig);
        case 'No'
            return
    end
end % closeRequest
