% ### collect_data_thresh_or_loud
% 
% Returns the saved dB levels and corresponding tones
% from either threshold determination or loudness matching
% experiments for a given config file.
% 
% **ARGUMENTS:**
% 
%   - exp_type: `char`, valid values: 'threshold' or 'loudness',
%       the type of experimental data to collect.
%   - config_file: `char`, name-value, default: `''`
%       Path to the desired config file.
%       GUI will open for the user to select a config if no path is supplied.
%   - config: `struct`, name-value, default: `[]`
%       An already-loaded config struct.
%   - data_dir: `char`, name-value, default: `''`
%       Filepath to directory in which data is stored. 
%       `config.data_dir` is used if left empty. 
%   - average: `logical`, name-value, default: `true`,
%       Flag to average dB values for all repeated tones.
%   - fill_nans: `logical`, name-value, default: `false`,
%       Flag to fill in NaN values with the previous non-NaN value
%   - verbose, `logical`, name-value, default: `true`,
%       Flag to show informational messages.
% 
% **OUTPUTS:**
% 
%   - pres_dBs: `n x 1` vector containing dB values,
%       where `n` is the number of unique tones if `average` is `true`,
%       or is the number of presented stimuli if `average` is `false.
%   - amp_dBs: `n x 1` vector containing amplitude values.
%   - tones: `n x 1` vector containing frequency values for each response.

function [pres_dBs, amp_dBs, tones] = collect_data_thresh_or_loud(exp_type, options)
    arguments
        exp_type (1,:) char
        options.config_file (1,:) = ''
        options.data_dir (1, :) char = ''
        options.config = []
        options.verbose (1,1) logical = true
        options.average logical = true
        options.fill_nans logical = false
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

    if all(isnan(dBs))
        return
    end

    if options.fill_nans && all(any(isnan(dBs)))
        % Try to fill with previous first then fill with nearest
        dBs = fillmissing(dBs,'previous');
        if any(isnan(dBs))
            dBs = fillmissing(dBs,'nearest');
        end
    end

    if options.average
        % Fill in NaNs
        if any(isnan(dBs))
            % Try to fill with previous first then fill with nearest
            dBs = fillmissing(dBs,'previous');
            if any(isnan(dBs))
                dBs = fillmissing(dBs,'nearest');
            end
        end

        % Get unique tones in sorted order
        [tones, ~, group_inds] = unique(tones,'sorted');
    
        % Average dBs and amplitudes grouping by tone frequency
        dBs = splitapply(@(x) mean(x,1),dBs,group_inds);
    end

    pres_dBs = dBs(:,1);
    amp_dBs = dBs(:,2);
end
