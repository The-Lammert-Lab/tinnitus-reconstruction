function [mult, binrange] = adjust_resynth(mult, binrange, options)
    arguments
        mult (1,1) {mustBePositive} = 0.001
        binrange (1,1) {mustBeGreaterThanOrEqual(binrange,1), ...
        mustBeLessThanOrEqual(binrange,100)} = 60
        options.fig matlab.ui.Figure
        options.data_dir char = ''
        options.this_hash char = ''
        options.target_sound (:,1) {mustBeNumeric} = []
        options.target_fs {mustBeNonnegative} = 0
        options.n_trials (1,1) {mustBePositive} = inf
        options.config_file (1,:) char = ''
        options.verbose (1,1) logical = true
    end

    %% Environment variables
    mult_min = 0;
    mult_max = 1;
    range_min = 1;
    range_max = 100;

    %% Input handling

    % If no config file path is provided,
    % open a UI to load the config
    [config, ~] = parse_config(options.config_file);

    if isempty(options.data_dir)
        data_dir = config.data_dir;
    else
        data_dir = options.data_dir;
    end

    % Hash config if necessary
    if isempty(options.this_hash)
        options.this_hash = get_hash(config);
    end

    % n_trials can't be more than total data
    total_trials_done = 0;
    d = dir(pathlib.join(data_dir, ['responses_', options.this_hash, '*.csv']));
    for ii = 1:length(d)
        responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
        total_trials_done = total_trials_done + length(responses);
    end
    
    if options.n_trials > total_trials_done
        options.n_trials = inf;
    end

    % Load target sound if not passed as an argument but is in config.
    if (isempty(options.target_sound) || ~options.target_fs) ...
            && (isfield(config, 'target_signal_filepath') && ~isempty(config.target_signal_filepath))
            [options.target_sound, options.target_fs] = audioread(config.target_signal_filepath);
    end

    % Truncate sound if necessary
    if length(options.target_sound) > floor(0.5 * options.target_fs)
        options.target_sound = options.target_sound(1:floor(0.5 * options.target_fs));
    end

    % Create stimgen obj
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);
    Fs = stimgen.get_fs();
    
    %% Make reconstructions
    reconstruction = get_reconstruction('config', config, 'method', 'linear', ...
        'use_n_trials', options.n_trials, 'data_dir', data_dir);

    %% Show figure

    % Useful vars
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    sld_w = 300;
    sld_h = 100;
    lbl_w = 60;
    lbl_h = 20;
    btn_w = 80;
    btn_h = 20;

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

    %% Fig contents
%     xlim([mult_min, mult_max])
%     ylim([range_min, range_max])
%     grid on
% 
%     play_btn = uicontrol(hFig,'Style','pushbutton', ...
%         'position', [(screenWidth/2)-(sld_w/2), 150 btn_w, btn_h], ...
%         'String', 'Play Sounds', 'Callback', @playSounds);
% 
%     confirm_btn = uicontrol(hFig,'Style','pushbutton', ...
%         'position', [(screenWidth/2)+(sld_w/2)-lbl_w, 150, btn_w, btn_h], ...
%         'String', 'Save Choice', 'Callback', {@closeRequest hFig});
% 
%     while ishandle(hFig)
%         [mult, binrange] = ginput(1);
%         scatter(mult, binrange);
%     end

    % Two sliders
    sld_mult = uicontrol(hFig, 'Style', 'slider', ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(sld_h/2), sld_w, sld_h], ...
        'min', mult_min, 'max', mult_max, ...
        'Value', mult, 'Callback', @getValue);

    sld_range = uicontrol(hFig, 'Style', 'slider', ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(1.5*sld_h), sld_w, sld_h], ...
        'min', range_min, 'max', range_max, ...
        'Value', binrange, 'Callback', @getValue);
    
    % Two buttons
    play_btn = uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)-(sld_w/2), 150 btn_w, btn_h], ...
        'String', 'Play Sounds', 'Callback', @playSounds);

    confirm_btn = uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)+(sld_w/2)-lbl_w, 150, btn_w, btn_h], ...
        'String', 'Save Choice', 'Callback', {@closeRequest hFig});

    % Instructions
    uicontrol(hFig, 'Style', 'text', 'String', ['Adjust both sliders together or ' ...
        'separately and press "Play" to hear the effect on your reconstruction. ' ...
        'Choose "confirm" when you are satisfied.'], ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)+(sld_h), sld_w, sld_h])

    % Labels
    uicontrol(hFig, 'Style', 'text', 'String', num2str(mult_min), ... 
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)+(sld_h/2)-(2*lbl_h), lbl_w, lbl_h]);

    uicontrol(hFig, 'Style', 'text', 'String', num2str(mult_max), ... 
        'Position', [(screenWidth/2)+(sld_w/2)-lbl_w, (screenHeight/2)+(sld_h/2)-(2*lbl_h), lbl_w, lbl_h]);

    uicontrol(hFig, 'Style', 'text', 'String', num2str(range_min), ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(sld_h/2)-(2*lbl_h), lbl_w, lbl_h]);

    uicontrol(hFig, 'Style', 'text', 'String', num2str(range_max), ...
        'Position', [(screenWidth/2)+(sld_w/2)-lbl_w, (screenHeight/2)-(sld_h/2)-(2*lbl_h), lbl_w, lbl_h]);

    waitfor(hFig);

    %% Nested functions
    function getValue(~,~)
        mult = sld_mult.Value;
        binrange = sld_range.Value;
    end % getValue
    
    function playSounds(~, ~)
        if ~isempty(options.target_sound)
            soundsc(options.target_sound, options.target_fs);
            pause(length(options.target_sound) / options.target_fs + 0.3);
        end
        recon_wav = stimgen.binnedrepr2wav(reconstruction, mult, binrange);
        soundsc(recon_wav, Fs);
    end % playSounds

end % adjust_resynth

function closeRequest(~,~,hFig)
    ButtonName = questdlg(['Do you wish to ' ...
        'end the resynthesis adjustment?'],...
        'Confirm Close', ...
        'Yes', 'No', 'No');
    switch ButtonName
        case 'Yes'
            delete(hFig);
        case 'No'
            return
    end
end % closeRequest
