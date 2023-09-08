function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % Pick a random index (i.e., frequency) and get bin number
    bin_to_fill = binnum(randi(length(binnum(binnum > 0))));

    % Fill the bin
    spect(binnum==bin_to_fill) = 0;

    % Create a vector of unfilled bins and fill the selected one.
    binned_repr = -100*ones(self.n_bins,1);
    binned_repr(bin_to_fill) = 0;

    stim = self.synthesize_audio(spect, nfft);
end
