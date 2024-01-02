# Uniform Prior Weighted Sampling Stimulus Generation

This is a stimulus generation class in which the number of filled bins is selected from a uniform distribution on `[min_bins, max_bins]`, but which bins are filled is determined by a non-uniform distribution. 

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```
- bin_probs = [] % Assigned via `set_bin_probs()`
- alpha_ = 1
```