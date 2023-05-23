% ### get_reconstruction
% 
% Compute reconstructions using data specified
% by a configuration file.
% 
% ```matlab
% [x, responses_output, stimuli_matrix_output] = get_reconstruction('key', value, ...)
% x = get_reconstruction('config_file', 'path_to_config', 'preprocessing', {'bit_flip'}, 'method', 'cs', 'verbose', true)
% ```
% 
% **ARGUMENTS:**
% 
%   - config_file: string or character array, name-value, default: ``''``
%       A path to a YAML-spec configuration file.
%       Either this argument or ``config`` is required.
%   - config: struct, name-value, default: ``[]``
%       A configuration file struct
%       (e.g., one created by ``parse_config``).
%   - preprocessing: cell array of character vectors, name-value, default: ``{}``
%       A list of preprocessing steps to take.
%       Currently, the only supported preprocessing step is ``'bit flip'``,
%       which flips the sign on all responses before computing the reconstruction.
%   - method: character vector, name-value, default: ``'cs'``
%       Which reconstruction algorithm to use. 
%       Options: ``'cs'``, ``'cs_nb'``, ``'linear'`, ``'linear_ridge'``.
%   - use_n_trials: Positive scalar, name-value, default: `inf`
%       Indicates how many trials to use of data. `inf` uses all data.
%   - bootstrap: Positive scalar, name-value, deafult: 0
%       Number of bootstrap iterations to perform.
% 
% 
% 
% See Also: 
% collect_reconstructions
% collect_data
% config2table

function [x, r_bootstrap, responses_output, stimuli_matrix_output] = get_reconstruction(options)

    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.preprocessing = {}
        options.method = 'cs'
        options.verbose (1,1) logical = true
        options.fraction (1,1) {mustBeReal, mustBeNonnegative} = 1.0
        options.use_n_trials (1,1) {mustBeReal, mustBePositive} = inf
        options.bootstrap (1,1) {mustBeInteger, mustBeNonnegative} = 0
        options.target (:,1) = []
        options.data_dir (1,:) char = ''
        options.legacy (1,1) {mustBeNumericOrLogical} = false
        options.gamma (1,1) {mustBeReal, mustBeNonnegative, mustBeInteger} = 0
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
    
    % collect the data from files
    [responses, stimuli_matrix] = collect_data('config', config, 'verbose', options.verbose, 'data_dir', char(options.data_dir));

    % bin preprocessing
    if strcmp(config.stimuli_save_type, 'bins') || any(contains(options.preprocessing, 'bins'))
        if size(stimuli_matrix, 1) > config.n_bins
            % stimuli are probably saved as waveforms
            % but should be in bins
            corelib.verb(options.verbose, 'INFO: get_reconstruction', 'bin preprocessing')
            stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
            stimgen = stimgen.from_config(config);

            if size(stimuli_matrix, 1) >= (config.duration * stimgen.Fs - 1)
                % likely saved as waveforms
                stimuli_matrix = signal2spect(stimuli_matrix); % waveform => spectrum
            end
            % keyboard
            stimuli_matrix = stimgen.spect2binnedrepr(stimuli_matrix); % spectrum => bin repr
        end
    end

    % bit flip preprocessing
    if contains(options.preprocessing, 'bit_flip')
        corelib.verb(options.verbose, 'INFO: get_reconstruction', 'bit flip preprocessing')
        responses = -1 * responses;
    end

    %% Reconstruction Step
    if ~isinf(options.use_n_trials) && options.use_n_trials <= length(stimuli_matrix) 
        conv_factor = options.use_n_trials / size(stimuli_matrix, 2);
        options.fraction = conv_factor * options.fraction;
    end

    n_trials = round(options.fraction * size(stimuli_matrix, 2));

    corelib.verb(options.verbose, 'INFO: get_reconstruction', ...
        ['Computing reconstructions using ' num2str(n_trials), ' trials.'])

    responses_output = responses(1:n_trials);
    stimuli_matrix_output = stimuli_matrix(:, 1:n_trials);
    
    if options.bootstrap
        % Truncate for readability
        responses_bs = responses(1:n_trials);
        stimuli_matrix_bs = stimuli_matrix(:, 1:n_trials);

        % Relevant variables
        n_samples = round(0.9*length(responses_bs));

        % Container for r values
        r_bootstrap = zeros(options.bootstrap, 1);

        % Bootstrap
        for i = 1:options.bootstrap
            ind = round((length(responses_bs)-1) * rand(n_samples, 1)) + 1;
            switch options.method
                case 'cs'
                    x = cs(responses_bs(ind), stimuli_matrix_bs(:, ind)', options.gamma, 'verbose', options.verbose);
                case 'cs_nb'
                    x = cs_no_basis(responses_bs(ind), stimuli_matrix_bs(:, ind)', options.gamma);
                case 'linear'
                    x = gs(responses_bs(ind), stimuli_matrix_bs(:, ind)');
                case 'linear_ridge'
                    x = gs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', 'ridge', true);
                otherwise
                    error('Unknown method')
            end
            r_bootstrap(i) = corr(x, options.target);
        end
    else
        r_bootstrap = [];
    end

    switch options.method
        case 'cs'
            x = cs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', options.gamma, 'verbose', options.verbose);
        case 'cs_nb'
            x = cs_no_basis(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', options.gamma);
        case 'linear'
            x = gs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)');
        case 'linear_ridge'
            x = gs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', 'ridge', true);
        otherwise
            error('Unknown method')
    end

end % function