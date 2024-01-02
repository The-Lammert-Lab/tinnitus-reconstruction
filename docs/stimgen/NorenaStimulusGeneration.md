# Norena Stimulus Generation

This is a stimulus generation class in which 
stimuli are formed by assigning one randomly chosen frequency value `0 dB`.

### Unique Properties

This stimulus generation class has no properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) class.

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr] = generate_stimulus(self)
```

Generate a stimulus where one random Hz value is 0dB and the rest are -100dB

**OUTPUTS:**

stim: `self.nfft + 1 x 1` numerical vector,
the stimulus waveform,

Fs: `1x1` numerical scalar,
the sample rate in Hz.

spect: `self.nfft / 2 x 1` numerical vector,
the half-spectrum, in dB.

binned_repr: `[]`, empty because this is not a binned class.



