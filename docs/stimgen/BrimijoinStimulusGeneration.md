# Brimijoin Stimulus Generation

This is a stimulus generation method in which each tonotopic bin is filled with an amplitude value from an equidistant list with equal probability.

### Unique Properties

This stimulus generation method has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```matlab
- amplitude_values = linspace(-20, 0, 6)
```

-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generate a matrix of stimuli.
Bins are filled with an amplitude value chosen from self.amplitude_values
with equal probability.

**OUTPUTS:**

stim: `n x 1` numerical vector,
the stimulus waveform,
where `n` is `self.get_nfft() + 1`.

Fs: `1x1` numerical scalar,
the sample rate in Hz.

spect: `m x 1` numerical vector,
the half-spectrum,
where m is `self.get_nfft() / 2`,
in dB.

binned_repr: `self.n_bins x 1` numerical vector,
the binned representation.

frequency_vector: `m x 1` numerical vector,
the frequencies associated with the spectrum,
where `m` is `self.get_nfft() / 2`,
in Hz.

Class Properties Used:

```
n_bins
amplitude_values
```



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)



