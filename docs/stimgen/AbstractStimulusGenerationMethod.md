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

### subject_selection_process

```matlab
[y, spect, binned_repr] = subject_selection_process(self, signal)
```

Model of a subject performing the task.
Takes in a signal (the gold standard)
and returns an `n_samples x 1` vector
of `-1` for "no"
and `1` for "yes".





### generate_stimuli_matrix

```matlab
[stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)
```

Generates a matrix of stimuli.
Explicitly calls the `generate_stimulus()`
class method.

**OUTPUTS:**

- stim: `n x self.n_trials` numerical vector,
the stimulus waveform,
where `n` is `self.get_nfft() + 1`.

- Fs: `1x1` numerical scalar,
the sample rate in Hz.

- spect: `m x self.n_trials` numerical vector,
the half-spectrum,
where `m` is `self.get_nfft() / 2`,
in dB.

- binned_repr: `self.n_bins x self.n_trials` numerical vector,
the binned representation.

- frequency_vector: `m x self.n_trials` numerical vector,
the frequencies associated with the spectrum,
where `m` is `self.get_nfft() / 2`,
in Hz.



!!! info "See Also"
    * [BernoulliStimulusGeneration.generate_stimulus](../BernoulliStimulusGeneration/#generate_stimulus)
    * [BrimijoinStimulusGeneration.generate_stimulus](../BrimijoinStimulusGeneration/#generate_stimulus)
    * [GaussianNoiseNoBinsStimulusGeneration.generate_stimulus](../GaussianNoiseNoBinsStimulusGeneration/#generate_stimulus)
    * [GaussianNoiseStimulusGeneration.generate_stimulus](../GaussianNoiseStimulusGeneration/#generate_stimulus)
    * [GaussianPriorStimulusGeneration.generate_stimulus](../GaussianPriorStimulusGeneration/#generate_stimulus)
    * [PowerDistributionStimulusGeneration.generate_stimulus](../PowerDistributionStimulusGeneration/#generate_stimulus)
    * [UniformNoiseNoBinsStimulusGeneration.generate_stimulus](../UniformNoiseNoBinsStimulusGeneration/#generate_stimulus)
    * [UniformNoiseStimulusGeneration.generate_stimulus](../UniformNoiseStimulusGeneration/#generate_stimulus)
    * [UniformPriorStimulusGeneration.generate_stimulus](../UniformPriorStimulusGeneration/#generate_stimulus)





### from_config

Set properties from a struct holding config options.



!!! info "See Also"
    * [* yaml.loadFile](../* yaml/#loadfile)





### synthesize_audio
Synthesize audio from spectrum, X.



