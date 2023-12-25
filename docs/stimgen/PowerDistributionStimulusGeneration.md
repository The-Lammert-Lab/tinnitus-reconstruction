# Power Distribution Stimulus Generation

This is a stimulus generation method in which the frequencies in each bin are sampled from a power distribution learned from tinnitus examples. 

### Unique Properties

This stimulus generation method has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
distribution = []
distribution_filepath = ''
```

### build_distribution

Builds the default power distribution from ATA tinnitus sample files.
Saves the distribution as a vector in dB
and the corresponding frequency vector.

**ARGUMENTS:**

- save_path: character vector, 
the path to `.mat` file where distribution should be saved. 
Default:
```matlab
pathlib.join(fileparts(mfilename('fullpath')), 'distribution.mat');
```  

**OUTPUTS:**

- distribution: numeric vector,
the power distribution in dB.



!!! info "See Also"
    * [PowerDistributionStimulusGeneration.from_file](../PowerDistributionStimulusGeneration/#from_file)
    * [PowerDistributionStimulusGeneration.generate_stimulus](../PowerDistributionStimulusGeneration/#generate_stimulus)





-------

### from_file

Loads a power distribution from a `.mat` or `.csv` file into the object.



!!! info "See Also"
    * [PowerDistributionStimulusGeneration.build_distribution](../PowerDistributionStimulusGeneration/#build_distribution)





-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
```

Generates stimuli by assigning the power in each bin
by sampling from a power distribution
learned from ATA tinnitus examples.

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
```



