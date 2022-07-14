# Bernoulli Stimulus Generation

This is a stimulus generation method in which each tonotopic bin has a probability `p` of being at 0 dB, otherwise it is at -20 dB. 

### Unique Properties

This stimulus generation method has one property in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Default:

```
- bin_prob = 0.3
```