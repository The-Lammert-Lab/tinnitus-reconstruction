# Bernoulli Stimulus Generation

This is a stimulus generation method in which each tonotopic bin has a probability `p` of being at 0 dB, otherwise it is at -20 dB. 

### Unique Properties

This stimulus generation method has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```
- bin_prob = 0.3
```

-------

### generate_stimulus

```matlab
[stim, Fs, X, binned_repr] = generate_stimulus(self)
```

Generate a matrix of stimuli
where the matrix is of size nfft x n_trials.
Bins are filled with an an amplitude of -20 or 0.
Each bin is randomly filled with a change of being filled
(amplitude = 0) with a probability of `self.bin_prob`.

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
bin_prob
```



