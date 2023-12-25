# Uniform Prior Stimulus Generation

This is a stimulus generation method in which the number of filled bins is selected from a uniform distribution on `[min_bins, max_bins]`.

### Unique Properties

This stimulus generation method has two unique properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes.

```
- min_bins = 10
- max_bins = 50
```

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
amplitudes based on a tonotopic map of audible frequency perception.

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
- n_bins_filled_mean
- n_bins_filled_var
```



