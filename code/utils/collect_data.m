function [responses, stimuli] = collect_data(options)

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

    %% Is the config file for a 2AFC experiment?

    if isfield(config, 'two_afc') && config.two_afc
        is_two_afc = true;
        corelib.verb(options.verbose, 'INFO: collect_data', 'operating in 2-afc mode')
    else
        is_two_afc = false;
    end

    %% Find the files containing the data

    % These variables are the same size regardless of 2-afc status
    glob_meta = pathlib.join(options.data_dir, ['meta_', config_hash, '*.csv']);
    files_meta = dir(glob_meta);
    
    % These variables are the same size regardless of 2-afc status
    glob_responses = pathlib.join(options.data_dir, ['responses_', config_hash, '*.csv']);
    files_responses = dir(glob_responses);

    % These variables are only for non-2-afc experiments
    glob_stimuli = pathlib.join(options.data_dir, ['stimuli_', config_hash, '*.csv']);
    files_stimuli = dir(glob_stimuli);
    
    % If in a 2AFC regime, there are two stimuli files for each meta file with file names of the form:
    % "stimuli_{config_hash}_{unix_timestamp}_{stimuli_hash}.csv".
    % The meta file has a file name of the form:
    % "meta_{config_hash}_{unix_timestamp}_{stimuli_hash_1}_{stimuli_hash_2}.csv".
    if is_two_afc
        globs_stimuli_1s = cell(length(files_meta), 1);
        globs_stimuli_2s = cell(length(files_meta), 2);
        for ii = 1:length(files_meta)
            splits = split(files_meta(ii).name, '_'); % split into a cell array at "_"
            stimulus_hash_1 = splits{4};
            stimulus_hash_2 = splits{5}(1:end-4); % remove ".csv" from end
            globs_stimuli_1s{ii} = pathlib.join(options.data_dir, ['stimuli_', config_hash, '*', stimulus_hash_1,'.csv']);
            globs_stimuli_2s{ii} = pathlib.join(options.data_dir, ['stimuli_', config_hash, '*', stimulus_hash_2,'.csv']);
        end
    end

    %% Checks for data validity

    if ~is_two_afc
        % Remove mismatched files
        [mismatched_response_files, mismatched_stimuli_files] = filematch({files_responses.name}, {files_stimuli.name}, 'delimiter', '_');
        files_responses(mismatched_response_files) = [];
        files_stimuli(mismatched_stimuli_files) = [];
        
        corelib.verb(length(files_responses) ~= length(files_stimuli), 'WARN: collect_data', 'number of stimuli and response files do not match')
        
        % Are there any response files?
        if isempty(files_responses)
            error(['No response files found at:  ', glob_responses, ' . Check that your ``options.data_dir`` and ``config.subjectID`` are correct'])
        end
    
        % Are there any stimulus files?
        if isempty(files_stimuli)
            error(['No stimuli files found at:  ', glob_stimuli, ' . Check that your ``options.data_dir`` and ``config.subjectID`` are correct'])
        end
    else
        corelib.verb(true, 'WARN', 'you are in 2AFC mode, where data validity checking has been disabled')
        % TODO: write data validity checks #77
    end

    %% Construct the output matrices
    
    if is_two_afc
        % Instantiate cell arrays to hold the data
        stimuli = cell(length(files_responses), 1);
        responses = cell(length(files_responses), 1);

        % Load the files and add to the cell arrays
        for ii = 1:length(files_responses)
            filepath_responses = pathlib.join(files_responses(ii).folder, files_responses(ii).name);
            splits = split(files_responses(ii).name, '_'); % split into a cell array at "_"
            stimulus_hash_1 = splits{3};
            stimulus_hash_2 = splits{4}(1:end-4); % remove ".csv" from end
            files_stimuli_1 = dir(pathlib.join(options.data_dir, ['stimuli_', config_hash, '*', stimulus_hash_1,'.csv']));
            files_stimuli_2 = dir(pathlib.join(options.data_dir, ['stimuli_', config_hash, '*', stimulus_hash_2,'.csv']));
            filepath_stimuli_1 = pathlib.join(files_stimuli_1(1).folder, files_stimuli_1(1).name);
            filepath_stimuli_2 = pathlib.join(files_stimuli_2(1).folder, files_stimuli_2(1).name);

            % Read in the responses and stimuli
            responses{ii} = readmatrix(filepath_responses);
            stimulus_block_1 = readmatrix(filepath_stimuli_1);
            stimulus_block_2 = readmatrix(filepath_stimuli_2);

            assert(all(size(stimulus_block_1) == size(stimulus_block_2)), 'size mismatch')

            % If the responses for this file are empty,
            % don't add any stimuli.
            % Otherwise, add stimuli for each response given.
            % This accounts for incomplete blocks.
            if isempty(responses{ii})
                stimuli{ii} = [];
            else
                % Combine the stimuli into a single tall matrix.
                % Initially, a "1" response refers to a "yes" response for stimulus 1
                % and a "-1" response refers to a "no" response for stimulus 2.
                % We want to use both "yes" and "no" stimuli
                % but change the response vector and stimulus matrix
                % so that "1" refers to "good" stimuli
                % and "-1" refers to "bad" stimuli.
                m = size(stimulus_block_1);
                n = length(responses{ii});

                correct_stimuli = NaN(m, n);
                incorrect_stimuli = NaN(m, n);

                correct_stimuli(:, responses{ii} == 1) = stimulus_block_1(:, responses{ii} == 1);
                correct_stimuli(:, responses{ii} == -1) = stimulus_block_2(:, responses{ii} == -1);
                incorrect_stimuli(:, responses{ii} == 1) = stimulus_block_2(:, responses{ii} == 1);
                incorrect_stimuli(:, responses{ii} == -1) = stimulus_block_1(:, responses{ii} == -1);

                stimulus_block_fused = NaN(m, 2 * n);
                stimulus_block_fused(:, 1:2:end) = correct_stimuli;
                stimulus_block_fused(:, 2:2:end) = incorrect_stimuli;
                
                responses_fused = ones(2 * n, 1);
                responses_fused(2:2:end) = -1;

                assert(all(~isnan(stimulus_block_fused(:))), 'stimulus_block_fused contained NaN values')

                % Reassign these vectors/matrices
                responses{ii} = responses_fused;
                stimuli{ii} = stimulus_block_fused;

            end

        end
    else
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
    end

    responses = vertcat(responses{:});
    stimuli = horzcat(stimuli{:});

end % function