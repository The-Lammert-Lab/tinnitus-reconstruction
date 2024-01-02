# Uniform Noise No Bins Stimulus Generation

This is a stimulus generation class in which each frequency is chosen from a uniform distribution on `[-20, 0]` dB. This class does not work with binned representations of the stimuli.

### Unique Properties

This stimulus generation class *does not* have any unique properties in addition to those inhereted from the [Abstract](../AbstractStimulusGenerationMethod) class.

### generate_stimulus

Generate stimuli using a binless white-noise process
with amplitudes randomly distributed between -20 and 0 dB.

**OUTPUTS:**

stim: `self.nfft + 1 x 1` numerical vector,
the stimulus waveform,

Fs: `1x1` numerical scalar,
the sample rate in Hz.

spect: `self.nfft / 2 x 1` numerical vector,
the half-spectrum, in dB.

binned_repr: `[]`, empty because this is not a binned class.



