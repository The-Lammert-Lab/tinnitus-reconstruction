function [mean_dBs, unique_tones] = collect_data_threshold(options)
    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.verbose (1,1) logical = true
        options.data_dir (1, :) char = ''
    end
    
    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data', 'config file loaded from GUI')
    elseif isempty(options.config)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data', ['config object loaded from provided file [', options.config_file, ']'])
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

    % Get all full file names
    files_thresholds = dir(fullfile(options.data_dir, ['threshold_dB_', config_hash, '*.csv']));
    files_tones = dir(fullfile(options.data_dir, ['threshold_tones_', config_hash, '*.csv']));

    % Collect
    dBs = cell(length(files_thresholds),1);
    tones = cell(length(files_tones),1);
    for ii = 1:length(files_thresholds)
        filepath_thresholds = fullfile(files_thresholds(ii).folder,files_thresholds(ii).name);
        filepath_tones = fullfile(files_tones(ii).folder,files_tones(ii).name);

        dBs{ii} = readmatrix(filepath_thresholds);
        tones{ii} = readmatrix(filepath_tones);
    end

    % Convert to vectors
    tones = vertcat(tones{:});
    dBs = vertcat(dBs{:});

    % Get unique tones in sorted order
    [unique_tones, ~, group_inds] = unique(tones,'sorted');

    % Average dBs and amplitudes grouping by tone frequency
    mean_dBs = splitapply(@mean,dBs,group_inds);
end
