# Uniform Prior Rand N Bins Stimulus Generation

This is a stimulus generation class in which the number of tonotopic bins 
is randomly decided from a value in `n_bins_range` then 
filled according to the `UniformPrior` method but where `min_bins = 1` and `max_bins = n_bins`.

### Unique Properties

This stimulus generation class has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```matlab
- n_bins_range = 2.^(2:7) % Possible values for n_bins to be randomly assigned
```

### generate_stimuli_matrix

```matlab
[stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)
```

Unique function for `UniformPriorRandomNBinsStimulusGeneration`
Since self.n_bins is changed at each `generate_stimulus()` call,
this function pads the matrix with NaN values.
Generates a matrix of stimuli.
Explicitly calls the `generate_stimulus()`
class method.

**OUTPUTS:**

- stimuli_matrix: `n x self.n_trials` numerical vector,
the stimulus waveform,
where `n` is `self.nfft + 1`.

- Fs: `1x1` numerical scalar,
the sample rate in Hz.

- spect_matrix: `m x self.n_trials` numerical vector,
the half-spectrum,
where `m` is `self.nfft / 2`,
in dB.

- binned_repr_matrix: `self.n_bins x self.n_trials` numerical vector,
the binned representation.



!!! info "See Also"
    * [UniformPriorRandomNBinsStimulusGeneration.generate_stimulus](../UniformPriorRandomNBinsStimulusGeneration/#generate_stimulus)





-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```
Generates a stimulus vector by randomly assigning `self.n_bins`
and filling the spectrum as in `UniformPriorStimulusGeneration`, 
where `self.min_bins = 1` and `self.max_bins = self.n_bins`.

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
- n_bins_range
- unfilled_dB
- filled_dB
```



!!! info "See Also"
    * [UniformPriorRandomNBinsStimulusGeneration.generate_stimuli_matrix](../UniformPriorRandomNBinsStimulusGeneration/#generate_stimuli_matrix)



