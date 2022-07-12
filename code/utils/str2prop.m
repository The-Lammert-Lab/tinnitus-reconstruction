% ### str2prop
% Converts a string of properties and values
% into a struct or cell array.
% TODO: more documentation, use property_separator
% 
% Arguments:
% 
%   prop_string: character vector
%       String containing property : value pairs
% 
%   properties_to_skip: character vector or cell array
%       Properties to not incude in the output character vector
% 
%   property_separator: character vector
%       What separator to use between parameter statements.
% 
% Returns:
% 
%   obj: struct or cell array
% 
% 
% Example:
% 
%   obj = str2prop(prop_string, [], '&&')
% 
% See Also: 
% collect_parameters

function obj = str2prop(prop_string, properties_to_skip, property_separator, output_type)

    arguments
        prop_string {mustBeText}
        properties_to_skip = []
        property_separator = '&&'
        output_type = 'struct'
    end

    regex_result = regexp(prop_string, '([\w_]+)=([\-\w\d\.\,]*)', 'tokens');
    params_cell = cat(1, regex_result{:})';

    if ~strcmp(output_type, 'struct')
        obj = params_cell;
        return
    end

    obj = cell2struct(params_cell(2, :), params_cell(1, :), 2);


end % function