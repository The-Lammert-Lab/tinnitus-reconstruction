# Uniform Prior Stimulus Generation

This is a stimulus generation class in which the number of filled bins is selected from a uniform distribution on `[min_bins, max_bins]`.

### Unique Properties

This stimulus generation class has two unique properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes.

```
- min_bins = 10 % Minimum number of bins that can be filled.
- max_bins = 50 % Maximum number of bins that can be filled.
```