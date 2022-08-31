%% munge_hashes.m 
% Processes config files, correcting errors.
% Then, fixes the hashes for saved data files
% associated with changed config files.

LEGACY = false;


config_files = dir("config*.yaml");

for ii = 1:length(config_files)
    config_file = config_files(ii).name;
    config = parse_config(config_file, LEGACY, true);
    old_hash = get_hash(config);
    corelib.verb(true, 'munge_hashes', ['config is: ', config_file])
    corelib.verb(true, 'munge_hashes', ['hash is: ', old_hash])

    %% Get the new properties

    if isfield(config, 'target_audio_filepath')
        target_signal_filepath = config.target_audio_filepath;
        
        % Update target signal filepath
        config.target_signal_filepath = target_signal_filepath;
        config = rmfield(config, 'target_audio_filepath');
        corelib.verb(true, 'munge_hashes', 'removing target_audio_filepath, replacing with target_signal_filepath')
    end

    if contains(config_file, 'buzz')
        target_signal_name = 'buzzing';
    elseif contains(config_file, 'roar')
        target_signal_name = 'roaring';
    else
        error("unknown target signal type")
    end

    % Update properties
    config.target_signal_name = target_signal_name;
    corelib.verb(true, 'munge_hashes', ['new target signal name: ', target_signal_name])
    
    % Set stimuli save type
    config.stimuli_save_type = 'bins';
    corelib.verb(true, 'munge_hashes', 'fixing stimuli save type')

    % For 2-AFC
    if strcmp(config.experiment_name, 'paper1-buzzing-BWR') && isfield(config, 'two_afc') && config.two_afc
        config.experiment_name = 'paper1-buzzing-2afc-BWR';
        corelib.verb(true, 'munge_hashes', 'fixing 2afc experiment name')
    end
    
    % Save the config file
    yaml.dumpFile(config_file, config, "block");

    % Compute the new hash
    new_hash = get_hash(parse_config(config_file));
    corelib.verb(true, 'munge_hashes', ['new hash is: ', new_hash])

    % Update hashes
    update_hashes(new_hash, old_hash, '/home/alec/code/tinnitus-project/code/experiment/Data');


end



