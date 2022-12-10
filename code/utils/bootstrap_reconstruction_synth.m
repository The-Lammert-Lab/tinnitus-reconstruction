% Runs the synthetic subject selection process N times
% and reconstructs each time.
function [r] = bootstrap_reconstruction_synth(options)
    
    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.method = 'linear' % or 'cs'
        options.verbose (1,1) logical = true
        options.gamma (1,1) {mustBeReal, mustBeNonnegative, mustBeInteger} = 0
        options.N (1,1) {mustBeReal, mustBeNonnegative, mustBeInteger} = 100
        options.strategy (1,:) {mustBeText} = 'synth' % or 'rand'
        options.legacy = false
        options.parallel = true
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
        options.gamma = get_gamma_from_config(config, options.verbose);
    else
        % Gamma set by user
        corelib.verb(options.verbose, 'INFO: get_reconstruction', ['gamma parameter set to ', num2str(options.gamma), ', as specified by the user.']);
    end

    assert(any(strcmp(options.strategy, {'synth', 'rand'})), 'options.strategy must be synth or rand')
    corelib.verb(options.verbose, 'INFO: bootstrap_reconstruction_synth', ['strategy is ', options.strategy])
    assert(any(strcmp(options.method, {'cs', 'linear'})), 'options.method must be cs or linear')
    corelib.verb(options.verbose, 'INFO: bootstrap_reconstruction_synth', ['method is ', options.method])

    % Create the stimulus generation object
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);

    % Load and preprocess the target signal
    [target_signal, ~] = wav2spect(config.target_signal_filepath);
    target_signal = 10 * log10(target_signal);
    binned_target_signal = stimgen.spect2binnedrepr(target_signal);

    % Run the synthetic subject selection process N times
    r = zeros(options.N, 1);
    if options.parallel
        parfor ii = 1:options.N
            if strcmp(options.strategy, 'synth')
                [responses, ~, stimuli_binned_repr] = stimgen.subject_selection_process(target_signal);
            elseif strcmp(options.strategy, 'rand')
                responses = sign(rand(options.N, 1) - 0.5);
                [~, ~, ~, stimuli_binned_repr] = stimgen.generate_stimuli_matrix();
            else
                error('not implemented')
            end

            % Compute the reconstruction
            if strcmp(options.method, 'cs')
                x = cs(responses, stimuli_binned_repr', options.gamma, 'verbose', true);
            elseif strcmp(options.method, 'linear')
                x = gs(responses, stimuli_binned_repr');
            else
                error('not implemented')
            end

            % Get the correlation for the reconstruction
            r(ii) = corr(x, binned_target_signal, 'Type', 'Pearson');
        end
    else
        for ii = 1:options.N
            if strcmp(options.strategy, 'synth')
                [responses, ~, stimuli_binned_repr] = stimgen.subject_selection_process(target_signal);
            elseif strcmp(options.strategy, 'rand')
                responses = sign(rand(options.N, 1) - 0.5);
                [~, ~, ~, stimuli_binned_repr] = stimgen.generate_stimuli_matrix();
            else
                error('not implemented')
            end

            % Compute the reconstruction
            if strcmp(options.method, 'cs')
                x = cs(responses, stimuli_binned_repr', options.gamma, 'verbose', true);
            elseif strcmp(options.method, 'linear')
                x = gs(responses, stimuli_binned_repr');
            else
                error('not implemented')
            end

            % Get the correlation for the reconstruction
            r(ii) = corr(x, binned_target_signal, 'Type', 'Pearson');

            corelib.verb(options.verbose, 'INFO: bootstrap_reconstruction_synth', ['(', num2str(ii), '/', num2str(options.N), ') completed with r = ', num2str(r(ii))])
        end
    end

end % function