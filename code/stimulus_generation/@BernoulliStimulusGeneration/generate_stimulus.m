function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % 
    %   [stim, Fs, X, binned_repr] = generate_stimulus(self)
    % 
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
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();
    binned_repr = zeros(self.n_bins, 1);
    
    % get the amplitude values
    amplitude_values = -20 * ones(self.n_bins, 1);
    amplitude_values(rand(self.n_bins, 1) < self.bin_prob) = 0;

    for ii = 1:self.n_bins
        binned_repr(ii) = amplitude_values(ii);
        spect(binnum==ii) = amplitude_values(ii);
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

end % function
