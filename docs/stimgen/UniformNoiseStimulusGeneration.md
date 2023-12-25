# Uniform Noise Stimulus Generation

This class does not have any unique properties as it's purpose is to generate a uniformly noisy stimulus signal. This class can work with binned representations of the stimuli.  

### Unique Properties

This stimulus generation method *does not* have any unique properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes.

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```


Generate a vector of stimuli where
the bin amplitudes are chosen randomly
from a uniform distribution over [`self.unfilled_dB`, `self.filled_dB`] dB.

**OUTPUTS:**

- stim: `n x 1` numerical vector,
the stimulus waveform,
where `n` is `self.nfft + 1`.
- Fs: `1x1` numerical scalar,
the sample rate in Hz.
- spect: `m x 1` numerical vector,
the half-spectrum,
where `m` is `self.nfft / 2`,
in dB.
- binned_repr: `self.n_bins x 1` numerical vector,
the binned representation.
- frequency_vector: `m x 1` numerical vector
The frequencies associated with the spectrum,
where `m` is `self.nfft / 2`,
in Hz.

**Class Properties Used:**

```
- n_bins
```



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)



