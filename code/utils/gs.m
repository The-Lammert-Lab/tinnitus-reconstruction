% ### gs
% 
% Returns the linear reconstruction of stimuli and responses.
% 
% ```matlab
%   x = gs(responses, Phi)
%   x = gs(responses, Phi, 'ridge', true, 'mean_zero', true)
% ```
% 
% **ARGUMENTS:**
% 
%   - responses: `n x 1` vector of 1 and -1 values,
%       representing the subject's responses.
%   
%   - Phi: `n x m` numerical matrix,
%       where m is the length of each stimulus 
%       and n is the same length as the responses
% 
%   - ridge: `boolean`, name-value, default: `false`,
%       a flag to for using ridge regression.
% 
%   - mean_zero: `boolean`, name-value, defaut: `false`,
%       a flag for setting the mean of `Phi` to zero.
% 
% **OUTPUTS:**
% 
%   - x: `m x 1` vector,
%       representing the linear reconstruction of the signal, 
%       where m is the length of a stimulus. 

function x = gs(responses, Phi, options)
    arguments
        responses (:,1) {mustBeNumeric}
        Phi (:,:) {mustBeNumeric}
        options.ridge (1,1) logical = false
        options.mean_zero (1,1) logical = false
    end

    if options.mean_zero
        Phi = Phi - mean(Phi,2);
    end

    if options.ridge
        x = (Phi'*Phi + 0.0001*eye(size(Phi,2)))\(Phi'*responses);
    else
        len_signal = size(Phi, 2);
        x = (1 / len_signal) * Phi' * responses;
    end
end
