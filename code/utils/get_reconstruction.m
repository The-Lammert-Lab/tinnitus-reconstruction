% ### get_reconstruction
% 
% Compute reconstructions using data specified
% by a configuration file.
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
%   
% 
% ```matlab
% [x, responses_output, stimuli_matrix_output] = get_reconstruction('key', value, ...)
% x = get_reconstruction('config_file', 'path_to_config', 'preprocessing', {'bit_flip'}, 'method', 'cs', 'verbose', true)
% ```
% 
% Compute the reconstruction, given the response vector and the stimuli matrix with a preprocessing step and a method chosen from {'cs', 'cs_nb', 'linear'}
% 
% See Also: 
% collect_reconstructions
% collect_data
% config2table

function [x, responses_output, stimuli_matrix_output] = get_reconstruction(options)

    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.preprocessing = {}
        options.method = 'cs'
        options.verbose (1,1) logical = true
        options.fraction (1,1) {mustBeReal, mustBeNonnegative} = 1.0
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
        % Try to set the gamma parameter from the config.
        if any(strcmp(fieldnames(config), 'gamma'))
            options.gamma = config.gamma;
            corelib.verb(options.verbose, 'INFO: get_reconstruction', ['gamma parameter set to ', num2str(options.gamma), ', based on config.']);
        elseif any(strcmp(fieldnames(config), 'n_bins'))
            % Try to set the gamma parameter based on the number of bins
            options.gamma = get_gamma(config.n_bins);
            corelib.verb(options.verbose, 'INFO: get_reconstruction', ['gamma parameter set to ', num2str(options.gamma), ', based on the number of bins.']);
        else
            % Set gamma based on a guess
            options.gamma = 32;
            corelib.verb(options.verbose, 'INFO: get_reconstruction', ['gamma parameter set to ', num2str(options.gamma), ', which is the default.']);
        end
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
    n_trials = round(options.fraction * length(stimuli_matrix(1, :)));

    responses_output = responses(1:n_trials);
    stimuli_matrix_output = stimuli_matrix(:, 1:n_trials);

    switch options.method
    case 'cs'
        x = cs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', options.gamma);
    case 'cs_nb'
        x = cs_no_basis(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)', options.gamma);
    case 'linear'
        x = gs(responses(1:n_trials), stimuli_matrix(:, 1:n_trials)');
    otherwise
        error('Unknown method')
    end

end % function