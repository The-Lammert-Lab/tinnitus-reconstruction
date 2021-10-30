function [stim, Fs, X, binned_repr] = generate_stimuli(options)
    % Generate a matrix of stimuli
    % where the matrix is of size nfft x n_trials.
    % Bins are filled with an amplitude value chosen from options.amplitude_values
    % with equal probability.

    arguments
        options.min_freq (1,1) {mustBeNumeric} = 100
        options.max_freq (1,1) {mustBeNumeric} = 22e3
        options.n_bins (1,1) {mustBeNumeric} = 100
        options.bin_duration (1,1) {mustBeNumeric} = 0.4
        % options.prob_f (1,1) {mustBeNumeric} = 0.4
        % options.n_trials (1,1) {mustBeNumeric} = 80
    end

    % Define Frequency Bin Indices 1 through options.n_bins
    [binnum, Fs, nfft] = stimuli.get_freq_bins(...
        'min_freq', options.min_freq, ...
        'max_freq', options.max_freq, ...
        'bin_duration', options.bin_duration, ...
        'n_bins', options.n_bins);

    % fill the bins
    X = zeros(nfft/2, 1);
    binned_repr = zeros(options.n_bins, 1);

    for ii = 1:options.n_bins
        this_amplitude_value = -20 * rand();
        binned_repr(ii) = this_amplitude_value;
        X(binnum==ii) = this_amplitude_value;
    end

    % Synthesize Audio
    stim = stimuli.synthesize_audio(X, nfft);

end % function