% ### config2table
% 
% Take information from directory containing config files and return
% a table with all relevant information for each config.
% 
% **ARGUMENTS:** 
% 
%   - curr_dir: `struct`, 
%   which is the directory information 
%   containing config file name, path, and other
%   returns from `dir()` function.
% 
% **OUTPUTS:** 
% 
%   - data_table: `table`
% 
% See also:
% parse_config
% * [dir](https://www.mathworks.com/help/matlab/ref/dir.html)

function data_table = config2table(curr_dir)

    arguments
        curr_dir (:,1)
    end
    
    config_file = curr_dir(1);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    
    data_table = cellstr4tables(struct2table(config));
    data_table.ID = 1;
    
    % Create and outer join each new data table, keeping column names the same
    if length(curr_dir) > 1
        for ii = 2:length(curr_dir)
            config_file = curr_dir(ii);
            config = parse_config(pathlib.join(config_file.folder, config_file.name));
    
            new_data_table = cellstr4tables(struct2table(config));
            new_data_table.ID = ii;
            data_table = outerjoin(data_table, new_data_table, 'MergeKeys', true);
        end
    end
    
    %% Remove unnecessary info from table / clean fields
    
    % Extract tone name from target .wav filepath
    if ~isempty(data_table.target_audio_filepath)
        audPath_cell = mat2cell(data_table.target_audio_filepath, ...
            repelem(1,size(data_table.target_audio_filepath,1)), ...
            repelem(size(data_table.target_audio_filepath,2),1));
        data_table.target_audio = cellfun(@(x) extractBetween(x,'Tinnitus_','_Tone'), audPath_cell);
    end
    
    remove_fields = {'n_trials_per_block', 'n_blocks', ...
        'min_freq', 'max_freq', 'duration', 'n_bins', ...
        'target_audio_filepath', 'bin_target_signal', ...
        'data_dir', 'stimuli_save_type'};
    
    data_table = removevars(data_table,remove_fields);

end % function

