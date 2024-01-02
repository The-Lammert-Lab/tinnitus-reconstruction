# Bernoulli Stimulus Generation

This is a stimulus generation class in which each tonotopic bin has a probability `bin_prob` of being filled. 

### Unique Properties

This stimulus generation class has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```
- bin_prob = 0.3 % Probability of a bin being filled
```

-------

### generate_stimulus

```matlab
[stim, Fs, X, binned_repr] = generate_stimulus(self)
```

Generate a stimulus vector of length `self.nfft+1`.
Bins are filled with an an amplitude of `self.unfilled_dB` or `self.filled_dB`.
Each bin is randomly filled with a change of being filled
(amplitude = 0) with a probability of `self.bin_prob`.

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
bin_prob
unfilled_dB
filled_dB
```



