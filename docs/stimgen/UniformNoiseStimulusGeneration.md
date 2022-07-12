# Uniform Noise Stimulus Generation

This class does not have any unique properties as it's purpose is to generate a uniformly noisy stimulus signal. This class can work with binned representations of the stimuli.  

-------

### generate_stimulus

[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)


Generate a vector of stimuli where
the bin amplitudes are chosen randomly
from a uniform distribution over [-20, 0] dB.

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



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)



