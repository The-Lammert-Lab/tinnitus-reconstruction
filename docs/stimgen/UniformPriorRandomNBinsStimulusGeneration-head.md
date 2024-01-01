# Uniform Prior Rand N Bins Stimulus Generation

This is a stimulus generation class in which the number of tonotopic bins 
is randomly decided from a value in `n_bins_range` then 
filled according to the `UniformPrior` method but where `min_bins = 1` and `max_bins = n_bins`.

### Unique Properties

This stimulus generation class has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```matlab
- n_bins_range = 2.^(2:7) % Possible values for n_bins to be randomly assigned
```