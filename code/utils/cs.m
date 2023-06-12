% ### cs  
% 
% ```matlab
% [x] = cs(responses, Phi, Gamma)
% [x] = cs(responses, Phi)
%```
% 
% **ARGUMENTS:**
% 
%   - responses: `n x 1` vector
% 
%   - Phi: `n x m` matrix,
%       where `n` is the number of trials/samples
%       and `m` is the dimensionality of the stimuli/spectrum/bins
% 
%   - Gamma: Positive scalar, default: 32
%       optional value for zhangpassivegamma function.
% 
%   - mean_zero: `bool`, name-value, default: `false`,
%       a flag for setting the mean of `Phi` to zero.
% 
%   - verbose: `bool`, name-value, default: `true`,
%       a flag to print information messages
% 
% **OUTPUTS:**
% 
%   - x: `m x 1` vector,
%       representing the compressed sensing reconstruction of the signal.

function x = cs(responses, Phi, Gamma, options)

    arguments
        responses (:,1) {mustBeNumeric}
        Phi {mustBeNumeric}
        Gamma (1,1) {mustBeInteger, mustBeNonnegative} = 32
        options.mean_zero (1,1) logical = false
        options.verbose (1,1) logical = true
    end
    
    n_samples = length(responses);
    len_signal = size(Phi, 2);

    % Since this is only cosmetic, shouldn't error if user doesn't have 
    % parallel computing toolbox that is required by waittext.
    show_waittext = options.verbose && ~license('test','Distrib_Computing_Toolbox');

    if show_waittext
        waittext(0, 'init');
    end

    if options.mean_zero
        Phi = Phi - mean(Phi,2);
    end

    Theta = zeros(n_samples, len_signal);
    for ii = 1:len_signal
        if show_waittext
            waittext(ii/len_signal, 'fraction');
        end
        ek = zeros(1, len_signal);
        ek(ii) = 1;
        Psi = idct(ek)';
        Theta(:, ii) = Phi * Psi;
    end
        
    s = zhangpassivegamma(Theta, responses, Gamma);

    if show_waittext
        waittext(0, 'init');
    end

    x = zeros(len_signal, 1);
    for ii = 1:len_signal
        if show_waittext
            waittext(ii/len_signal, 'fraction');
        end
        ek = zeros(1, len_signal);
        ek(ii) = 1;
        Psi = idct(ek)';
        x = x + Psi * s(ii);
    end

end
