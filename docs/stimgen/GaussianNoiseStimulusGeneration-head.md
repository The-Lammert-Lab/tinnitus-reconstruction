# Gaussian Noise Stimulus Generation 

This is a stimulus generation method in which each tonotopic bin is filled with amplitude chosen from a Gaussian distribution. This class can work with binned representations of the signals. 

### Unique Properties

This stimulus generation method has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
amplitude_mean = -10
amplitude_var = 3
```