function s = cs_no_basis(responses, Phi, Gamma)

    if nargin < 3
        Gamma = 32;
    end

    Theta = Phi;

    s = zhangpassivegamma(Theta, responses, Gamma);

end