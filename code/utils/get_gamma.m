function g = get_gamma(n_bins)
    g = get_highest_power_of_2(max([1, floor(n_bins / 3)]));
end