% ### adjust_resynth
% 
% Runs interactive adjustment of `mult` and `binrange` parameters
% for reconstruction resynthesis. Plays target sound as comparison
% if one is provided or included in config.
% 
% **ARGUMENTS:**
% 
%   - cal_dB, `1x1` scalar, the externally measured decibel level of a 
%       1kHz tone at the system volume that will be used during the
%       protocol.
%   - mult: `1 x 1` positive scalar, default: 0.001
%       initial value for the peak-sharpening `mult` parameter.
%    - binrange: `1 x 1` scalar, default: 60,
%       must be between [1, 100]. The initial value for the 
%       upper bound of the [0, binrange] dynamic range of 
%       the peak-sharpened reconstruction.
%   - data_dir: `character vector`, name-value, default: empty
%       Directory where data is stored. If blank, config.data_dir is used. 
%   - project_dir: `character vector`, name-value, default: empty
%       Set as an input to reduce tasks if running from `Protocol.m`.
%   - this_hash: `character vector`, name-value, default: empty
%       Hash to use for output file. Generates from config if blank.
%   - target_sound: `numeric vector`, name-value, default: empty
%       Target sound for comparison. Generates from config if blank.
%   - target_fs: `Positive scalar`, name-value, default: empty
%       Frequency associated with target_sound
%   - n_trials: `Positive number`, name-value, default: inf
%       Number of trials to use for reconstruction. Uses all data if `inf`.
%   - version:`Positive number`, name-value, default: 0
%       Question version number. Must be passed or in config.
%   - config_file: `character vector`, name-value, default: ``''``
%       A path to a YAML-spec configuration file. 
%       Can be `'none'` if passing other relevant arguments.
%   - survey: `logical`, name-value, default: `true`
%       Flag to run static/survey questions. If `false`, only sound
%       comarison is shown.
%   - stimgen: Any `StimulusGenerationMethod`, name-value, default: `[]`,
%       Stimgen object to use. `options.config` must be `'none'`. 
%   - recon: `numeric vector`, name-value, default: `[]`
%       Allows user to supply a specific reconstruction to use, 
%       rather than generating from config. 
%   - mult_range: `1 x 2 numerical vector, name-value, default: `[0, 1]`,
%       The min (1,1) and max (1,2) values for mult parameter.
%   - binrange_range: `1 x 2 numerical vector, name-value, default: `[1, 100]`,
%       The min (1,1) and max (1,2) values for binrange parameter.
%   - del_fig, `logical`, name-value, default: `true`,
%       Flag to delete figure at the end of the experiment.
%   - fig: `matlab.ui.Figure`, name-value.
%       Handle to open figure on which to display questions.
%   - save: `logical`, name-value, default: `true`.
%       Flag to save the `mult` and `binrange` outputs to a `.csv` file.
%   - verbose: `logical`, name-value, default: `true`
%       Flag to print information and warnings. 
% 
% **OUTPUTS:**
% 
%   - mult: `1 x 1` scalar, the last selected value for this parameter.
%   - binrange: `1 x 1` scalar, the last selected value for this parameter.
%   - mult_binrange_XXX.csv: csv file, where XXX is the config hash.
%       In the data directory. ONLY IF `save` param is `true`.
% 
% See also:
% AbstractBinnedStimulusGenerationMethod.binnedrepr2wav

function [mult, binrange, lowcf, highcf] = adjust_resynth(cal_dB, mult, binrange, lowcf, highcf, options)
    arguments
        cal_dB (1,1) {mustBeReal}
        mult (1,1) {mustBePositive} = 0.001
        binrange (1,1) {mustBeGreaterThanOrEqual(binrange,1), ...
        mustBeLessThanOrEqual(binrange,100)} = 60
        lowcf (1,1) {mustBeGreaterThanOrEqual(lowcf,0)} = 0
        highcf (1,1) {mustBePositive} = 13000
        options.fig matlab.ui.Figure
        options.data_dir char = ''
        options.this_hash char = ''
        options.target_sound (:,1) {mustBeNumeric} = []
        options.target_fs {mustBeNonnegative} = 0
        options.n_trials (1,1) {mustBePositive} = inf
        options.config_file (1,:) char = ''
        options.stimgen = []
        options.recon (:,1) {mustBeNumeric} = []
        options.mult_range (1,2) = [0, 1]
        options.binrange_range (1,2) = [1, 100]
        options.filter (1,1) logical = false
        options.save (1,1) logical = true
        options.verbose (1,1) logical = true
        options.del_fig (1,1) logical = true
    end

    %% Unpack options
    mult_min = options.mult_range(1,1);
    mult_max = options.mult_range(1,2);
    range_min = options.binrange_range(1,1);
    range_max = options.binrange_range(1,2);

    %% Input handling

    % If no config file path is provided,
    % open a UI to load the config
    if ~strcmp(options.config_file,'none')
        [config, ~] = parse_config(options.config_file);
    end

    if ~strcmp(options.config_file,'none') && isempty(options.data_dir)
        data_dir = config.data_dir;
    else
        data_dir = options.data_dir;
    end

    % Hash config if necessary
    if ~strcmp(options.config_file,'none') && isempty(options.this_hash)
        options.this_hash = get_hash(config);
    end

    % n_trials can't be more than total data
    if isempty(options.recon)
        total_trials_done = 0;
        d = dir(pathlib.join(data_dir, ['responses_', options.this_hash, '*.csv']));
        for ii = 1:length(d)
            responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
            total_trials_done = total_trials_done + length(responses);
        end

        if options.n_trials > total_trials_done
            options.n_trials = inf;
        end
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

    % Calculate gain to play at 65 dB.
    gain = 10^((65-cal_dB)/20);

    % Rescale to 65 dB.
    options.target_sound = gain*(options.target_sound ./ rms(options.target_sound));

    % Create stimgen obj
    if ~strcmp(options.config_file,'none')
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    else
        stimgen = options.stimgen;
    end
    Fs = stimgen.get_fs();
    highcf = stimgen.max_freq;
    
    %% Make reconstructions
    if ~isempty(options.recon)
        reconstruction = options.recon;
    else
        reconstruction = get_reconstruction('config', config, 'method', 'linear', ...
            'use_n_trials', options.n_trials, 'data_dir', data_dir);
    end

    %% Show figure

    % Useful vars
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    sld_w = 300;
    sld_h = 100;
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
    clf(hFig)

    %% Fig contents
    % Sliders
    sld_mult = uicontrol(hFig, 'Style', 'slider', ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(sld_h/2), sld_w, sld_h], ...
        'min', mult_min, 'max', mult_max, ...
        'Value', mult, 'Callback', @getValue);

    sld_range = uicontrol(hFig, 'Style', 'slider', ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(1.5*sld_h), sld_w, sld_h], ...
        'min', range_min, 'max', range_max, ...
        'Value', binrange, 'Callback', @getValue);

    if options.filter
        sld_lowcf = uicontrol(hFig, 'Style', 'slider', ...
            'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(2.5*sld_h), sld_w, sld_h], ...
            'min', 0, 'max', stimgen.max_freq/2, ...
            'Value', lowcf, 'Callback', @getValue);

        sld_highcf = uicontrol(hFig, 'Style', 'slider', ...
            'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)-(3.5*sld_h), sld_w, sld_h], ...
            'min', (stimgen.max_freq/2) + 1, 'max', stimgen.max_freq, ...
            'Value', highcf, 'Callback', @getValue);

        btn_bottom = 160;
    else
        btn_bottom = 350;
    end

    % Two buttons
    play_btn = uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)-(sld_w/2), btn_bottom, btn_w, btn_h], ...
        'String', 'Play Sounds', 'Callback', @playSounds);

    confirm_btn = uicontrol(hFig,'Style','pushbutton', ...
        'position', [(screenWidth/2)+(sld_w/2)-btn_w, btn_bottom, btn_w, btn_h], ...
        'String', 'Save Choice', 'Callback', {@saveRequest hFig});

    % Instructions
    uicontrol(hFig, 'Style', 'text', 'String', ['Adjust both sliders together or ' ...
        'separately and press "Play Sounds" to hear the effect on your reconstruction. ' ...
        'Choose "Save Choice" when you are satisfied.'], ...
        'Position', [(screenWidth/2)-(sld_w/2), (screenHeight/2)+(sld_h), sld_w, sld_h], ... 
        'FontSize', 16, 'HorizontalAlignment', 'left')

    uiwait(hFig);

    if options.save
        if options.filter
            param_table = table(mult,binrange,lowcf,highcf,'VariableNames',["mult","binrange","lowcutoff","highcutoff"]);
        else
            param_table = table(mult,binrange,'VariableNames',["mult","binrange"]);
        end
        writetable(param_table, fullfile(data_dir, ['resynth_params_',options.this_hash, '.csv']));
    end

    if options.del_fig
        delete(hFig)
    end

    %% Nested functions
    function getValue(~,~)
        mult = sld_mult.Value;
        binrange = sld_range.Value;
        if options.filter
            lowcf = sld_lowcf.Value;
            highcf = sld_highcf.Value;
        end
    end % getValue
    
    function playSounds(~, ~)
        if ~isempty(options.target_sound)
            sound(options.target_sound, options.target_fs, 24);
            pause(length(options.target_sound) / options.target_fs + 0.3);
        end
        % Generate recon with new settings
        recon_wav = stimgen.binnedrepr2wav(reconstruction, mult, binrange, ...
                                            'filter', options.filter, ...
                                            'cutoff', [lowcf, highcf]);
        % Rescale dB level 
        recon_wav = gain*(recon_wav ./ rms(recon_wav)); 
        sound(recon_wav, Fs, 24);
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

function saveRequest(~,~,hFig)
    ButtonName = questdlg(['Do you wish to ' ...
        'confirm your choices?'],...
        'Confirm', ...
        'Yes', 'No', 'No');
    switch ButtonName
        case 'Yes'
            uiresume(hFig);
        case 'No'
            return
    end
end % saveRequest
