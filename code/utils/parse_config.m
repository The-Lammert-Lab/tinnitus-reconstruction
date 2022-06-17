function config = parse_config(config_file, verbose)
    % Read a config file and perform any special parsing that is required.
    %
    % Arguments:
    % 
    %   config_file: character vector, default: []
    %       Path to the config file to be used.
    %       If empty, opens a GUI to find the file using a file browser.
    % 
    % Outputs:
    %
    %   config: struct
    % 
    % See Also: ReadYaml
    % 

    arguments
        config_file (1,:)
        verbose (1,1) {mustBeNumericOrLogical} = true
    end

    % Load the config file
    if isempty(config_file)
        [file, abs_path] = uigetfile('*.yaml');
        config = ReadYaml(pathlib.join(abs_path, file));
    else
        config = ReadYaml(config_file);
    end

    % Check for required config options
    required_fields = {'stimuli_type', 'n_trials_per_block', 'n_blocks', 'subjectID'};
    for ii = 1:length(required_fields)
        assert(isfield(config, required_fields{ii}), ['required_field: ', required_fields{ii}]);
    end

    %% Perform specific parsing of config options
    stimuli_types = {'Bernoulli', 'Brimijoin', 'GaussianNoise', 'GaussianNoiseNoBins', ...
                    'GaussianPrior', 'UniformNoise', 'UniformNoiseNoBins', 'UniformPrior', ...
                    'PowerDistribution'};
    stimuli_string = [stimuli_types(:), repmat({', '}, length(stimuli_types), 1)]';
    stimuli_string = [stimuli_string{:}];
    assert(any(strcmp(config.stimuli_type, stimuli_types)), ...
        ['Unknown stimuli type: ' config.stimuli_type, '. Allowed values are: ', stimuli_string(1:end-2)], '.');

    % data_dir
    if ~isfield(config, 'data_dir') || isempty(config.data_dir)
        project_dir = pathlib.strip(mfilename('fullpath'), 3);
        data_dir = pathlib.join(project_dir, 'code', 'experiment', 'Data');
        corelib.verb(verbose, 'INFO: parse_config', ['data_dir is empty, filling with: ', data_dir])
        config.data_dir = data_dir;
    end

    % stimuli_save_type
    if ~isfield(config, 'stimuli_save_type') || isempty(config.stimuli_save_type)
        config.stimuli_save_type = 'waveform';
        corelib.verb(verbose, 'WARN: parse_config', 'stimuli_save_type is empty, filling with: waveform.')
    end
    assert(any(strcmp(config.stimuli_save_type, {'bins', 'waveform', 'spectrum'})), ...
        ['Unknown stimuli save type: ', config.stimuli_save_type, '. Allowed values are: [bins, waveform, spectrum].'])


end % function

