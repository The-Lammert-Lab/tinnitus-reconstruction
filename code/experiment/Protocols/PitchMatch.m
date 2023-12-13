%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ### PitchMatch
% 
% Protocol for matching tinnitus to a single tone.
% 
% Based on the Binary method from:
% Henry, James A., et al. 
% "Comparison of manual and computer-automated procedures for tinnitus pitch-matching." 
% Journal of Rehabilitation Research & Development 41.2 (2004).
% 
% Henry, James A., et al. 
% "Comparison of two computer-automated procedures for tinnitus pitch matching." 
% Journal of Rehabilitation Research & Development 38.5 (2001).
% 
% ```matlab
%   PitchMatch(cal_dB) 
%   PitchMatch(cal_dB, 'config', 'path2config')
%   PitchMatch(cal_dB, 'verbose', false, 'fig', gcf, 'del_fig', false)
% ```
% 
% **ARGUMENTS:**
% 
%   - cal_dB, `1x1` scalar, the externally measured decibel level of a 
%       1kHz tone at the system volume that will be used during the
%       protocol.
%   - config_file, `character vector`, name-value, default: `''`
%       Path to the desired config file.
%       GUI will open for the user to select a config if no path is supplied.
%   - verbose, `logical`, name-value, default: `true`,
%       Flag to show informational messages.
%   - del_fig, `logical`, name-value, default: `true`,
%       Flag to delete figure at the end of the experiment.
%   - fig, `matlab.ui.Figure`, name-value.
%       Handle to figure window in which to display instructions
%       Function will create a new figure if none is supplied.
% 
% **OUTPUTS:**
% 
%   - Three `CSV` files: `loudness_dBs`, `loudness_noise_dB`, `loudness_tones`
%       saved to config.data_dir.

function PitchMatch(cal_dB, options)
    arguments
        cal_dB (1,1) {mustBeReal}
        options.fig matlab.ui.Figure
        options.config_file char = []
        options.del_fig logical = true
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

    % Starting frequencies
    freqL = 3180;
    freqH = 4000;

    % Flag and counter
    in_oct = false;
    counter = 0;
    in_oct_counter = 0;

    % Load loudness-matched dBs
    [loudness_dBs, loudness_tones] = collect_data_thresh_or_loud('loudness','config',config);

    % Interpolate gains
    n_octs_high = floor(log2(config.max_tone_freq/freqH)); % Number of octaves between freqH and config.max_tone_freq
    n_octs_low = floor(log2(freqL/config.min_tone_freq)); % Number of octaves between config.min_tone_freq and freqL
    possible_octs = [fliplr(freqL*0.5.^(0:n_octs_low)), freqH*2.^(0:n_octs_high)]'; % All possible octave values 
    oct_dBs = interp1(loudness_tones,loudness_dBs,possible_octs)-cal_dB;
    oct_gains = 10.^(oct_dBs/20);

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
    ScreenError = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'SlideError.png'));
    ScreenEnd = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'SlideExpEnd.png'));
    
    %% Intro Screen & Start
    
    % Open full screen figure if none provided or the provided was deleted
    if ~isfield(options, 'fig') || ~ishandle(options.fig)
        hFig = figure('Numbertitle','off',...
            'Position', [0 0 screenWidth screenHeight],...
            'Color',[0.5 0.5 0.5],...
            'Toolbar','none', ...
            'MenuBar','none');
    else
        hFig = options.fig;
    end
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
        
        if in_oct
            gainL = in_oct_gains(in_oct_freqs==freqL);
            gainH = in_oct_gains(in_oct_freqs==freqH);
        else
            gainL = oct_gains(possible_octs==freqL);
            gainH = oct_gains(possible_octs==freqH);
        end

        stimL = gainL*stimL;
        stimH = gainH*stimH;

        if min([stimL; stimH]) < -1 || max([stimL; stimH]) > 1
            disp_fullscreen(ScreenError, hFig);
            warning('Sound is clipping. Recalibrate dB level.')
            return
        end

        % Show first pitch screen
        disp_fullscreen(ScreenA, hFig);
        sound(stimL,Fs,24);

        pause(1);

        % Show second pitch screen
        disp_fullscreen(ScreenB, hFig);
        sound(stimH,Fs,24);

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
        if counter > 0
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

        % TODO: SAVE PRESENTED DB LEVEL

        % write stimuli and response to file
        fprintf(fid_stimuli, [num2str(freqL), ',', num2str(freqH), '\n']);
        fprintf(fid_responses, [num2str(respnum), '\n']);

         % Decide on next 2AFC stimuli frequencies
         % Make sure stimuli are within bounds
         % If not, their choise is irrelevant b/c min or max is hit
         % Switch if reversal, too
         if freqL / 2 < config.min_tone_freq || freqH * 2 > config.max_tone_freq || (counter > 0 && prev_respnum ~= respnum)
             if in_oct
                 % This only hits on reversal
                 break
             else
                 % Can hit on any condition

                 % TODO: consider octave bounds
                 % (oct_min = (freqL+freqH)/2;
                 % oct_max = oct_min*2;)?

                 % Take the octave and break it into semitones
                 half_steps = semitones(freqL);

                 % Take the whole steps
                 in_oct_freqs = half_steps(1:2:end);

                 % Interpolate for these values
                 in_oct_dBs = interp1(loudness_tones,loudness_dBs,in_oct_freqs)-cal_dB;
                 in_oct_gains = 10.^(in_oct_dBs/20);

                 % Set new freqH
                 freqH = in_oct_freqs(2);

                 % Move to in-octave phase
                 in_oct = true;
             end
         else
             if in_oct
                 % B/c range is fixed, a reversal is the final choice,
                 % and will be caught in above logic

                 % Reached the high end of possible in octave stimuli
                 if in_oct_counter == length(in_oct_freqs)-1
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

    oct_conf_dBs = interp1(loudness_tones,loudness_dBs,oct_conf_tones)-cal_dB;
    oct_conf_gains = 10.^(oct_conf_dBs/20);

    % TODO: SAVE PRESENTED DB LEVEL

    % Save octave confusion stimuli
    writematrix(oct_conf_tones,filename_octave);

    for ii = 1:size(oct_conf_tones,1)
        stimA = pure_tone(oct_conf_tones(ii,1),config.duration,Fs);
        stimB = pure_tone(oct_conf_tones(ii,2),config.duration,Fs);

        gainA = oct_conf_gains(ii,1);
        gainB = oct_conf_gains(ii,2);

        stimA = gainA*stimA;
        stimB = gainB*stimB;

        if min([stimA; stimB]) < -1 || max([stimA; stimB]) > 1
            disp_fullscreen(ScreenError, hFig);
            warning('Sound is clipping. Recalibrate dB level.')
            return
        end

        % Show first pitch screen
        disp_fullscreen(ScreenA, hFig);
        sound(stimA,Fs,24);

        pause(1);

        % Show second pitch screen
        disp_fullscreen(ScreenB, hFig);
        sound(stimB,Fs,24);

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

    % Show completion screen
    disp_fullscreen(ScreenEnd, hFig);
    k = waitforkeypress();
    if k < 0
        corelib.verb(options.verbose, 'INFO PitchMatch', 'Exiting...')
        return
    end
    
    if options.del_fig
        delete(hFig)
    end
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

% function value = readkeypress(target, options)
%     % Wait for a key press and return the value
%     % only if the pressed key was in `target`. 
% 
%     arguments
%         target {mustBeNumeric}
%         options.verbose (1,1) {mustBeNumericOrLogical} = true
%     end
% 
%     value = double(get(gcf,'CurrentCharacter'));
%     while isempty(value) || ~ismember(value, target)
%         k = waitforkeypress(options.verbose);
%         if k < 0
%             value = -1;
%             return
%         end
%         value = double(get(gcf,'CurrentCharacter'));
%     end
% 
%     return
% end % function
