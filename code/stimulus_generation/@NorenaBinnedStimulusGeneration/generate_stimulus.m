function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % Pick a random index (frequency) and get bin number
    valid_inds = find(frequency_vector >= self.min_freq & frequency_vector <= self.max_freq);
    bin_to_fill = binnum(randi([min(valid_inds), max(valid_inds)]));

    % Fill the bin
    spect(binnum==bin_to_fill) = self.filled_dB;

    % Create a vector of unfilled bins and fill the selected one.
    binned_repr = self.unfilled_dB*ones(self.n_bins,1);
    binned_repr(bin_to_fill) = self.filled_dB;

    stim = self.synthesize_audio(spect, nfft);
end
