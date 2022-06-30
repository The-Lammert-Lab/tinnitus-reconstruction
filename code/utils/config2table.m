%%% Collect and present the desired fields for data table

function data_table = config2table(dir)

    config_file = dir(1);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    
    data_table = struct2table(config);

    data_table.ID = 1;

    if length(dir) > 1
        for ii = 2:length(dir)
            config_file = dir(ii);
            config = parse_config(pathlib.join(config_file.folder, config_file.name));

            new_data_table = struct2table(config);
            new_data_table.ID = ii;
            data_table = outerjoin(data_table, new_data_table, 'MergeKeys', true);
        end
    end

    %% Remove unnecessary info from table / clean fields
    
    if ~isempty(data_table.target_audio_filepath)
        audPath_cell = mat2cell(data_table.target_audio_filepath, ...
            [1 1], length(data_table.target_audio_filepath));
        data_table.target_audio = cellfun(@(x) extractBetween(x,'Tinnitus_','_Tone'), audPath_cell);
    end

    remove_fields = {'n_trials_per_block', 'n_blocks', ...
        'min_freq', 'max_freq', 'duration', 'n_bins', ...
        'target_audio_filepath', 'bin_target_signal', ... 
        'data_dir', 'stimuli_save_type'};

    data_table = removevars(data_table,remove_fields);

end

