# Abstract Stimulus Generation Method

This is an abstract class describing all features common to a stimulus generation method. In addition to these features, the `generate_stimulus` method is common to every stimulus generation type. Furthermore this abstract class contains properties common to all stimulus generation methods. 

### Abstract Properties

These are automatically instantiated for subclasses, since they are not abstract themselves. Default values are shown here:

```
- min_freq = 100
- max_freq = 22e3
- duration = 0.5
- n_trials = 100
- Fs = 44.1e3
```