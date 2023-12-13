%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ### LoudnessMatch
% 
% Protocol for matching perceived loudness of tones to tinnitus level.
% 
% ```matlab
%   LoudnessMatch(cal_dB) 
%   LoudnessMatch(cal_dB, 'config', 'path2config')
%   LoudnessMatch(cal_dB, 'verbose', false, 'fig', gcf, 'del_fig', false)
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

function LoudnessMatch(cal_dB, options)
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
    Fs = 44100;
    err = 0; % Shared error flag variable

    % Load just noticable dBs and test freqs from threshold data
    [jn_vals, test_freqs] = collect_data_thresh_or_loud('threshold','config',config);

    if isempty(jn_vals) || isempty(test_freqs)
        corelib.verb(options.verbose,'INFO: LoudnessMatch','Generating test frequencies and starting at 60dB')

        test_freqs = gen_octaves(config.min_tone_freq,config.max_tone_freq,2,'semitone');

        % config.max_tone_freq might not always be in test_freqs, but
        % config.min_tone_freq will (start from min freq and double)
        if ~ismember(ceil(config.max_tone_freq),ceil(test_freqs))
            test_freqs(end+1) = config.max_tone_freq;
        end

        init_dBs = 60*ones(length(test_freqs),1);
    else
        init_dBs = jn_vals(:,1) + 10;
    end

    % Subtract calibraiton dB so that sounds are presented at correct level
    init_dBs = init_dBs - cal_dB;
    duration = 1; % seconds to play the tone for

    %%% Create and open data file
    file_hash = [hash_prefix '_', rand_str()];
    filename_dB  = fullfile(config.data_dir, ['loudness_dBs_', file_hash, '.csv']);
    filename_noise_dB  = fullfile(config.data_dir, ['loudness_noise_dB_', file_hash, '.csv']);
    fid_dB = fopen(filename_dB,'w');

    % Save test frequencies 
    % Double each b/c protocol is jndB -> jn, jn+10dB -> jn
    filename_testfreqs = fullfile(config.data_dir, ['loudness_tones_', file_hash, '.csv']);
    writematrix(repelem(test_freqs,2,1), filename_testfreqs);

    %%% Slider values
    dB_min = -100-cal_dB;
    dB_max = 100-cal_dB;
    curr_dB = init_dBs(1);

    % Load error and end screens
    project_dir = pathlib.strip(mfilename('fullpath'), 3);
    ScreenError = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'SlideError.png'));
    ScreenEnd = imread(fullfile(project_dir, 'experiment', 'fixationscreen', 'SlideExpEnd.png'));

    %% Show figure
    % Useful vars
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

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
    clf(hFig)

    %% Fig contents
    sldWidth = 500;
    sldHeight = 20;
    sld = uicontrol(hFig, 'Style', 'slider', ...
        'Position', [(screenWidth/2)-(sldWidth/2), ...
        (screenHeight/2)-sldHeight, ...
        sldWidth sldHeight], ...
        'min', dB_min, 'max', dB_max, ...
        'SliderStep', [1/150 1/150], ...
        'Value', curr_dB, 'Callback', @getValue);

    instrWidth = 300;
    instrHeight = 100;
    instr_txt = uicontrol(hFig, 'Style', 'text', 'String', ...
        ['Adjust the volume of the audio via the slider ' ...
        'until it matches the loudness of your tinnitus. ' ...
        'Press "Play Tone" to hear the adjusted audio. ' ...
        'Press "Save Choice" when satisfied.'], ...
        'Position', [(screenWidth/2)-(instrWidth/2), ...
        (2*screenHeight/3)-instrHeight, ...
        instrWidth, instrHeight]);

    btnWidth = 80;
    btnHeight = 20;
    uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)-(sldWidth/4)-(btnWidth/2), ...
        (screenHeight/2)-sldHeight-(2*btnHeight), ...
        btnWidth, btnHeight], ...
        'String', 'Play Tone', 'Callback', @playTone);

    uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)+(sldWidth/4)-(btnWidth/2), ...
        (screenHeight/2)-sldHeight-(2*btnHeight), ...
        btnWidth, btnHeight], ...
        'String', 'Save Choice', 'Callback', {@saveChoice hFig});

    lblWidth = 60;
    lblHeight = 20;
    uicontrol(hFig, 'Style', 'text', 'String', 'Min', ...
        'Position', [(screenWidth/2)-(sldWidth/2)-lblWidth-10, ...
        (screenHeight/2)-sldHeight-lblHeight, ...
        lblWidth, lblHeight]);

    uicontrol(hFig, 'Style', 'text', 'String', 'Max', ...
        'Position', [(screenWidth/2)+(sldWidth/2)+10, ...
        (screenHeight/2)-sldHeight-lblHeight, ...
        lblWidth lblHeight]);

    %% Run protocol
    for ii = 1:length(test_freqs)+1
        if ii == length(test_freqs)+1
            curr_tone = white_noise(duration,Fs);
            curr_init_dB = 60-cal_dB;
            noise_trial = true;
        else
            curr_tone = pure_tone(test_freqs(ii),duration,Fs);
            curr_init_dB = init_dBs(ii);
        end

        % Reset slider value to just noticable + 10 ( == init_dB)
        curr_dB = curr_init_dB;
        sld.Value = curr_dB;

        instr_txt.String =  ['Adjust the volume of the audio via the slider ' ...
            'until it matches the loudness of your tinnitus. ' ...
            'Press "Play Tone" to hear the adjusted audio. ' ...
            'Press "Save Choice" when satisfied.'];

        uiwait(hFig)
        if err
            return
        end

        % Repeat
        curr_dB = curr_init_dB;
        sld.Value = curr_dB;

        % Update instructions
        instr_txt.String = ['Please repeat the same steps as before: ' ...
            'Adjust the volume of the audio via the slider ' ...
            'until it matches the loudness of your tinnitus. ' ...
            'Press "Play Tone" to hear the adjusted audio. ' ...
            'Press "Save Choice" when satisfied.'];

        uiwait(hFig)
        if err
            return
        end
    end

    fclose(fid_dB);

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
    
    %% Callback Functions
    function getValue(~,~)
        curr_dB = sld.Value;
    end % getValue

    function playTone(~, ~)
        % Convert dB to gain and play sound
        gain = 10^(curr_dB/20);
        tone_to_play = gain*curr_tone;
        if min(tone_to_play) < -1 || max(tone_to_play) > 1
            disp_fullscreen(ScreenError, hFig);
            warning('Sound is clipping. Recalibrate dB level.')
            err = 1;
            uiresume(hFig)
            return
        end
        sound(tone_to_play,Fs,24)
    end % playTone

    function saveChoice(~,~,hFig)
        % Save the just noticable value
        jn_dB = curr_dB+cal_dB;
        jn_amp = 10^(jn_dB/20);
        if noise_trial
            writematrix([jn_dB, jn_amp], filename_noise_dB);
        else
            fprintf(fid_dB, [num2str(jn_dB), ',', num2str(jn_amp), '\n']);
        end
        uiresume(hFig)
    end
end

function closeRequest(~,~,hFig)
    ButtonName = questdlg('Are you sure you want to end the experiment?',...
        'Confirm', ...
        'Yes', 'No', 'Yes');
    switch ButtonName
        case 'Yes'
            delete(hFig);
        case 'No'
            return
    end
end % closeRequest
