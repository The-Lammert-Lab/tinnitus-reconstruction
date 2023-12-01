function ThresholdDetermination(cal_dB, options)
    arguments
        cal_dB (1,1) {mustBeReal}
        options.fig matlab.ui.Figure
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
    amp_min = 0;
    amp_max = 5;
    duration = 1; % seconds to play the tone for
    
    min_test_freq = 1000;
    max_test_freq = 16000;
    n_in_oct = 2; % Number of points inside each octave (2 points = split octave into thirds)

    % Define scale factor so it can be referenced in figure creation
    scale_factor = amp_min;

    % Generate test frequencies
    n_octs = floor(log2(max_test_freq/min_test_freq)); % Number of octaves between min and max
    oct_vals = min_test_freq * 2.^(0:n_octs); % Octave frequency values

    test_freqs = zeros(length(oct_vals)+(n_in_oct*n_octs),1);
    oct_marks = 1:n_in_oct+1:length(test_freqs);
    for ii = 1:n_octs
        test_freqs(oct_marks(ii):oct_marks(ii)+n_in_oct+1) = linspace(oct_vals(ii),oct_vals(ii+1),n_in_oct+2);
    end

    % Create and open data file
    file_hash = [hash_prefix '_', rand_str()];
    filename_dB  = fullfile(config.data_dir, ['threshold_dB_', file_hash, '.csv']);
    fid_dB = fopen(filename_dB,'w');

    % Save test frequencies 
    % Double each b/c protocol is 60dB -> jn, jn+10dB -> jn
    filename_testfreqs = fullfile(config.data_dir, ['threshold_tones_', file_hash, '.csv']);
    writematrix(repelem(test_freqs,2,1), filename_testfreqs);

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
        'min', amp_min, 'max', amp_max, ...
        'Value', scale_factor, 'Callback', @getValue);

    instrWidth = 300;
    instrHeight = 100;
    instr_txt = uicontrol(hFig, 'Style', 'text', 'String', ...
        ['Adjust the volume of the ' ...
        'audio via the slider until it is "just audible". Press "Play Tone" ' ...
        'to hear the adjusted audio. Press "Save Choice" when satisfied.'], ...
        'Position', [(screenWidth/2)-(instrWidth/2), ...
                    (2*screenHeight/3)-instrHeight, ...
                    instrWidth instrHeight]);

    btnWidth = 80;
    btnHeight = 20;
    uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)-(sldWidth/4)-(btnWidth/2), ...
                    (screenHeight/2)-sldHeight-(2*btnHeight), ...
                    btnWidth btnHeight], ...
        'String', 'Play Tone', 'Callback', @playTone);

    uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)+(sldWidth/4)-(btnWidth/2), ...
                    (screenHeight/2)-sldHeight-(2*btnHeight), ...
                    btnWidth btnHeight], ...
        'String', 'Save Choice', 'Callback', {@saveChoice hFig});

    lblWidth = 60;
    lblHeight = 20;
    uicontrol(hFig, 'Style', 'text', 'String', 'Min', ...
        'Position', [(screenWidth/2)-(sldWidth/2)-lblWidth-10, ...
                    (screenHeight/2)-sldHeight-lblHeight, ...
                    lblWidth lblHeight]);

    uicontrol(hFig, 'Style', 'text', 'String', 'Max', ...
        'Position', [(screenWidth/2)+(sldWidth/2)+10, ...
                    (screenHeight/2)-sldHeight-lblHeight, ...
                    lblWidth lblHeight]);

    %% Allow adjusting to happen
    for ii = 1:length(test_freqs)
        curr_tone = pure_tone(test_freqs(ii),duration,Fs);
        % Set scale factor such that first tone is presented at 60dB
        scale_factor = 10^((60-cal_dB)/20);
        sld.Value = scale_factor;

        instr_txt.String = ['Adjust the volume of the ' ...
            'audio via the slider until it is "just audible". Press "Play Tone" ' ...
            'to hear the adjusted audio. Press "Save Choice" when satisfied.'];

        uiwait(hFig)

        % Update the scale factor to present tone at (jn + 10)dB
        scale_factor = scale_factor + 10^(1/2);
        sld.Value = scale_factor;

        % Update instructions
        instr_txt.String = ['Please repeat the same steps as before:' ...
            'Adjust the volume of the ' ...
            'audio via the slider until it is "just audible". Press "Play Tone" ' ...
            'to hear the adjusted audio. Press "Save Choice" when satisfied.'];

        uiwait(hFig)
    end

    fclose(fid_dB);
    delete(hFig)
    
    %% Callback Functions
    function getValue(~,~)
        scale_factor = sld.Value;
    end % getValue

    function playTone(~, ~)
        sound(scale_factor*curr_tone,Fs)
    end % playTone

    function saveChoice(~,~,hFig)
        % Save the just noticable value
        jn_amp = scale_factor;
        jn_dB = 20*log10(jn_amp);
        fprintf(fid_dB, [num2str(jn_dB), ',', num2str(jn_amp), '\n']);
        uiresume(hFig)
    end
end % ThresholdDetermination

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