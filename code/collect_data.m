function [responses, stimuli] = collect_data(options)

    arguments
        options.config char = []
        options.verbose logical = true
    end

    % If no config file path is provided,
    % open a UI to load the config
    if isempty(options.config)
        [file, abs_path] = uigetfile();
        config = ReadYaml(pathlib.join(abs_path, file));
    else
        config = ReadYaml(options.config);
    end

    % Find the files containing the data
    glob_responses = pathlib.join(config.datadir, [config.subjectID '_responses*.csv']);
    glob_stimuli = pathlib.join(config.datadir, [config.subjectID '_stimuli*.csv']);
    files_responses = dir(glob_responses);
    files_stimuli = dir(glob_stimuli);

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

    responses = vertcat(responses);
    stimuli = horzcat(stimuli);

end % function