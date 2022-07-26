function munge(config_file, flag)

    arguments
        config_file (1, :) char
        flag (1,:) char = 'all' % or 'data' or 'filenames'
    end
    
    config = parse_config(config_file);
    config_hash = get_hash(config);
    hash_prefix = [config_hash '_' num2str(floor(posixtime(datetime('now', 'TimeZone', 'local'))))];

    if strcmp(flag, 'all') || strcmp(flag, 'filenames')
    
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

    end

    if strcmp(flag, 'all') || strcmp(flag, 'data')
        files = dir(['stimuli_', config_hash, '_*.csv']);
        stimgen = eval([config.stimuli_type, 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);

        for ii = 1:length(files)
            corelib.verb(true, 'munge', ['Writing ' files(ii).name])
            this_spectrum = readmatrix(files(ii).name);
            this_bin_repr = stimgen.spect2binnedrepr(this_spectrum); % spectrum => bin repr
            writematrix(this_bin_repr, files(ii).name);
        end

    end

end % function