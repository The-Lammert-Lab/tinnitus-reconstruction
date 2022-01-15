function [stim, Fs, X, binned_repr] = bernoulli_generate_stimuli(self)
    % Generate a matrix of stimuli
    % where the matrix is of size nfft x n_trials.
    % Bins are filled with an an amplitude of -20 or 0.
    % Each bin is randomly filled with a change of being filled
    % (amplitude = 0) with a probability of `self.bin_prob`.
    %
    % Class Properties Used
    %   n_bins
    %   bin_prob

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft] = self.get_freq_bins();

    % fill the bins
    X = zeros(nfft/2, 1);
    binned_repr = zeros(self.n_bins, 1);
    
    % get the amplitude values
    amplitude_values = -20 * ones(self.n_bins, 1);
    amplitude_values(rand(self.n_bins, 1) < self.bin_prob) = 0;

    for ii = 1:self.n_bins
        binned_repr(ii) = amplitude_values(ii);
        X(binnum==ii) = amplitude_values(ii);
    end

    % Synthesize Audio
    stim = self.synthesize_audio(X, nfft);

end % function
