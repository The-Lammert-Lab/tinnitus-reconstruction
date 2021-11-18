function [stim, Fs, X, binned_repr] = brimijoin_generate_stimuli(self)
    % Generate a matrix of stimuli
    % where the matrix is of size nfft x n_trials.
    % Bins are filled with an amplitude value chosen from self.amplitude_values
    % with equal probability.


    [binnum, Fs, nfft] = self.get_freq_bins();

    X = zeros(nfft/2, 1);
    binned_repr = zeros(self.n_bins, 1);

    for ii = 1:self.n_bins
        this_amplitude_value = self.amplitude_values(randi(length(self.amplitude_values)));
        binned_repr(ii) = this_amplitude_value;
        X(binnum==ii) = this_amplitude_value;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(X, nfft);