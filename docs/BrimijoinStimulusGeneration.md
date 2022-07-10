# Brimijoin Stimulus Generation

This is a stimulus generation method in which each tonotopic bin is filled with an amplitude value from an equidistant list with equal probability.

-------

### generate_stimulus

[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)

Generate a matrix of stimuli.
Bins are filled with an amplitude value chosen from self.amplitude_values
with equal probability.

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
amplitude_values



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)



