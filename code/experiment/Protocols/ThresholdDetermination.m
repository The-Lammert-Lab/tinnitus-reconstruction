function ThresholdDetermination(cal_dB, options)
    arguments
        cal_dB (1,1) {mustBeReal}
        options.cal_tone (:,1) {mustBeReal} = []
        options.config_file char = []
        options.fig matlab.ui.Figure = []
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
    test_tone = pure_tone(1000,1,Fs);
    apm_min = -100;
    amp_max = 100;
    n_repeats = 2;

    % Setup and calibrate SPL meter
    SPL = splMeter();

    if isempty(options.cal_tone)
        options.cal_tone = test_tone;
    end

    calibrate(SPL,options.cal_tone,cal_dB)
    
    % Figure out initial scale factor 
    % such that sound is presented at 60dB
    scale_factor = 10^((60-cal_dB)/20);

    file_hash = [hash_prefix '_', rand_str()];
    filename_dB  = fullfile(config.data_dir, ['threshold_dB_', file_hash, '.csv']);
    fid_dB = fopen(filename_dB,'w');

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
    sld = uicontrol(hFig, 'Style', 'slider', ...
        'Position', [120 100 300 100], ...
        'min', apm_min, 'max', amp_max, ...
        'Value', scale_factor, 'Callback', @getValue);

    uicontrol(hFig,'Style','pushbutton', ...
        'position', [130 150 80 20], ...
        'String', 'Play Tone', 'Callback', @playTone);

    uicontrol(hFig,'Style','pushbutton', ...
        'position', [330 150 80 20], ...
        'String', 'Save Choice', 'Callback', {@saveChoice hFig});

    instruction_txt = uicontrol(hFig, 'Style', 'text', 'String', ...
        ['Adjust the volume of the ' ...
        'audio via the slider until it is "just audible". Press "Play Tone" ' ...
        'to hear the adjusted audio. Press "Save Choice" when satisfied.'], ...
        'Position', [120 200 300 100]);

    uicontrol(hFig, 'Style', 'text', 'String', num2str(apm_min), ...
        'Position', [60 180 60 20]);

    uicontrol(hFig, 'Style', 'text', 'String', num2str(amp_max), ...
        'Position', [420 180 60 20]);

    %% Allow adjusting to happen
    for ii = 1:n_repeats
        just_noticable = false;
        while ~just_noticable
            continue
        end

        % Save the just noticable value
        jn_amp = scale_factor;
        jn_dB = 20*log10(jn_amp);

        fprintf(fid_dB, [num2str(jn_dB), '\n']);

        % Update the scale factor such that tone is presented at (jn + 10) dB
        % Could just add 3.1623
        scale_factor = jn_amp + 10^(1/2);

        % Update instructions
        instruction_txt.String = ['Please repeat the same steps as before: \n' ...
            'Adjust the volume of the ' ...
            'audio via the slider until it is "just audible". Press "Play Tone" ' ...
            'to hear the adjusted audio. Press "Save Choice" when satisfied.'];
    end

    fclose(fid_dB);
    
    %% Callback Functions
    function getValue(~,~)
        scale_factor = sld.Value;
    end % getValue

    function playTone(~, ~)
        sound(scale_factor*test_tone,Fs)
    end % playTone

    function saveChoice(~,~)
        just_noticable = true;
    end

    function closeRequest(~,~,hFig)
        ButtonName = questdlg('Confirm volume setting and continue protocol?',...
            'Confirm Volume', ...
            'Yes', 'No', 'Yes');
        switch ButtonName
            case 'Yes'
                delete(hFig);
            case 'No'
                return
        end
    end % closeRequest

end % ThresholdDetermination
