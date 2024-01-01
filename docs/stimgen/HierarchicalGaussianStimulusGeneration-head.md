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