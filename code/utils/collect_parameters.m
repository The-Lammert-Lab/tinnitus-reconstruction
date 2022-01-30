function data_table = collect_parameters(filenames)
    % Read parameters out from character vectors of text contained in
    % a character vector or cell array.
    % 
    % Arguments:
    % 
    %   filenames: cell array of character vectors or character vector
    %       Contains the filenames (or text strings)
    %       to read parameters out of.
    %       If `filenames` is a cell array, parameters are read from each
    %       character vector contained in the cell array.
    %       Filenames should not have file endings like '.csv'.
    %       The regular expressions are not sophisticated enough to skip them.
    % 
    % Outputs:
    % 
    %   data_table: table
    % 
    % Example:
    % 
    %   data_table = collect_parameters(filenames)
    % 
    % See Also: collect_reconstructions, collect_data


    arguments
        filenames (:,1)
    end

    if isa(filenames, 'char')
        filenames = {filenames};
    end

    % ii = 1 condition
    regex_result = regexp(filenames{1}, '([\w_]+)=([\-\w\d\.\,]*)', 'tokens');
    params_cell = cat(1, regex_result{:})';
    data_table = cell2table(params_cell(2, :), 'VariableNames', params_cell(1, :));

    if length(filenames) > 1
        for ii = 2:length(filenames)
            regex_result = regexp(filenames{ii}, '([\w_]*)=([\-\w\d\.\,]*)', 'tokens');
            params_cell = cat(1, regex_result{:})';
            new_data_table = cell2table(params_cell(2, :), 'VariableNames', params_cell(1, :));
            data_table = [data_table; new_data_table];
        end
    end

end % function