# Gaussian Prior Stimulus Generation

This is a stimulus generation method in which the number of filled bins is selected from a Gaussian distribution with known mean and variance parameters.

### Unique Properties

This stimulus generation method has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
- n_bins_filled_mean = 20
- n_bins_filled_var = 1
```