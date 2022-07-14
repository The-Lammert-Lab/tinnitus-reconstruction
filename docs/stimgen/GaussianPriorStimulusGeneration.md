# Gaussian Prior Stimulus Generation

This is a stimulus generation method in which the number of filled bins is selected from a Gaussian distribution with known mean and variance parameters.

-------

### generate_stimulus

[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)


Generate a vector of stimuli where
the bin amplitudes are -20 dB for an unfilled bin
and 0 dB for a filled bin.
Filled bins are chosen uniformly from unfilled bins, one at a time.
The total number of bins-to-be-filled is chosen from a Gaussian distribution.

Returns:
stim: n x 1 numerical vector
The stimulus waveform,
where n is self.get_nfft() + 1.
Fs: 1x1 numerical scalar
The sample rate in Hz.
spect: m x 1 numerical vector
The half-spectrum,
where m is self.get_nfft() / 2,
in dB.
binned_repr: self.n_bins x 1 numerical vector
The binned representation.
frequency_vector: m x 1 numerical vector
The frequencies associated with the spectrum,
where m is self.get_nfft() / 2,
in Hz.

Class Properties Used:
n_bins
n_bins_filled_mean
n_bins_filled_var



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)


