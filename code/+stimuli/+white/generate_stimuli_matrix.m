function [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(options)
    % Generate a matrix of stimuli,
    % where the matrix is of size nfft x n_trials.
    
    arguments
        options.min_freq (1,1) {mustBeNumeric} = 100
        options.max_freq (1,1) {mustBeNumeric} = 22e3
        options.n_bins (1,1) {mustBeNumeric} = 100
        options.bin_duration (1,1) {mustBeNumeric} = 0.4
        options.n_trials (1,1) {mustBeNumeric} = 80
    end

    % generate first stimulus
    binned_repr_matrix = zeros(options.n_bins, options.n_trials);
    [stim1, Fs, spect, binned_repr_matrix(:, 1)] = stimuli.white.generate_stimuli(...
        'min_freq', options.min_freq, ...
        'max_freq', options.max_freq, ...
        'n_bins', options.n_bins, ...
        'bin_duration', options.bin_duration);

    % instantiate stimuli matrix
    stimuli_matrix = zeros(length(stim1), options.n_trials);
    spect_matrix = zeros(length(spect), options.n_trials);
    stimuli_matrix(:, 1) = stim1;
    spect_matrix(:, 1) = spect;
    for ii = 2:options.n_trials
        [stimuli_matrix(:, ii), ~, spect_matrix(:, ii), binned_repr_matrix(:, ii)] = stimuli.white.generate_stimuli(...
            'min_freq', options.min_freq, ...
            'max_freq', options.max_freq, ...
            'n_bins', options.n_bins, ...
            'bin_duration', options.bin_duration);
    end
