function [responses, stimuli] = collect_data(options)

    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.verbose (1,1) logical = true
    end

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        [file, abs_path] = uigetfile();
        config = parse_config(pathlib.join(abs_path, file), options.verbose);
        corelib.verb(options.verbose, 'INFO: collect_data', ['config file [', file, '] loaded from GUI'])
    elseif isempty(options.config)
        config = parse_config(options.config_file, options.verbose);
        corelib.verb(options.verbose, 'INFO: collect_data', 'config object loaded from provided file [', options.config_file, ']')
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: collect_data', 'config object provided')
    end

    config_hash = get_hash(config);

    % Find the files containing the data
    glob_responses = pathlib.join(config.data_dir, ['responses_', config_hash, '*.csv']);
    glob_stimuli = pathlib.join(config.data_dir, ['stimuli_', config_hash, '*.csv']);
    files_responses = dir(glob_responses);
    files_stimuli = dir(glob_stimuli);

    % Remove mismatched files
    [mismatched_response_files, mismatched_stimuli_files] = filematch({files_responses.name}, {files_stimuli.name}, 'delimiter', '_');
    files_responses(mismatched_response_files) = [];
    files_stimuli(mismatched_stimuli_files) = [];
    
    if isempty(files_responses)
        error(['No response files found at:  ', glob_responses, ' . Check that your config.data_dir and config.subjectID are correct'])
    end

    if isempty(files_stimuli)
        error(['No stimuli files found at:  ', glob_stimuli, ' . Check that your config.data_dir and config.subjectID are correct'])
    end

    % Checks for data validity
    corelib.verb(length(files_responses) ~= length(files_stimuli), 'WARN', 'number of stimuli and response files do not match')

    % Instantiate cell arrays to hold the data
    stimuli = cell(length(files_stimuli), 1);
    responses = cell(length(files_responses), 1);

    % Load the files and add to the cell arrays
    for ii = 1:length(files_responses)
        filepath_responses = pathlib.join(files_responses(ii).folder, files_responses(ii).name);
        filepath_stimuli = pathlib.join(files_stimuli(ii).folder, files_stimuli(ii).name);

        % Read in the responses and stimuli
        responses{ii} = readmatrix(filepath_responses);
        stimulus_block = readmatrix(filepath_stimuli);
        
        % If the responses for this file are empty,
        % don't add any stimuli.
        % Otherwise, add stimuli for each response given.
        % This accounts for incomplete blocks.
        if isempty(responses{ii})
            stimuli{ii} = [];
        else
            stimuli{ii} = stimulus_block(:, 1:length(responses{ii}));
        end
    end

    responses = vertcat(responses{:});
    stimuli = horzcat(stimuli{:});

end % function