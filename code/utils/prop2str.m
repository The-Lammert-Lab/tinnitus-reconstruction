function [stringified_properties] = prop2str(obj, properties_to_skip, property_separator)
    % Converts the property names and values of a struct or object
    % into a character vector.
    % For example, a struct, s, with the properties, s.a = 1, s.b = 2,
    % would become 'a=1-b=2'.
    % If some of the property values are cell arrays,
    % they should be character vectors or numerical vectors
    % and of the same type within each cell array.
    % 
    % Arguments:
    %
    %   obj: 1x1 struct or object
    %       Object with properties to be stringified
    % 
    %   properties_to_skip: character vector or cell array
    %       Properties to not include in the output character vector.
    % 
    %   property_separator: character vector
    %       What separator to use between parameter statements.
    % 
    % Returns:
    % 
    %   stringified_properties: character vector
    % 
    % Example:
    %
    %   stringified_properties = prop2str(obj, [], '&&')
    % 
    % See Also: collect_parameters

    stringified_properties = [];
    props = fieldnames(obj);

    if nargin < 2
        properties_to_skip = {};
    elseif ischar(properties_to_skip)
        properties_to_skip = {properties_to_skip};
    end

    if nargin < 3
        property_separator = '&&';
    end

    for ii = 1:length(props)-1
        prop = props{ii};
        val = obj.(prop);

        % if property should be skipped, skip it
        if any(strcmp(prop, properties_to_skip))
            continue
        end
        
        % type checking and conversions
        val = var2str(val);

        string_chunk = [prop, '=', val];
        stringified_properties = [stringified_properties, string_chunk, property_separator];
    end

    prop = props{end};
    val = var2str(obj.(prop));
    string_chunk = [prop, '=', val];
    stringified_properties = [stringified_properties, string_chunk];

end % function