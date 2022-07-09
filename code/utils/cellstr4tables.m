function T = cellstr4tables(T)
    % Converts all character vector columns (variables)
    % of a table into cell arrays of character vectors.
    % This is a workaround because `varfun` is bad, actually.

    arguments
        T table
    end

    d = T(1, vartype("char"));
    vars = d.Properties.VariableNames;

    for ii = 1:length(vars)
        T.(vars{ii}) = cellstr(T.(vars{ii}));
    end

end % function