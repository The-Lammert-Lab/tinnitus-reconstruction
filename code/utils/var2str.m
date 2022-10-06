function [val] = var2str(val)
    % Convert a numeric matrix, or cell array of numbers or character vectors
    % into a character vector.


    % type checking and conversions for val
    % return a character vector with no whitespace
    if isnumeric(val)
        val = regexprep(num2str(val(:)'), '\s*', ',');
        % is the data numeric?
    elseif iscell(val)
        if all(cellfun(@isnumeric, val))
            % convert to character vector
            val = num2str([val{:}]);
            % replace whitespace with comma
            val = regexprep(val(:)', '\s*', ',');
        elseif all(cellfun(@ischar, val))
            % combine all cells into a vector
            % with commas between them
            new_val = [];
            for ii = 1:length(val)-1
                new_val = [new_val, val{ii}(:)', ','];
            end
            val = [new_val, val{end}(:)'];
        else
            error('cell array doesn''t contain only numeric or characte vector data')
        end
    elseif ischar(val)
        % assume everything is fine but replace whitespace
        val = regexprep(val(:)', '\s*', ',');
    elseif islogical(val)
        val = regexprep(num2str(val(:)'), '\s*', ',');
    elseif isstring(val)
        % assume everything is fine but replace whitespace and cast as a character vector
        val = char(val);
        val = regexprep(val(:)', '\s*', ',');
    else
        error(['the class of this variable is: ', class(val), '. I don''t know what to do with this.'])
    end

end