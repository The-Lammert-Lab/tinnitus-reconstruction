# Norena Binned Stimulus Generation

This is a stimulus generation class in which 
stimuli are formed by filling the bin that houses one randomly chosen frequency.

### Unique Properties

This stimulus generation method has no properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes.

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
``` 

Generate a stimulus vector of length `self.nfft+1`
where the bin of a randomly chosen frequency is filled.

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
- min_freq
- max_freq
- filled_dB
- unfilled_dB
```



