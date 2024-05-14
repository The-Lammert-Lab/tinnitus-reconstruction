% ### get_best_pitch
% 
% Returns the matched pitch for a given config's PM data 
% and whether or not all any octaves were confused
% 
% **ARGUMENTS:**
% 
%   - config_file: `character vector`, name-value, default: `''`
%       Path to the desired config file.
%       GUI will open for the user to select a config if no path is supplied.
%   - config: `struct`, name-value, default: `[]`,
%       the loaded config.
%   - data_dir: `character vector`, name-value, default: `''`,
%       the path to the location of the data. 
%       If none is supplied, config.data_dir will be used.
%   - verbose: `bool`, name-value, default: `true`,
%       flag to print information text.
% 
% **OUTPUTS:**
%   
%   - best_freq: `1x1` scalar, the identified best frequency.
%   - oct_agree: `bool`, `true` if there was never any octave confusion over all data
%       `false` if there was ever any octave confusion.
% 
% See also:
% PitchMatch
% collect_data_pitch_match

function [best_freq, oct_agree] = get_best_pitch(options)
    arguments
        options.config_file (1,:) = ''
        options.config = []
        options.verbose (1,1) logical = true
        options.data_dir (1, :) char = ''
    end
    
    %% Setup

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config) && isempty(options.config_file)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: get_best_pitch', 'config file loaded from GUI')
    elseif isempty(options.config)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: get_best_pitch', ['config object loaded from provided file [', options.config_file, ']'])
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: get_best_pitch', 'config object provided')
    end
        
    % If no data directory is provided, use the one from the config file
    if isempty(options.data_dir)
        options.data_dir = config.data_dir;
        corelib.verb(options.verbose, 'INFO: get_best_pitch', ['using data directory from config: ' char(config.data_dir)])
    else
        corelib.verb(options.verbose, 'INFO: get_best_pitch', ['using data directory from function arguments: ' options.data_dir])
    end

    %% Get data
    [responses, stimuli, octave_responses, ~] = collect_data_pitch_match('config', config, 'data_dir', options.data_dir, 'verbose', options.verbose);
    if isempty(responses) || isempty(stimuli)
        best_freq = NaN;
        oct_agree = NaN;
        return
    end

    %% Find best pitch
    final_freqs = zeros(length(responses),1);
    oct_agree = zeros(length(responses),1);
    for ii = 1:length(responses)
        if ~responses{ii}(end) % Last choice was a 0 (lower freq preferred)
            final_freqs(ii) = stimuli{ii}(end-1);
        else
            final_freqs(ii) = stimuli{ii}{end};
        end
        % [1; 0] is "correct", i.e., no octave confusion.
        if isequal(octave_responses{ii}, [1; 0])
            oct_agree(ii) = true;
        else
            oct_agree(ii) = false;
        end
    end
    
    % If all repetitions have a different final frequency, take the mean
    if length(unique(final_freqs)) == length(final_freqs)
        best_freq = mean(final_freqs);
    else
        best_freq = mode(final_freqs);
    end

    oct_agree = all(oct_agree);
end
