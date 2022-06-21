function [x, responses_output, stimuli_matrix_output] = get_reconstruction(options)

    %
    %   [x, responses_output, stimuli_matrix_output] = get_reconstruction('key', value, ...)
    % 
    %   x = get_reconstruction('config', 'path_to_config', 'preprocessing', {'bit_flip'}, 'method', 'cs', 'verbose', true)
    % 
    % Compute the reconstruction, given the response vector
    % and the stimuli matrix
    % with a preprocessing step
    % and a method chosen from {'cs', 'cs_nb', 'linear'}
    % 
    % See Also: collect_reconstructions, collect_data

    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.preprocessing = {}
        options.method = 'cs'
        options.verbose (1,1) logical = true
        options.fraction (1,1) {mustBeReal, mustBeNonnegative} = 1.0
    end

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        [file, abs_path] = uigetfile();
        config = parse_config(pathlib.join(abs_path, file), options.verbose);
        corelib.verb(options.verbose, 'INFO: get_reconstruction', ['config file [', file, '] loaded from GUI'])
    elseif isempty(options.config)
        config = parse_config(options.config_file, options.verbose);
        corelib.verb(options.verbose, 'INFO: get_reconstruction', 'config object loaded from provided file [', options.config_file, ']')
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: get_reconstruction', 'config object provided')
    end

    % collect the data from files
    [responses, stimuli_matrix] = collect_data('config', config, 'verbose', options.verbose);

    % bin preprocessing
    if any(contains(options.preprocessing, 'bins')) || strcmp(config.stimuli_save_type, 'bins') && ...
            size(stimuli_matrix, 1) > config.n_bins
        % stimuli are probably saved as waveforms
        % but should be in bins
        corelib.verb(options.verbose, 'INFO: get_reconstruction', 'bin preprocessing')
        stimgen = eval([config.stimuli_type, 'StimulusGeneration()']);
        stimgen.from_config(config);
        stimuli_matrix = signal2spect(stimuli_matrix); % waveform => spectrum
        stimuli_matrix = stimgen.spect2binnedrepr(stimuli_matrix); % spectrum => bin repr
    end

    % bit flip preprocessing
    if contains(options.preprocessing, 'bit flip')
        corelib.verb(options.verbose, 'INFO: get_reconstruction', 'bit flip preprocessing')
        responses = -1 * responses;
    end

    %% Reconstruction Step
    n_trials = round(options.fraction * length(stimuli_matrix(1, :)));

    responses_output = responses(1:n_trials);
    stimuli_matrix_output = stimuli_matrix(:, 1:n_trials);

    switch options.method
    case 'cs'
        x = cs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)');
    case 'cs_nb'
        x = cs_no_basis(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)');
    case 'linear'
        x = gs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)');
    otherwise
        error('Unknown method')
    end

end % function