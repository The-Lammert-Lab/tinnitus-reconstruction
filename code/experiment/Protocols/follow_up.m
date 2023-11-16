% ### follow_up
% 
% Runs the follow up protocol to ask exit survey and subjective 
% reconstruction assessment questions.
% Questions are included in code/experiment/fixationscreens/FollowUp_vX,
% where X is the version number.
% Computes standard linear reconstruction, 
% peak-sharpened linear reconstruction,
% and generates config-informed white noise for comparison against target
% sound. Responses are saved in the specified data directory. 
% 
% **ARGUMENTS:**
% 
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
%   - mult: `Positive number`, name-value, default: 0.01
%       The peak-sharpening `mult` parameter.
%   - binrange: `Positive number`, name-value, default: 60,
%       must be between [1, 100], the upper bound of the [0, binrange]
%       dynamic range of the peak-sharpened reconstruction.
%   - version:`Positive number`, name-value, default: 0
%       Question version number. Must be passed or in config.
%   - config_file: `character vector`, name-value, default: ``''``
%       A path to a YAML-spec configuration file.
%   - survey: `logical`, name-value, default: `true`
%       Flag to run static/survey questions. If `false`, only sound
%       comarison is shown.
%   - recon: `numeric vector`, name-value, default: `[]`
%       Allows user to supply a specific reconstruction to use, 
%       rather than generating from config. 
%   - fig: `matlab.ui.Figure`, name-value.
%       Handle to open figure on which to display questions.
%   - verbose: `logical`, name-value, default: `true`
%       Flag to print information and warnings. 
% 
% **OUTPUTS:**
% 
%   - survey_XXX.csv: csv file, where XXX is the config hash.
%       In the data directory. 

function follow_up(options)

    arguments
        options.data_dir char = ''
        options.project_dir char = ''
        options.this_hash char = ''
        options.target_sound (:,1) {mustBeNumeric} = []
        options.target_fs {mustBeNonnegative} = 0
        options.n_trials (1,1) {mustBePositive} = inf
        options.version (1,1) = 0
        options.config_file (1,:) char = ''
        options.mult (1,1) {mustBeReal} = 0.01
        options.binrange (1,1) {mustBeReal} = 60
        options.filter (1,1) logical = false
        options.cutoff_freqs (1,2) {mustBeReal} = []
        options.recon (:,1) {mustBeNumeric} = []
        options.survey (1,1) logical = true
        options.verbose (1,1) logical = true
        options.fig matlab.ui.Figure
    end

    %% Input handling
    % If not called from Protocol, get path to use for loading images.
    if isempty(options.project_dir)
        project_dir = pathlib.strip(mfilename('fullpath'), 2);
    end

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
    if isempty(options.recon)
        total_trials_done = 0;
        dir_responses = dir(pathlib.join(data_dir, ['responses_', options.this_hash, '*.csv']));
        for ii = 1:length(dir_responses)
            responses = readmatrix(pathlib.join(dir_responses(ii).folder, dir_responses(ii).name));
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

    % Use supplied version or take from config if not supplied.  
    if options.version < 1 && isfield(config, 'follow_up_version') && ~isempty(config.follow_up_version)
        options.version = config.follow_up_version;
    elseif options.version < 1
        error('No version supplied and no version available in config.')
    end

    %% Sound Comparison Setup
    if options.version == 1
        n_sounds = 2;
    else
        n_sounds = 3;
    end

    % Container for non-target sounds.
    comparison = cell(n_sounds,2);

    % Generate reconstruction
    if ~isempty(options.recon)
        reconstruction = options.recon;
    else
        reconstruction = get_reconstruction('config', config, 'method', 'linear', ...
            'use_n_trials', options.n_trials, 'data_dir', data_dir);
    end

    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);

    % (since using one stimgen, recon and noise share fs).
    Fs = stimgen.Fs;

    % Make unadjusted (standard) waveform from reconstruction
    recon_binrep = rescale(reconstruction, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);
 
    % Create frequency vector 
    freqs = linspace(1, floor(Fs/2), length(recon_spectrum))' - 1; 

    recon_spectrum(freqs > config.max_freq & freqs < config.min_freq) = stimgen.unfilled_dB;
    recon_waveform_standard = stimgen.synthesize_audio(recon_spectrum, stimgen.nfft);

    % Make adjusted (peak sharpened, etc.) waveform from reconstruction
    recon_waveform_adjusted = stimgen.binnedrepr2wav(reconstruction,options.mult,options.binrange, ...
        'filter',options.filter,'cutoff',options.cutoff_freqs);

    % Generate white noise
    noise_waveform = stimgen.white_noise();

    %% Load Screens
    % Load Protocol completion/follow up intro screen
    img_dir = pathlib.join(project_dir, 'experiment', 'fixationscreen', ...
        ['FollowUp_v', num2str(options.version)]);

    intro_screen = imread(pathlib.join(img_dir, 'FollowUp_intro.png'));
    final_screen = imread(pathlib.join(img_dir, 'FollowUp_end.png'));

    % Question screens
    if options.survey
        if isempty(options.target_sound)
            d = dir(pathlib.join(img_dir, '*Q*_patient.png'));
        else
            d = dir(pathlib.join(img_dir, '*Q*_healthy.png'));
        end
        
        static_qs = cell(length(d),1);
        
        for i = 1:length(static_qs)
            static_qs{i} = imread(pathlib.join(img_dir, d(i).name));
        end
    end
    
    % Sound screens
    sound_screens = cell(n_sounds,1);
    
    for i = 1:n_sounds
        if isempty(options.target_sound)
            sound_screens{i} = imread(pathlib.join(img_dir,['FollowUp_compare_tinnitus', num2str(i), '.png']));
        else
            sound_screens{i} = imread(pathlib.join(img_dir,['FollowUp_compare', num2str(i), '.png']));
        end
    end

    %% Response file
    % Set up response file
    filename_survey = pathlib.join(data_dir, ['survey_', options.this_hash, '.csv']);
    fid_survey = fopen(filename_survey, 'w');

    % Version 1 has a different save configuration than future versions.
    if options.version == 1
        % Set order for qualitative sound assessment.
        order = randi(1:n_sounds);
    
        % Write follow up question version and order of presented stimuli
        fprintf(fid_survey, ['v_', num2str(options.version), '\n']);
        fprintf(fid_survey, ['o_', num2str(order), '\n']);    
    
        % Set order and write to file for clarity
        switch order
            case 1
                comparison{1,1} = recon_waveform_standard;
                comparison{2,1} = noise_waveform;
                fprintf(fid_survey, 'recon-noise\n');
            case 2
                comparison{1,1} = noise_waveform;
                comparison{2,1} = recon_waveform_standard;
                fprintf(fid_survey, 'noise-recon\n');
        end
    else
        if options.survey
            % Auto-fill static question headers
            % Either "QX," or "QXX,"
            if length(static_qs) < 10
                inds = 1:3:(3*length(static_qs))+1;
                staticqs_header = blanks(3*length(static_qs));
            else
                inds = [1:3:28, 32:4:33+(4*(length(static_qs)-10))];
                staticqs_header = blanks(4*(length(static_qs)-9)+27);
            end
    
            for i = 1:length(static_qs)
                staticqs_header(inds(i):inds(i+1)-1) = ['Q', num2str(i), ','];
            end
        else
            staticqs_header = '';
        end

        % Put sounds in a random order
        order = randperm(n_sounds);
        comparison{order(1),1} = noise_waveform;
        comparison{order(1),2} = 'whitenoise';
        comparison{order(2),1} = recon_waveform_standard;
        comparison{order(2),2} = 'recon_standard';
        comparison{order(3),1} = recon_waveform_adjusted;
        comparison{order(3),2} = 'recon_adjusted';

        % Write header
        fprintf(fid_survey, ['hash,','version,', ...
            'mult,','binrange,', staticqs_header, ...
            comparison{1,2},',',comparison{2,2},',',comparison{3,2},'\n']);

        % Write config hash, version, mult, and binrange params to file.
        fprintf(fid_survey, [options.this_hash,',',num2str(options.version),',', ...
            num2str(options.mult),',',num2str(options.binrange),',']);
    end

    %% Figure
    % Open full screen figure if none provided or the provided was deleted
    if ~isfield(options, 'fig') || ~ishandle(options.fig)
        screenSize = get(0, 'ScreenSize');
        screenWidth = screenSize(3);
        screenHeight = screenSize(4);

        hFig = figure('Numbertitle','off',...
            'Position', [0 0 screenWidth screenHeight],...
            'Color',[0.5 0.5 0.5],...
            'Toolbar','none', ...
            'MenuBar','none');
    else
        hFig = options.fig;
    end
    hFig.CloseRequestFcn = {@closeRequest hFig};

    %% Press 'F' to start
    disp_fullscreen(intro_screen)
    
    value = readkeypress(102, 'verbose', options.verbose); % f - 102
    if value < 0
        corelib.verb(options.verbose, 'INFO follow_up', 'Exiting...')
        return
    end

    %% Ask questions
    if options.survey
        % Static questions
        for i = 1:length(static_qs)
            disp_fullscreen(static_qs{i})
            value = readkeypress(49:53, 'verbose', options.verbose); % 1-5 = 49-53
            if value < 0
                corelib.verb(options.verbose, 'INFO follow_up', 'Exiting...')
                return
            end
    
            % Write the response to file
            if options.version == 1
                fprintf(fid_survey, [char(value), '\n']);
            else
                fprintf(fid_survey, [char(value), ',']);
            end
        end
    end

    % Sound assessment 
    for i = 1:length(sound_screens)
        % Wait for 'F' to play sound
        disp_fullscreen(sound_screens{i});
        value = readkeypress(102, 'verbose', options.verbose); % f - 102
        if value < 0
            corelib.verb(options.verbose, 'INFO follow_up', 'Exiting...')
            return
        end

        play_sounds(options.target_sound, options.target_fs, comparison{i,1}, Fs)

        % Get key press or repeat sounds
        while ~(value < 0)
            if options.version == 1
                value = readkeypress([49:53, 114], 'verbose', options.verbose); % r - 114
            else
                value = readkeypress([49:55, 114], 'verbose', options.verbose); % r - 114
            end
            if value == 114
                play_sounds(options.target_sound, options.target_fs, comparison{i,1}, Fs)
            else
                % Write response to file
                if options.version == 1
                    fprintf(fid_survey, [char(value), '\n']);
                else
                    if i < length(sound_screens)
                        fprintf(fid_survey, [char(value), ',']);
                    else
                        fprintf(fid_survey, char(value));
                    end
                end
                break
            end
        end

        if value < 0
            corelib.verb(options.verbose, 'INFO follow_up', 'Exiting...')
            return
        end
    end

    disp_fullscreen(final_screen);
    fclose(fid_survey);

end % function

function play_sounds(target_sound, target_fs, comp_sound, comp_fs)
    if ~isempty(target_sound)
        soundsc(target_sound, target_fs);
        pause(length(target_sound) / target_fs + 0.3);
    end
    soundsc(comp_sound, comp_fs);
end % function

function value = readkeypress(target, options)
    % Wait for a key press and return the value
    % only if the pressed key was in `target`. 

    arguments
        target {mustBeNumeric}
        options.verbose (1,1) {mustBeNumericOrLogical} = true
    end

    k = waitforkeypress(options.verbose);
    if k < 0
        value = -1;
        return
    end

    value = double(get(gcf,'CurrentCharacter'));
    while isempty(value) || ~any(ismember(target, value))
        k = waitforkeypress(options.verbose);
        if k < 0
            value = -1;
            return
        end
        value = double(get(gcf,'CurrentCharacter'));
    end

    return
end % function

function closeRequest(~,~,hFig)
    ButtonName = questdlg(['Do you wish not to ' ...
        'answer the follow up questions?'],...
        'Confirm Close', ...
        'Yes', 'No', 'No');
    switch ButtonName
        case 'Yes'
            delete(hFig);
        case 'No'
            return
    end
end % closeRequest
