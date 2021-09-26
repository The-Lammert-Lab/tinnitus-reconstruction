function x = cs(responses, Phi, Gamma)

    %   [x] = cs(responses, Phi)
    %
    % responses is an n x 1 vector
    % Phi is an n x m matrix
    % where n is the number of trials/samples
    % and m is the dimensionality of the stimuli/spectrum/bins

    if nargin < 3
        Gamma = 32;
    end
    
    n_samples = length(responses);
    len_signal = size(Phi, 2);

    Theta = zeros(n_samples, len_signal);
    for ii = 1:len_signal
        ii/len_signal
        ek = zeros(1, len_signal);
        ek(ii) = 1;
        Psi = idct(ek)';
        Theta(:, ii) = Phi * Psi;
    end

    s = zhangpassivegamma(Theta, responses, Gamma);

    x = zeros(len_signal, 1);
    for ii = 1:len_signal
        ii/len_signal
        ek = zeros(1, len_signal);
        ek(ii) = 1;
        Psi = idct(ek)';
        x = x + Psi * s(ii);
    end

end