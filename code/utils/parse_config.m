% ### parse_config 
% 
% Read a config file and perform any special parsing that is required.
% 
% **ARGUMENTS:**
% 
%     config_file: character vector, default: []
%         Path to the config file to be used.
%         If empty, opens a GUI to find the file using a file browser.
% 
% **OUTPUTS:**
% 
%     varargout: `1 x 2` cell array:
%         varargout{1} = config: `struct`, the parsed config file.
%         varargout{2} = config_file OR abs_path, `char`,
%             if path provided, return the path, else return path chosen
%             from GUI.
% 
% See Also: 
% * yaml.loadFile

function varargout = parse_config(config_file,legacy, verbose)

    arguments
        config_file (1,:) = []
        legacy (1,1) {mustBeNumericOrLogical} = false
        verbose (1,1) {mustBeNumericOrLogical} = true
    end

    if legacy
        read_yaml = @(x) ReadYaml(x);
    else
        read_yaml = @(x) yaml.loadFile(x);
    end

    % Load the config file
    if isempty(config_file)
        [file, abs_path] = uigetfile('*.yaml');
        config = read_yaml(pathlib.join(abs_path, file));
        varargout{2} = pathlib.join(abs_path, file);
    else
        config = read_yaml(config_file);
        varargout{2} = config_file;
    end

    % Convert strings to character vectors for compatibility
    fnames = fieldnames(config);
    for ii = 1:length(fnames)
        if isstring(config.(fnames{ii}))
            config.(fnames{ii}) = char(config.(fnames{ii}));
        end
    end

    % Check for required config options
    required_fields = {'stimuli_type', 'n_trials_per_block', 'n_blocks', 'experiment_name', 'subject_ID'};
    for ii = 1:length(required_fields)
        assert(isfield(config, required_fields{ii}), ['required_field: ', required_fields{ii}]);
    end

    %% Perform specific parsing of config options
    stimuli_types = {'Bernoulli', 'Brimijoin', 'GaussianNoise', 'GaussianNoiseNoBins', ...
                    'GaussianPrior', 'UniformNoise', 'UniformNoiseNoBins', 'UniformPrior', ...
                    'PowerDistribution', 'UniformPriorWeightedSampling'};
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

    % target_signal
    if isfield(config, 'target_signal')
        if isfield(config, 'target_signal_filepath')
            corelib.verb(verbose, 'WARN: parse_config', 'target_signal_filepath not defined but target_signal is.');
        end
    end
    if isfield(config, 'target_signal_filepath')
        if isfield(config, 'target_signal')
            corelib.verb(verbose, 'WARN: parse_config', 'target_signal is not defined but target_signal_filepath is.');
        end
    end
    

    varargout{1} = config;

end % function

