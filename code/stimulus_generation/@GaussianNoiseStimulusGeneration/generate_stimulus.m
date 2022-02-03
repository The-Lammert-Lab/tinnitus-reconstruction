function [stim, Fs, X, binned_repr] = generate_stimulus(self)
    % Generate a matrix of stimuli
    % where the matrix is of size nfft x n_trials.
    % Bins are filled with an amplitude value chosen randomly.
    % from a Gaussian distribution.
    %
    % Class Properties Used
    %   n_bins
    %   amplitude_mean
    %   amplitude_var

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft] = self.get_freq_bins();

    % fill the bins
    X = zeros(nfft/2, 1);
    binned_repr = zeros(self.n_bins, 1);

    for ii = 1:self.n_bins
        this_amplitude_value = self.amplitude_mean + self.amplitude_var * randn();
        binned_repr(ii) = this_amplitude_value;
        X(binnum==ii) = this_amplitude_value;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(X, nfft);

end % function
