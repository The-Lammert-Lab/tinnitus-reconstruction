function params = collect_parameters(filenames, pattern, n_params)
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
    % 
    %   pattern: character vector or string
    %       A regular expression pattern matching the parameters to extract.
    % 
    %   n_params: integer scalar
    %       How many parameters are there?
    % 
    % Outputs:
    % 
    %   params: numerical matrix
    %       m x n matrix of parameter values,
    %       where m is the number of filenames
    %       and n is the number of parameters.
    % 
    % Example:
    % 
    %   params = collect_parameters('n_bins_filled_mean=10-n_bins_filled_var=3', 'n_bins_filled_mean=(\d*)-n_bins_filled_var=(\d*)')
    % 
    % See Also: collect_reconstructions, collect_data


    arguments
        filenames (:,1)
        pattern (1,:) char
        n_params (1,1) double {mustBeInteger, mustBePositive}
    end

    if isa(filenames, 'char')
        filenames = {filenames};
    end
    
    % Get the parameter values from the files
    params = cell(length(filenames), n_params);

    for ii = 1:length(filenames)
        these_params = regexp(filenames{ii}, pattern, 'tokens');
        if isempty(these_params)
            error(['regex failed to match with string: ', filenames{ii}, ' and regex pattern: ', pattern])
        end
        if ~(length(these_params) > 1)
            these_params = mat2cell(these_params{1}(:), n_params, 1);
        end
        params(ii, :) = these_params{:};
    end


end % function