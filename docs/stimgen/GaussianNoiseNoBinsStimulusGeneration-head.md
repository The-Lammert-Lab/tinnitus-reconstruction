# Gaussian Noise No Bins Stimulus Generation

This is a stimulus generation class in which each frequency's amplitude is chosen according to a Gaussian distribution. This class cannot work with binned representations.

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) class. Defaults:

```
amplitude_mean = -10 % Mean of the Gaussian from which the amplitude is chosen
amplitude_var = 3 % Variance of the Gaussian from which the amplitude is chosen
```