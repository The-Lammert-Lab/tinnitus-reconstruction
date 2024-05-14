# Brimijoin Gaussian Smoothed Stimulus Generation

This is a stimulus generation class in which each tonotopic bin is filled by a Gaussian 
with a maximum amplitude value chosen from an equidistant list with equal probability.

### Unique Properties

This stimulus generation class has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```matlab
- amplitude_values = linspace(-20, 0, 6) % Possible aplitudes for each bin (dB)
```


-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generate a stimulus vector of length `self.nfft+1`.
Each bin is filled between `self.unfilled_dB` and `0` 
using a Gaussian power distribution rather than rectangular bins.

**OUTPUTS:**

stim: `self.nfft + 1 x 1` numerical vector,
the stimulus waveform,

Fs: `1x1` numerical scalar,
the sample rate in Hz.

spect: `self.nfft / 2 x 1` numerical vector,
the half-spectrum, in dB.

binned_repr: `self.n_bins x 1` numerical vector,
the binned representation.

frequency_vector: `self.nfft / 2 x 1` numerical vector,
the frequencies associated with the spectrum, in Hz.

**Class Properties Used:**

```
n_bins
amplitude_values
```



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)



