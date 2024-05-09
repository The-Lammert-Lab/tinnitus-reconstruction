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
%   - max_dB_allowed_, `1x1` scalar, name-value, default: `95`.
%       The maximum dB value at which tones can be played. 
%       `cal_dB` must be greater than this value. Not intended to be changed from 95.
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
%   - Six `CSV` files: `PM_tone_responses`, `PM_tones`, 
%       `PM_octave_responses`, `PM_octaves`,  
%       `PM_tone_dBs`, `PM_octave_dBs`
%       saved to config.data_dir.

function PitchMatch(cal_dB, options)
    arguments
        cal_dB (1,1) {mustBeReal}
        options.max_dB (1,1) {mustBeReal} = 95
        options.fig matlab.ui.Figure
        options.config_file char = []
        options.del_fig logical = true
        options.verbose (1,1) {mustBeNumericOrLogical} = true
    end
    
    assert(cal_dB > options.max_dB, ...
        ['cal_dB must be greater than ', num2str(options.max_dB), ' dB.'])

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

    %% Validate settings then save

    % Starting frequencies
    freqL = 3180;
    freqH = 4000;

    assert(config.min_tone_freq <= freqL, ['config.min_tone_freq must be less than or equal to ', num2str(freqL)])
    assert(config.max_tone_freq >= freqH, ['config.max_tone_freq must be greater than or equal to ', num2str(freqH)])

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
    duration = 1; % Seconds for sound to be played

    % Flag and counter
    in_oct = false;
    counter = 0;
    in_oct_counter = 0;

    % Get list of all possible octaves from the starting points
    n_octs_high   = floor(log2(config.max_tone_freq/freqH)); % Number of octaves between freqH and config.max_tone_freq
    n_octs_low    = floor(log2(freqL/config.min_tone_freq)); % Number of octaves between config.min_tone_freq and freqL
    possible_octs = [fliplr(freqL*0.5.^(0:n_octs_low)), freqH*2.^(0:n_octs_high)]'; % All possible octave values

    % Load loudness-matched dBs
    [loudness_dBs, ~, loudness_tones] = collect_data_thresh_or_loud('loudness','config',config);
    if ~isempty(loudness_dBs) && ~isempty(loudness_tones)
        loudness_dBs = loudness_dBs+5;
        % Interpolate gains
        oct_dBs = interp1(loudness_tones,loudness_dBs,possible_octs)-cal_dB;
        oct_gains = 10.^(oct_dBs/20);
    else % If there's no data, set all at 60dB
        oct_dBs = 60*ones(length(possible_octs),1)-cal_dB;
        oct_gains = 10.^(oct_dBs/20);
    end

    % Generate filenames
    file_hash = [hash_prefix '_', rand_str()];

    filename_tone_resps = fullfile(config.data_dir, ['PM_tone_responses_', file_hash, '.csv']);
    filename_tones      = fullfile(config.data_dir, ['PM_tones_', file_hash, '.csv']);
    filename_oct_resp   = fullfile(config.data_dir, ['PM_octave_responses_', file_hash, '.csv']);
    filename_octave     = fullfile(config.data_dir, ['PM_octaves_', file_hash, '.csv']);
    filename_tone_dBs   = fullfile(config.data_dir, ['PM_tone_dBs_', file_hash, '.csv']);
    filename_oct_dBs    = fullfile(config.data_dir, ['PM_octave_dBs_', file_hash, '.csv']);

    % Open files
    fid_tone_resps = fopen(filename_tone_resps,'w');
    fid_tones      = fopen(filename_tones,'w');
    fid_oct_resp   = fopen(filename_oct_resp,'w');
    fid_tone_dBs   = fopen(filename_tone_dBs,'w');
    
    %% Load Presentations Screens
    ScreenInit   = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideInit.png'));
    ScreenA      = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideA.png'));
    ScreenB      = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideB.png'));
    ScreenChoose = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'PitchMatch', 'SlideC.png'));
    ScreenError  = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'SlideError.png'));
    ScreenEnd    = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'SlideExpEnd.png'));
    
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
        stimL = pure_tone(freqL,duration,Fs);
        stimH = pure_tone(freqH,duration,Fs);

        if counter == 0
            % Window to apply to stimuli
            win = tukeywin(length(stimL),0.08);
        end
        
        if in_oct
            % Values to save
            perceived_dBL = in_oct_dBs(in_oct_freqs==freqL)+cal_dB;
            perceived_dBH = in_oct_dBs(in_oct_freqs==freqH)+cal_dB;
            % Values to use
            gainL = in_oct_gains(in_oct_freqs==freqL);
            gainH = in_oct_gains(in_oct_freqs==freqH);
        else
            % Values to save
            perceived_dBL = oct_dBs(possible_octs==freqL)+cal_dB;
            perceived_dBH = oct_dBs(possible_octs==freqH)+cal_dB;
            % Values to use
            gainL = oct_gains(possible_octs==freqL);
            gainH = oct_gains(possible_octs==freqH);
        end

        stimL = gainL * win .* stimL;
        stimH = gainH * win .* stimH;

        if min([stimL; stimH]) < -1 || max([stimL; stimH]) > 1
            disp_fullscreen(ScreenError, hFig);
            warning('Sound is clipping. Recalibrate dB level.')
            return
        end

        % Show first pitch screen
        disp_fullscreen(ScreenA, hFig);
        sound(stimL,Fs,24);

        % Pause so screen is up while sound plays and next sound doesn't play too soon
        pause(1.5*duration); 

        % Show second pitch screen
        disp_fullscreen(ScreenB, hFig);
        sound(stimH,Fs,24);
        pause(duration); % Pause so screen is up while sound plays

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

        % write stimuli and response to file
        fprintf(fid_tones, [num2str(freqL), ',', num2str(freqH), '\n']);
        fprintf(fid_tone_resps, [num2str(respnum), '\n']);
        fprintf(fid_tone_dBs, [num2str(perceived_dBL), ',', num2str(perceived_dBH), '\n']);

         % Decide on next 2AFC stimuli frequencies
         % Make sure stimuli are within bounds
         % If not, their choise is irrelevant b/c min or max is hit
         % Switch if reversal, too
         if ~in_oct && (freqL / 2 < config.min_tone_freq || freqH * 2 > config.max_tone_freq) || (counter > 0 && prev_respnum ~= respnum)
             if in_oct
                 % This only hits on reversal
                 break
             else
                 % If min or max was the preferred tone
                 if (freqH == config.max_tone_freq && respnum) || (freqL == config.min_tone_freq && ~respnum)
                     half_steps = semitones(freqL,12,'up');
                 else % Reversal
                     % Choose frequency to center based on last response
                     if ~respnum 
                         center_freq = freqL;
                     else
                         center_freq = freqH;
                     end
                     % Center choice freq
                     hs_down = semitones(center_freq,6,'down');
                     hs_up = semitones(center_freq,6,'up');
                     half_steps = [flipud(hs_down); hs_up(2:end)];
                 end

                 % Take whole steps
                 in_oct_freqs = half_steps(1:2:end);

                 if ~isempty(loudness_dBs) && ~isempty(loudness_tones)
                     % Interpolate for these values
                     in_oct_dBs = interp1(loudness_tones,loudness_dBs,in_oct_freqs)-cal_dB;
                     in_oct_gains = 10.^(in_oct_dBs/20);
                 else % If there's no data, set all at 60dB
                     in_oct_dBs = 60*ones(length(in_oct_freqs),1)-cal_dB;
                     in_oct_gains = 10.^(oct_dBs/20);
                 end

                 % Set new freqL and freqH
                 freqL = in_oct_freqs(1);
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
    oct_conf_tones = [chosen_tone / 2, chosen_tone; ...
                      chosen_tone, chosen_tone * 2];

    % Get dB/gain for this portion of experiment
    % Add 10 to dBs because octave tone might be really high & hard to hear
    % Chosen tone is guaranteed to be in in_oct_freqs. 
    this_dB = in_oct_dBs(in_oct_freqs == chosen_tone) + 10;
    this_gain = 10^(this_dB/20);

    % Save octave confusion stimuli and presentation level
    writematrix(oct_conf_tones,filename_octave);
    writematrix(repelem(this_dB+cal_dB,2,2),filename_oct_dBs);

    for ii = 1:size(oct_conf_tones,1)
        stimA = pure_tone(oct_conf_tones(ii,1),duration,Fs);
        stimB = pure_tone(oct_conf_tones(ii,2),duration,Fs);

        stimA = this_gain * win .* stimA;
        stimB = this_gain * win .* stimB;

        if min([stimA; stimB]) < -1 || max([stimA; stimB]) > 1
            disp_fullscreen(ScreenError, hFig);
            warning('Sound is clipping. Recalibrate dB level.')
            return
        end

        % Show first pitch screen
        disp_fullscreen(ScreenA, hFig);
        sound(stimA,Fs,24);

        % Pause so screen is up while sound plays and next sound doesn't play too soon
        pause(1.5*duration);

        % Show second pitch screen
        disp_fullscreen(ScreenB, hFig);
        sound(stimB,Fs,24);
        pause(duration); % Pause so screen is up while sound plays

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
    fclose(fid_tones);
    fclose(fid_tone_resps);
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
