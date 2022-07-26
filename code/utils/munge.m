function munge(config_file)
    
    config = parse_config(config_file);
    config_hash = get_hash(config);
    hash_prefix = [config_hash '_' num2str(floor(posixtime(datetime('now', 'TimeZone', 'local'))))];
    
    files = dir("*.csv");
    
    for ii = 1:length(files)
        this_filename = strrep(files(ii).name, 'pilot&&subject=AL&&stimuli_type=uniformprior&&target_audio=roar_', '');
        this_filename = strrep(this_filename, 'meta_', ['meta_', hash_prefix, '_']);
        this_filename = strrep(this_filename, 'stimuli_', ['stimuli_', hash_prefix, '_']);
        this_filename = strrep(this_filename, 'responses_', ['responses_', hash_prefix, '_']);
        this_filename(end-31:end) = [];
        this_filename = [this_filename, '.csv'];
        movefile(files(ii).name, this_filename)
        disp(this_filename)
    end

end % function