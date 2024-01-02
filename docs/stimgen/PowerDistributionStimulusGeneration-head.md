# Power Distribution Stimulus Generation

This is a stimulus generation class in which the frequencies in each bin are sampled from a power distribution learned from tinnitus examples. 

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) and [Abstract Binned](../AbstractBinnedStimulusGenerationMethod) classes. Defaults:

```
distribution = [] % The power distribution
distribution_filepath = '' % Path to the distribution file
```