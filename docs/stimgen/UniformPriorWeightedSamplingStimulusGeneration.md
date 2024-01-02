# Uniform Prior Weighted Sampling Stimulus Generation

This is a stimulus generation class in which the number of filled bins is selected from a uniform distribution on `[min_bins, max_bins]`, but which bins are filled is determined by a non-uniform distribution. 

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```
- bin_probs = [] % Assigned via `set_bin_probs()`
- alpha_ = 1
```

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generates a stimulus by generating a frequency spectrum 
with `self.unfilled_dB` and `self.filled_dB` dB amplitudes. 
The number of filled bins is selected
from a uniform distribution on `[self.min_bins, self.max_bins]`, 
but which bins are filled is determined from a non-uniform distribution.

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
```



!!! info "See Also"
    * [UniformPriorWeightedSamplingStimulusGeneration.sample](../UniformPriorWeightedSamplingStimulusGeneration/#sample)





-------

### UniformPriorWeightedSamplingStimulusGeneration
class constructor





-------

### get_bin_occupancy

```matlab
bin_occupancy = self.get_bin_occupancy();
```

Compute the bin occupancy,
which is a ``self.n_bins x 1`` vector
which counts the number of unique frequencies in each bin.
This bin occupancy quantity is not related to which bins
are "filled".

**OUTPUTS**

- bin_occupancy: `self.n_bins x 1`
representing the bin occupancy quantity, e.g.
`bin_occupancy(1)` is the occupancy for the first bin.



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../AbstractBinnedStimulusGenerationMethod/#get_freq_bins)





-------

### set_bin_probs

```matlab
self.set_bin_probs()
self.set_bin_probs(1.3)
```

Sets ``self.bin_probs`` equal to
the bin occupancy, exponentiated by ``alpha_``.
If ``alpha_`` is empty, uses the existing ``self.alpha_``
value. Otherwise, ``self.alpha_`` is set as well,
and that value is used.

**ARGUMENTS**

- self: the object
- alpha_: ``1x1`` nonnegative scalar



!!! info "See Also"
    * [UniformPriorWeightedSamplingStimulusGeneration.get_bin_occupancy](../UniformPriorWeightedSamplingStimulusGeneration/#get_bin_occupancy)





-------

### sample

```matlab
filled_bins = self.sample(weights, values)
```

Get a vector of indices referred to bins that should be filled,
by taking successive weighted samples
without replacement from a list of values
with associated weights.

**ARGUMENTS**
- n_bins_to_fill: `1x1` integral scalar indicating how many bins to fill


**OUTPUTS**
- filled_bins: `n_bins_to_fill x 1` vector of bin indices



