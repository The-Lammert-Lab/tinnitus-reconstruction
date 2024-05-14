% ### collect_data_pitch_match
% 
% Returns the saved responses and stimuli 
% from pitch matching experiments for a given config file.
% 
% **ARGUMENTS:**
% 
%   - config_file: `char`, name-value, default: `''`
%       Path to the desired config file.
%       GUI will open for the user to select a config if no path is supplied.
%   - config: `struct`, name-value, default: `[]`
%       An already-loaded config struct.
%   - data_dir: `char`, name-value, default: `''`
%       Filepath to directory in which data is stored. 
%       `config.data_dir` is used if left empty. 
%   - verbose, `logical`, name-value, default: `true`,
%       Flag to show informational messages.
% 
% **OUTPUTS:**
% 
%   - responses: `n x 1` cell of vectors containing responses on {0,1},
%       where `n` is the number of PitchMatch experiments run with this config file.
%       Each row contains the responses from separate experiments.
%   - stimuli: `n x 1` cell of vectors containing frequency values 
%       corresponding to the responses. 
%       Each row contains the responses from separate experiments.
%   - octave_responses: `n x 1` cell of vectors containing responses 
%       on {0,1} to the "octave confusion" section of the PitchMatch experiment. 
%       Each row contains the responses of separate experiments.
%   - octave_stimuli: `n x 1` cell of vectors containing frequency values
%       from the "octave confusion" section of the PitchMatch experiment. 
%       Each row contains the responses of separate experiments.

function [responses, stimuli, octave_responses, octave_stimuli] = collect_data_pitch_match(options)
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
        corelib.verb(options.verbose, 'INFO: collect_data_pitch_match', 'config file loaded from GUI')
    elseif isempty(options.config)
        config = parse_config(options.config_file);
        corelib.verb(options.verbose, 'INFO: collect_data_pitch_match', ['config object loaded from provided file [', options.config_file, ']'])
    else
        config = options.config;
        corelib.verb(options.verbose, 'INFO: collect_data_pitch_match', 'config object provided')
    end
    
    config_hash = get_hash(config);
    
    % If no data directory is provided, use the one from the config file
    if isempty(options.data_dir)
        options.data_dir = config.data_dir;
        corelib.verb(options.verbose, 'INFO: collect_data_pitch_match', ['using data directory from config: ' char(config.data_dir)])
    else
        corelib.verb(options.verbose, 'INFO: collect_data_pitch_match', ['using data directory from function arguments: ' options.data_dir])
    end

    % 
    files_responses = dir(fullfile(options.data_dir, ['PM_tone_responses_', config_hash, '*.csv']));
    files_stimuli = dir(fullfile(options.data_dir, ['PM_tones_', config_hash, '*.csv']));
    files_octave_responses = dir(fullfile(options.data_dir, ['PM_octave_responses_', config_hash, '*.csv']));
    files_octave = dir(fullfile(options.data_dir, ['PM_octaves_', config_hash, '*.csv']));
    
    responses = cell(length(files_responses),1);
    stimuli = cell(length(files_stimuli),1);
    octave_stimuli = cell(length(files_octave),1);
    octave_responses = cell(length(files_octave_responses),1);
    for ii = 1:length(files_responses)
        filepath_responses = fullfile(files_responses(ii).folder,files_responses(ii).name);
        responses{ii} = readmatrix(filepath_responses);

        filepath_stimuli = fullfile(files_stimuli(ii).folder,files_stimuli(ii).name);
        stimuli{ii} = readmatrix(filepath_stimuli);

        try
            filepath_oct_stim = fullfile(files_octave(ii).folder,files_octave(ii).name);
            octave_stimuli{ii} = readmatrix(filepath_oct_stim);
    
            filepath_oct_resp = fullfile(files_octave_responses(ii).folder,files_octave_responses(ii).name);
            octave_responses{ii} = readmatrix(filepath_oct_resp);
        catch
            % Don't add anything to the cell if no octave data exists for some reason
            if options.verbose
                warning('No octave confusion files found.')
            end
        end
    end
end
