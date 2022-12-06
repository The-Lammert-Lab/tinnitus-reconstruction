% Runs the synthetic subject selection process N times
% and reconstructs each time.
function bootstrap_reconstruction_synth(options)
    
    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.method = 'cs'
        options.verbose (1,1) logical = true
        options.target (:,1) = []
        options.gamma (1,1) {mustBeReal, mustBeNonnegative, mustBeInteger} = 0
        options.N (1,1) {mustBeReal, mustBeNonnegative, mustBeInteger} = 100
    end

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        [file, abs_path] = uigetfile();
        config = parse_config(pathlib.join(abs_path, file), options.legacy, options.verbose);
        corelib.verb(options.verbose, 'INFO: get_reconstruction', ['config file [', file, '] loaded from GUI'])
    elseif isempty(options.config)
        config = parse_config(options.config_file, options.legacy, options.verbose);
        corelib.verb(options.verbose, 'INFO: get_reconstruction', ['config object loaded from provided file [', char(options.config_file), ']'])
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: get_reconstruction', 'config object provided')
    end
    
    % Set the gamma parameter if not set
    if options.gamma == 0
        options.gamma = get_gamma_from_config(options.config, options.verbose);
    else
        % Gamma set by user
        corelib.verb(options.verbose, 'INFO: get_reconstruction', ['gamma parameter set to ', num2str(options.gamma), ', as specified by the user.']);
    end

    % Create the stimulus generation object
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);

    % Run the synthetic subject selection process N times
    r = zeros(N, 1);
    for ii = 1:N
        responses = stimgen.subject_selection_process(target_signal);
        
        switch options.method
        case 'cs'
            x = cs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', options.gamma, 'verbose', options.verbose);
        case 'cs_nb'
            x = cs_no_basis(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', options.gamma);
        case 'linear'
            x = gs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)');
        otherwise
            error('Unknown method')
        end 
    end