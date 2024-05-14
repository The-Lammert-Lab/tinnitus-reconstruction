% ### get_gamma_from_config
% 
% Choose a gamma value to be used in `cs` based on data in the config.
% 
% **ARGUMENTS:**
% 
%   - config: `struct`, config from which to find gamma
%   - verbose: `bool`, default: `true`,
%       flag to print information messages.
% 
% **OUTPUTS:**
% 
%   - this_gamma: `scalar`, the chosen gamma value.

function this_gamma = get_gamma_from_config(config, verbosity)
    arguments
        config (1,1) struct
        verbosity (1,1) {mustBeNumericOrLogical} = true
    end

    % Try to set the gamma parameter from the config.
    if any(strcmp(fieldnames(config), 'gamma'))
        this_gamma = config.gamma;
        corelib.verb(verbosity, 'INFO: get_gamma_from_config', ['gamma parameter set to ', num2str(this_gamma), ', based on config.']);
    elseif any(strcmp(fieldnames(config), 'n_bins'))
        % Try to set the gamma parameter based on the number of bins
        this_gamma = get_gamma(config.n_bins);
        corelib.verb(verbosity, 'INFO: get_gamma_from_config', ['gamma parameter set to ', num2str(this_gamma), ', based on the number of bins.']);
    else
        % Set gamma based on a guess
        this_gamma = 32;
        corelib.verb(verbosity, 'INFO: get_gamma_from_config', ['gamma parameter set to ', num2str(this_gamma), ', which is the default.']);
    end
end
