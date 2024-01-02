# Brimijoin Stimulus Generation

This is a stimulus generation class in which each tonotopic bin is filled with an amplitude value from an equidistant list with equal probability.

### Unique Properties

This stimulus generation class has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```matlab
- amplitude_values = linspace(-20, 0, 6) % Possible aplitudes for each bin (dB)
```