# Gaussian Noise Stimulus Generation 

This is a stimulus generation method in which each tonotopic bin is filled with amplitude chosen from a Gaussian distribution. This class can work with binned representations of the signals. 

### Unique Properties

This stimulus generation method has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
amplitude_mean = -10
amplitude_var = 3
```

-------

### generate_stimulus

Generate a matrix of stimuli
where the matrix is of size nfft x n_trials.
Bins are filled with an amplitude value chosen randomly.
from a Gaussian distribution.

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

**Class Properties Used:**

```
- n_bins
- amplitude_mean
- amplitude_var
```



