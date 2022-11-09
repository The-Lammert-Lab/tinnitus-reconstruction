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
%   - variables_to_remove: `cell`, default: `{}`,
%   a cell array of character vectors,
%   indicating which variables (columns) of
%   the data table to remove.
%   If empty, re-defaults to:
%   `{'n_trials_per_block', 'n_blocks', ...
%   'min_freq', 'max_freq', 'duration', 'n_bins', ...
%   'target_signal_filepath', 'bin_target_signal', ...
%    'data_dir', 'stimuli_save_type'}`.
%   
% 
% **OUTPUTS:** 
% 
%   - data_table: `table`
% 
% See also:
% parse_config
% * [dir](https://www.mathworks.com/help/matlab/ref/dir.html)

function data_table = config2table(curr_dir, variables_to_remove)

    arguments
        curr_dir (:,1)
        variables_to_remove = {}
    end
    
    config_file = curr_dir(1);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    
    data_table = cellstr4tables(struct2table(config));
    data_table.config_hash = get_hash(config);
    data_table.ID = 1;
    
    % Create and outer join each new data table, keeping column names the same
    if length(curr_dir) > 1
        for ii = 2:length(curr_dir)
            config_file = curr_dir(ii);
            config = parse_config(pathlib.join(config_file.folder, config_file.name));
    
            new_data_table = cellstr4tables(struct2table(config));
            new_data_table.config_hash = get_hash(config);
            new_data_table.ID = ii;
            data_table = outerjoin(data_table, new_data_table, 'MergeKeys', true);
        end
    end
    
    %% Remove unnecessary info from table / clean fields

    if isempty(variables_to_remove)  
        remove_fields = {'n_trials_per_block', 'n_blocks', ...
            'min_freq', 'max_freq', 'duration', ...
            'target_signal_filepath', 'bin_target_signal', ...
            'data_dir', 'stimuli_save_type'};
    else
        remove_fields = variables_to_remove;
    end
        
    data_table = removevars(data_table,remove_fields);
    data_table = sortrows(data_table, 'ID');

end % function

