# Gaussian Prior Stimulus Generation

This is a stimulus generation class in which the number of filled bins is selected from a Gaussian distribution with known mean and variance parameters.

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
- n_bins_filled_mean = 20 % Mean of the Gaussian from which number of filled bins is selected.
- n_bins_filled_var = 1 % Variance of the Gaussian from which number of filled bins is selected.
```