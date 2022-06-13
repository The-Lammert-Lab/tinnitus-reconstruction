function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % Generate a matrix of stimuli
    % where the matrix is of size nfft x n_trials.
    % Bins are filled with an amplitude value chosen randomly.
    % from a Gaussian distribution.
    %
    % Class Properties Used
    %   n_bins
    %   amplitude_mean
    %   amplitude_var

    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();
    binned_repr = zeros(self.n_bins, 1);

    for ii = 1:self.n_bins
        this_amplitude_value = self.amplitude_mean + self.amplitude_var * randn();
        binned_repr(ii) = this_amplitude_value;
        spect(binnum==ii) = this_amplitude_value;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

end % function
