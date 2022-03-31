function g = get_gamma(n_bins)
    g = min([32, floor(n_bins/4)]);
end