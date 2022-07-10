% ### cs  
% 
% [x] = cs(responses, Phi)
%
% ARGUMENTS:
%   responses: n x 1 vector
%   Phi: n x m matrix
%       where n is the number of trials/samples
%       and m is the dimensionality of the stimuli/spectrum/bins

function x = cs(responses, Phi, Gamma)

    if nargin < 3
        Gamma = 32;
    end
    
    n_samples = length(responses);
    len_signal = size(Phi, 2);

    f = waitbar(0,'Computing Theta');

    Theta = zeros(n_samples, len_signal);
    for ii = 1:len_signal
        waitbar(ii/len_signal,f, sprintf('Computing Theta: %d%%', floor(ii/len_signal*100)))
        ek = zeros(1, len_signal);
        ek(ii) = 1;
        Psi = idct(ek)';
        Theta(:, ii) = Phi * Psi;
    end
    
    close(f)
    
    s = zhangpassivegamma(Theta, responses, Gamma);

    f = waitbar(0,'Computing x');

    x = zeros(len_signal, 1);
    for ii = 1:len_signal
        waitbar(ii/len_signal,f, sprintf('Computing x: %d%%', floor(ii/len_signal*100)))
        ek = zeros(1, len_signal);
        ek(ii) = 1;
        Psi = idct(ek)';
        x = x + Psi * s(ii);
    end

    close(f)
end