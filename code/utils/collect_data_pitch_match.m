function [stimuli, responses, octave_stimuli, octave_responses] = collect_data_pitch_match(options)
    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.verbose (1,1) logical = true
        options.data_dir (1, :) char = ''
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
    
    % If no data directory is provided, use the one from the config file
    if isempty(options.data_dir)
        options.data_dir = config.data_dir;
        corelib.verb(options.verbose, 'INFO: collect_data', ['using data directory from config: ' char(config.data_dir)])
    else
        corelib.verb(options.verbose, 'INFO: collect_data', ['using data directory from function arguments: ' options.data_dir])
    end

    % 
    files_responses = dir(fullfile(options.data_dir, ['PM_responses_', config_hash, '*.csv']));
    files_stimuli = dir(fullfile(options.data_dir, ['PM_stimuli_', config_hash, '*.csv']));
    files_octave = dir(fullfile(options.data_dir, ['PM_octave_', config_hash, '*.csv']));
    files_octave_responses = dir(fullfile(options.data_dir, ['PM_octave_responses_', config_hash, '*.csv']));
    
    responses = cell(length(files_responses),1);
    stimuli = cell(length(files_stimuli),1);
    octave_stimuli = cell(length(files_octave),1);
    octave_responses = cell(length(files_octave_responses),1);
    for ii = 1:length(files_responses)
        filepath_responses = fullfile(files_responses(ii).folder,files_responses(ii).name);
        responses{ii} = readmatrix(filepath_responses);

        filepath_stimuli = fullfile(files_stimuli(ii).folder,files_stimuli(ii).name);
        stimuli{ii} = readmatrix(filepath_stimuli);

        filepath_oct_stim = fullfile(files_octave(ii).folder,files_octave(ii).name);
        octave_stimuli{ii} = readmatrix(filepath_oct_stim);

        filepath_oct_resp = fullfile(files_octave_responses(ii).folder,files_octave_responses(ii).name);
        octave_responses{ii} = readmatrix(filepath_oct_resp);
    end
end
