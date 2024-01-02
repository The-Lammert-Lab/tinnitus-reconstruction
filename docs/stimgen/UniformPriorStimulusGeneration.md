# Uniform Prior Stimulus Generation

This is a stimulus generation class in which the number of filled bins is selected from a uniform distribution on `[min_bins, max_bins]`.

### Unique Properties

This stimulus generation class has two unique properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes.

```
- min_bins = 10 % Minimum number of bins that can be filled.
- max_bins = 50 % Maximum number of bins that can be filled.
```

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generates a stimulus by generating a frequency spectrum 
with `self.unfilled_dB` and `self.filled_dB` dB amplitudes. 
The number of filled bins is selected
from a uniform distribution on `[self.min_bins, self.max_bins]`.

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
```



