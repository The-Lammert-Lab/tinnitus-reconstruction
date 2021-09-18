function [x, s] = cs(responses, Phi)
    
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

    Gamma = 32;
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