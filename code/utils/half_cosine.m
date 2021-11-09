function H = half_cosine(f, T)

    idx = abs(f) <= 1/T;

    H = zeros(size(f));
    H(idx) = 1/2 * (1 + cos(pi * f(idx) * T));

end % function