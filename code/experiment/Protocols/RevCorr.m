%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ### RevCorr
% 
% Reverse Correlation Protocol for Cognitive Representations of Tinnitus
% This function runs the main experimental procedure of this project.
% 
% ```matlab
%   RevCorr(cal_dB) 
%   RevCorr(cal_dB, 'config', 'path2config')
%   RevCorr(cal_dB, 'verbose', false, 'fig', gcf)
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
%   - fig, `matlab.ui.Figure`, name-value.
%       Handle to figure window in which to display instructions
%       Function will create a new figure if none is supplied.
% 
% **OUTPUTS:**
% 
%   - Two `CSV` files (`responses` and `stimuli`) saved to `config.data_dir`.

function RevCorr(cal_dB, options)

    arguments
        cal_dB (1,1) {mustBeReal}
        options.presentation_dB_ (1,1) {mustBeReal} = 65
        options.config_file (1,:) char = ''
        options.verbose (1,1) {mustBeNumericOrLogical} = true
        options.fig matlab.ui.Figure
    end

    assert(cal_dB > options.presentation_dB_, ...
        ['cal_dB must be greater than ', num2str(options.presentation_dB_), ' dB.'])

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

    % Add additional config fields here
    config.n_trials = config.n_trials_per_block;
 
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
    gain = 10^((options.presentation_dB_-cal_dB)/20); % Amplitude value such that presentation level is 65dB
    
    % Determine the stimulus generation function
    if isfield(config, 'stimuli_type') && ~isempty(config.stimuli_type)
        % There is a weird feature/bug where putting `stimuli_type: white`
        % in the config file returns a 256x3 matrix of ones.
        if strcmpi(config.stimuli_type,'white')
            config.stimuli_type = "UniformNoiseNoBins";
        end
    else
        % Default to 'custom' stimulus generation
        config.stimuli_type = "GaussianPrior";
    end

    % Determine if the protocol should be 2-AFC
    if isfield(config, 'two_afc') && ~isempty(config.two_afc)
        is_two_afc = config.two_afc;
    else
        is_two_afc = false;
    end
    
    % Generate the experiment ID
    expID = get_experiment_ID(config);
    
    % Instantiate the stimulus generation object
    stimuli_object = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimuli_object = stimuli_object.from_config(config);
    
    % Compute the total trials done
    total_trials_done = get_total_trials_done(config, config_hash);
    corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])

    if total_trials_done >= config.n_trials_per_block * config.n_blocks
        corelib.verb(options.verbose, 'INFO RevCorr', ['Number of trials completed: ', num2str(total_trials_done), ...
            ' equals or exceeds total specified in config: ', num2str(config.n_trials_per_block * config.n_blocks) '. Exiting...'])
        return
    end

    % Is this an A-X experiment protocol?
    %   If it's an A-X experiment protocol,
    %   then we should play a target sound before each stimulus
    %   for each trial.
    %   Whether we are doing an A-X protocol or an X protocol
    %   is determined by the config file.
    if isfield(config, 'target_signal_filepath') && ~isempty(config.target_signal_filepath)
        % Load the sound file.
        [target_sound, target_fs] = audioread(config.target_signal_filepath);
    else
        target_sound = [];
        target_fs = 0;
    end

    if isfield(config, 'bin_target_signal') && config.bin_target_signal
        % Convert the target signal to bin-representation and back
        assert(isa(stimuli_object, 'AbstractBinnedStimulusGenerationMethod'), 'If bin_target_signal is true, then stimuli_object must be an AbstractBinnedStimulusGenerationMethod')
        target_sound = stimuli_object.bin_signal(target_sound, target_fs);
    end

    % Truncate target sound to 500 ms if it's longer
    if length(target_sound) > floor(0.5 * target_fs)
        target_sound = target_sound(1:floor(0.5 * target_fs));
    end

    %% Load Presentations Screens
    if is_two_afc
        Screen1 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide1D.png'));
        Screen2 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide2D.png'));
    else
        Screen1 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide1C.png'));
        Screen2 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide2C.png'));
    end
    Screen3 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide3C.png'));
    Screen4 = imread(pathlib.join(project_dir, 'experiment', 'fixationscreen', 'Slide4.png'));
    
    %% Generate initial files and stimuli

    if is_two_afc
        [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, ~, ~, filename_meta, ~, ~, this_hash] = create_files_and_stimuli_2afc(config, stimuli_object, hash_prefix);
        stimuli_matrix_1 = gain*(stimuli_matrix_1 ./ rms(stimuli_matrix_1)); % Set dB of stimuli
        stimuli_matrix_2 = gain*(stimuli_matrix_2 ./ rms(stimuli_matrix_2)); % Set dB of stimuli
        if any(min([stimuli_matrix_1, stimuli_matrix_2]) < -1) || any(max([stimuli_matrix_1, stimuli_matrix_1]) > 1)
            warning('Sound is clipping. Recalibrate dB level.')
            return
        end
    else
        [stimuli_matrix, Fs, filename_responses, ~, filename_meta, this_hash] = create_files_and_stimuli(config, stimuli_object, hash_prefix);
        stimuli_matrix = gain*(stimuli_matrix ./ rms(stimuli_matrix)); % Set dB of stimuli
        if any(min(stimuli_matrix) < -1) || any(max(stimuli_matrix) > 1)
            warning('Sound is clipping. Recalibrate dB level.')
            return
        end
    end

    fid_responses = fopen(filename_responses, 'w');

    %% Adjust target audio volume
    target_sound_scaled = gain*(target_sound ./ rms(target_sound));

    if ~isempty(target_sound) && isfield(config, 'target_signal_name') && contains(config.target_signal_name,'resynth')
        if is_two_afc
            scale_factor = adjust_volume(target_sound_scaled, target_fs, stimuli_matrix_1(:,1), Fs);
        else
            scale_factor = adjust_volume(target_sound_scaled, target_fs, stimuli_matrix(:,1), Fs);
        end
    end
    
    %% Intro Screen & Start

    % Show the startup screen
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
    clf(hFig);

    disp_fullscreen(Screen1);

    % Press "F" to start
    k = waitforkeypress();
    if k < 0
        corelib.verb(options.verbose, 'INFO RevCorr', 'Exiting...')
        corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
        return
    end
    value = double(get(gcf,'CurrentCharacter')); % f - 102

    % Check the value, if "F" then continue
    while (value ~= 102)
        k = waitforkeypress();
        if k < 0
            corelib.verb(options.verbose, 'INFO RevCorr', 'Exiting...')
            corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
            return
        end
        value = double(get(gcf,'CurrentCharacter'));
    end

    %% Run Trials

    counter = 0;
    while (1)
        counter = counter + 1;

        % Reminder Screen
        disp_fullscreen(Screen2);

        % Present Target (if A-X protocol)
        if ~isempty(target_sound)
            if isfield(config, 'target_signal_name') && contains(config.target_signal_name,'resynth')
                sound(target_sound_scaled*scale_factor,target_fs,24)
            else
                sound(target_sound_scaled,target_fs,24)
            end
            pause(length(target_sound) / target_fs + 0.3) % 300ms pause between target and stimulus
        end

        % Present Stimulus
        if is_two_afc
            present_2afc_stimulus(stimuli_matrix_1, stimuli_matrix_2, counter, Fs);
        else
            present_stimulus(stimuli_matrix, counter, Fs);
        end
            
        % Obtain Response
        k = waitforkeypress();
        if k < 0
            corelib.verb(options.verbose, 'INFO RevCorr', 'Exiting...')
            corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
            return
        end
        value = double(get(gcf,'CurrentCharacter')); % f - 102, j - 106
        while isempty(value) || (value ~= 102) && (value ~= 106)
            k = waitforkeypress();
            if k < 0
                corelib.verb(options.verbose, 'INFO RevCorr', 'Exiting...')
                corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
                return
            end
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

        % Write the response to file
        fprintf(fid_responses, [num2str(respnum) '\n']);

        % Update the number of trials done in this block
        total_trials_done = total_trials_done + 1;

        % Write the meta file
        meta = {expID, this_hash, this_datetime, total_trials_done};
        meta_labels = {'expID', 'hash', 'datetime', 'total_trials_done'};
        writetable(cell2table(meta, 'VariableNames', meta_labels), filename_meta);
            
        % Decide How To Continue
        if total_trials_done >= config.n_trials_per_block * config.n_blocks
            fclose(fid_responses);
            % end, all trials complete
            corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
            if isfield(config, 'follow_up') && config.follow_up
                if isfield(config, 'mult_range') && ~isempty(config.mult_range)
                    mult_range = config.mult_range;
                else
                    mult_range = [0,0.1];
                end

                [mult, binrange] = adjust_resynth(cal_dB, 'config_file', config_path, ...
                    'data_dir', config.data_dir, 'this_hash', hash_prefix, ...
                    'target_sound', target_sound, 'target_fs', target_fs, ...
                    'fig', hFig, 'mult_range', mult_range, 'del_fig', false, 'verbose', false, ...
                    'presentation_dB_', options.presentation_dB_);
                
                follow_up(cal_dB, 'config_file', config_path, ...
                    'data_dir', config.data_dir, 'this_hash', hash_prefix, ...
                    'target_sound', target_sound, 'target_fs', target_fs, ...
                    'mult', mult, 'binrange', binrange, ...
                    'fig', hFig, 'verbose', false, 'survey', config.follow_up_survey, ...
                    'presentation_dB_', options.presentation_dB_);
            else
                disp_fullscreen(Screen4);
            end
            return
        elseif mod(total_trials_done, config.n_trials_per_block) == 0 % give rest before proceeding to next block
            fclose(fid_responses);

            % reset counter
            counter = 0;
            disp_fullscreen(Screen3);
            corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
            k = waitforkeypress();
            if k < 0
                corelib.verb(options.verbose, 'INFO RevCorr', 'Exiting...')
                corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
                return
            end
            value = double(get(gcf,'CurrentCharacter')); % f - 102
            while (value ~= 102)
                k = waitforkeypress();
                if k < 0
                    corelib.verb(options.verbose, 'INFO RevCorr', 'Exiting...')
                    corelib.verb(options.verbose, 'INFO RevCorr', ['# of trials completed: ', num2str(total_trials_done)])
                    return
                end
                value = double(get(gcf,'CurrentCharacter'));
            end

            % Generate new stimuli and files
            if is_two_afc
                [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, ~, ~, filename_meta, ~, ~, this_hash] = create_files_and_stimuli_2afc(config, stimuli_object, hash_prefix);
                stimuli_matrix_1 = gain*(stimuli_matrix_1 ./ rms(stimuli_matrix_1)); % Set dB of stimuli
                stimuli_matrix_2 = gain*(stimuli_matrix_2 ./ rms(stimuli_matrix_2)); % Set dB of stimuli
                if any(min([stimuli_matrix_1, stimuli_matrix_2]) < -1) || any(max([stimuli_matrix_1, stimuli_matrix_1]) > 1)
                    warning('Sound is clipping. Recalibrate dB level.')
                    return
                end
            else
                [stimuli_matrix, Fs, filename_responses, ~, filename_meta, this_hash] = create_files_and_stimuli(config, stimuli_object, hash_prefix);
                stimuli_matrix = gain*(stimuli_matrix ./ rms(stimuli_matrix)); % Set dB of stimuli
                if any(min(stimuli_matrix) < -1) || any(max(stimuli_matrix) > 1)
                    warning('Sound is clipping. Recalibrate dB level.')
                    return
                end
            end
            fid_responses = fopen(filename_responses, 'w');

        else % continue with block
            % Pause before playing next stimuli  
            if is_two_afc
                pause(length(stimuli_matrix_1(:,counter)) / Fs - 0.3)
            else
                pause(length(stimuli_matrix(:,counter)) / Fs - 0.3)
            end
        end
        
    end

    function closeRequest(~,~,hFig)
        percent_done = 100*(total_trials_done / (config.n_trials_per_block * config.n_blocks)); 

        ButtonName = questdlg(['You have done ', ...
            num2str(total_trials_done), ' trials of ', ...
            num2str(config.n_trials_per_block * config.n_blocks), ...
            ' (', num2str(percent_done), '%). ', ...
            'End the experiment?'],...
            'Confirm Close', ...
            'Yes', 'No', 'No');
        switch ButtonName
            case 'Yes'
                delete(hFig);
            case 'No'
                return
        end
    end % closeRequest
    
end % function

function present_stimulus(stimuli_matrix, counter, Fs)
    % Play the correct stimulus to the subject.
    sound(stimuli_matrix(:, counter), Fs, 24)
    pause(length(stimuli_matrix(:, counter)) / Fs)
end % function

function present_2afc_stimulus(stimuli_matrix_1, stimuli_matrix_2, counter, Fs, pause_duration)
    % Play the correct (first) stimulus to the subject.
    % Pause, then play the second stimulus.

    if nargin < 5
        pause_duration = 0.3;
    end

    sound(stimuli_matrix_1(:, counter), Fs, 24);
    pause(length(stimuli_matrix_1(:, counter)) / Fs + pause_duration);
    sound(stimuli_matrix_2(:, counter), Fs, 24);
end % function

function total_trials_done = get_total_trials_done(config, config_hash)
    % Compute the total trials completed.

    arguments
        config (1,1) struct
        config_hash (1,:) char
    end

    total_trials_done = 0;
    d = dir(pathlib.join(config.data_dir, ['responses_', config_hash, '*.csv']));

    for ii = 1:length(d)
        responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
        total_trials_done = total_trials_done + length(responses);
    end

end
