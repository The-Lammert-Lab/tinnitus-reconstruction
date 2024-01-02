# Gaussian Noise Stimulus Generation 

This is a stimulus generation class in which each tonotopic bin is filled with amplitude chosen from a Gaussian distribution. This class can work with binned representations of the signals. 

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
amplitude_mean = -10 % Mean of the Gaussian from which the amplitude is chosen
amplitude_var = 3 % Variance of the Gaussian from which the amplitude is chosen
```

-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
``` 

Generate a stimulus vector of length `self.nfft+1`.
Bins are filled with an amplitude value chosen randomly.
from a Gaussian distribution.

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
- amplitude_mean
- amplitude_var
```



