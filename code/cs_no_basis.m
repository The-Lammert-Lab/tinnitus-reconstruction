function [x, s] = cs_no_basis(responses, Phi, Gamma)

    if nargin < 3
        Gamma = 32;
    end
        
    len_signal = size(Phi, 2);

    Theta = Phi;

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