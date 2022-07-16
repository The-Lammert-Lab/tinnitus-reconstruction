# Gaussian Noise No Bins Stimulus Generation

This is a stimulus generation method in which each frequency's amplitude is chosen according to a Gaussian distribution. This class cannot work with binned representations.

### Unique Properties

This stimulus generation method has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) class. Defaults:

```
amplitude_mean = -10
amplitude_var = 3
```

-------

### generate_stimulus

Generate stimuli using a binless white-noise process.

Class Properties Used:

```
- amplitude_mean
- amplitude_var
```



