function [y, X] = subject_selection_process2(options)

    arguments
        options.signal {mustBeNumeric}
        options.n_samples (1,1) {mustBeNumeric} = 1000
        options.frequencies_est {mustBeNumeric}
        options.frequencies_true {mustBeNumeric}
        options.threshold (1,1) {mustBeNumeric} = 0.2
        options.config
    end

    X = generate_stimuli_matrix(...
        'min_freq', options.config.min_freq, ...
        'max_freq', options.config.max_freq, ...
        'n_bins', options.config.n_bins, ...
        'bin_duration', options.config.bin_duration, ...
        'n_trials', options.n_samples, ...
        'n_bins_filled_mean', options.config.n_bins_filled_mean, ...
        'n_bins_filled_var', options.config.n_bins_filled_var);
    X = signal2spect(X);
    
    keyboard
    stimuli_interp = interp1(options.frequencies_true, X, options.frequencies_est);

    r2 = corr(options.signal, stimuli_interp);
    
    y = ones(size(r2));
    y(r2 < options.threshold) = -1;

