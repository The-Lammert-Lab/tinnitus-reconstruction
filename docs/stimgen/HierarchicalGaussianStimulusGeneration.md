# Hierarchical Gaussian Stimulus Generation

This is a stimulus generation class in which 
stimuli are formed by applying random weights to a 
basis of Gaussians described by the class properties.

### Unique Properties

This stimulus generation method has seven properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
- n_broad = 3 % Number of "wide" Gaussians in the basis
- n_med = 8 % Number of "medium" Gaussians in the basis 
- n_narrow = 6 % Number of "narrow" Gaussians in the basis
- broad_std = 8000 % Standard deviation of the "wide" Gaussians
- med_std = 2000 % Standard deviation of the "medium" Gaussians
- narrow_std = 100 % Standard deviation of the "narrow" Gaussians
- scale_fact = 40 % Max power (dB)
```

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr, w] = generate_stimulus(self)
```

Generate a stimulus by applying random weights to a basis of Gaussians.

**OUTPUTS:**

stim: `self.nfft + 1 x 1` numerical vector,
the stimulus waveform,

Fs: `1x1` numerical scalar,
the sample rate in Hz.

spect: `self.nfft / 2 x 1` numerical vector,
the half-spectrum, in dB.

binned_repr: `[]`, empty because this is not a binned class.

w: `self.n_broad + self.n_med + self.n_narrow x 1` numerical vector,
the weight vector corresponding to the each curve.

**Class Properties Used:**

```
- scale_fact
```



!!! info "See Also"
    * [HierarchicalGaussianStimulusGeneration.get_basis](../HierarchicalGaussianStimulusGeneration/#get_basis)
    * [AbstractStimulusGenerationMethod.generate_stimuli_matrix](../AbstractStimulusGenerationMethod/#generate_stimuli_matrix)





-------

### get_basis

```matlab
B = self.get_basis();
```

Generate a basis vector from the Gaussians stored in the class.

**OUTPUTS:**

B: `self.nfft / 2 x self.n_broad + self.n_med + self.n_narrow` numerical array,
Gaussian distributions for each type specified in the class fields

**Class Properties Used:**

```
- n_broad
- n_med
- n_narrow
- broad_std
- med_std
- narrow_std
```



