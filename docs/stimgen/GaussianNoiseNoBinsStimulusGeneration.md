# Gaussian Noise No Bins Stimulus Generation

This is a stimulus generation class in which each frequency's amplitude is chosen according to a Gaussian distribution. This class cannot work with binned representations.

### Unique Properties

This stimulus generation class has two properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) class. Defaults:

```
amplitude_mean = -10 % Mean of the Gaussian from which the amplitude is chosen
amplitude_var = 3 % Variance of the Gaussian from which the amplitude is chosen
```

-------

### generate_stimulus

```matlab
[stim, Fs, spect, binned_repr] = generate_stimulus(self)
```

Generate a stimulus using a binless white-noise process.

**OUTPUTS:**

stim: `self.nfft + 1 x 1` numerical vector,
the stimulus waveform,

Fs: `1x1` numerical scalar,
the sample rate in Hz.

spect: `self.nfft / 2 x 1` numerical vector,
the half-spectrum, in dB.

binned_repr: `[]`, empty because this is not a binned class.

**Class Properties Used:**

```
- amplitude_mean
- amplitude_var
```



