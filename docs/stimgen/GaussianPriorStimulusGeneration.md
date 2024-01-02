# Gaussian Prior Stimulus Generation

This is a stimulus generation class in which the number of filled bins is selected from a Gaussian distribution with known mean and variance parameters.

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
- n_bins_filled_mean = 20 % Mean of the Gaussian from which number of filled bins is selected.
- n_bins_filled_var = 1 % Variance of the Gaussian from which number of filled bins is selected.
```

-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generate a stimulus vector of length `self.nfft+1`.
the bin amplitudes are `self.unfilled_dB` for an unfilled bin
and `self.filled_dB` for a filled bin.
Filled bins are chosen uniformly from unfilled bins, one at a time.
The total number of bins-to-be-filled is chosen from a Gaussian distribution.

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
- n_bins
- n_bins_filled_mean
- n_bins_filled_var
- unfilled_dB
- filled_dB
```



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)



