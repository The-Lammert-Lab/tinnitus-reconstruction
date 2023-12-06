function [dBs, tones] = collect_data_thresh_or_loud(exp_type, options)
    arguments
        exp_type (1,:) char
        options.config_file (1,:) = ''
        options.data_dir (1, :) char = ''
        options.config = []
        options.verbose (1,1) logical = true
        options.average logical = true
    end

    if ~ismember(exp_type,{'threshold','loudness'})
        error(['UNKNOWN EXPERIMENT TYPE: ''', exp_type, ...
            '''. `exp_type` must be ''threshold'' or ''loudness'''])
    end

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data_thresh_or_loud', 'config file loaded from GUI')
    elseif isempty(options.config)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data_thresh_or_loud', ['config object loaded from provided file [', options.config_file, ']'])
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: collect_data_thresh_or_loud', 'config object provided')
    end
    
    config_hash = get_hash(config);
    
    % If no data directory is provided, use the one from the config file
    if isempty(options.data_dir)
        options.data_dir = config.data_dir;
        corelib.verb(options.verbose, 'INFO: collect_data_thresh_or_loud', ['using data directory from config: ' char(config.data_dir)])
    else
        corelib.verb(options.verbose, 'INFO: collect_data_thresh_or_loud', ['using data directory from function arguments: ' options.data_dir])
    end

    % Get all full file names
    files_thresholds = dir(fullfile(options.data_dir, [exp_type, '_dBs_', config_hash, '*.csv']));
    files_tones = dir(fullfile(options.data_dir, [exp_type, '_tones_', config_hash, '*.csv']));

    if isempty(files_thresholds) || isempty(files_tones)
        dBs = [];
        tones = [];
        corelib.verb(options.verbose, 'INFO: collect_data_thresh_or_loud', ['No ', exp_type, ' data found.'])
        return
    end

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

    % Remove any tones that do not have a corresponding decibel level
    tones = tones(1:size(dBs,1));

    if options.average
        % Get unique tones in sorted order
        [tones, ~, group_inds] = unique(tones,'sorted');
    
        % Average dBs and amplitudes grouping by tone frequency
        dBs = splitapply(@mean,dBs,group_inds);
    end
end
