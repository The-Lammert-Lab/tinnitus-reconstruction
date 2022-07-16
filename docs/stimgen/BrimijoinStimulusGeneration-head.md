# Brimijoin Stimulus Generation

This is a stimulus generation method in which each tonotopic bin is filled with an amplitude value from an equidistant list with equal probability.

### Unique Properties

This stimulus generation method has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```matlab
- amplitude_values = linspace(-20, 0, 6)
```