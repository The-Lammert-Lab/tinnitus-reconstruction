# Abstract Binned Stimulus Generation Method 
 
Abstract class describing all features common to a stimulus generation method that uses a binned representation of the signal.

### Abstract Properties

These properties are automatically instantiated for subclasses, since they are not abstract themselves. Default values are given:

```
- n_bins = 100 % The number of bins to break the frequency spectrum into 
- unfilled_dB = -100 % The dB value of "unfilled" bins
- filled_dB = 0 % The dB value of "filled" bins
```