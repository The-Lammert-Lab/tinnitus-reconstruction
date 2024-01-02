# Abstract Stimulus Generation Method

This is an abstract class describing all features common to a stimulus generation method. In addition to these features, the `generate_stimulus` method is common to every stimulus generation type. Furthermore, this abstract class contains properties common to all stimulus generation methods. 

### Abstract Properties

These are automatically instantiated for subclasses, since they are not abstract themselves. Default values are shown here:

```
- min_freq = 100 % The minimum frequency a stimulus can have (Hz)
- max_freq = 22e3 % The maximum frequency a stimulus can have (Hz)
- duration = 0.5 % The duration of each stimulus (sec)
- n_trials = 100 % The number of trials to generate
- Fs = 44.1e3 % The sampling rate (Hz)
```

### subject_selection_process

```matlab
[y, spect, binned_repr] = subject_selection_process(self, signal)
```

Model of a subject performing the task.
Takes in a signal (the gold standard)
and returns a `self.n_trials x 1` vector
of `-1` for "no"
and `1` for "yes".





-------

### generate_stimuli_matrix

```matlab
[stimuli_matrix, Fs, spect_matrix, binned_repr_matrix, W] = generate_stimuli_matrix(self)
```

Generates a matrix of stimuli.
Explicitly calls the `generate_stimulus()`
class method.

**OUTPUTS:**

- stimuli_matrix: `n x self.n_trials` numerical vector,
the stimulus waveform,
where `n` is `self.nfft + 1`.
- Fs: `1x1` numerical scalar,
the sample rate in Hz.
- spect_matrix: `m x self.n_trials` numerical vector,
the half-spectrum,
where `m` is `self.nfft / 2`,
in dB.
- binned_repr_matrix: `self.n_bins x self.n_trials` numerical vector,
the binned representation.
- W: `p x self.n_trials` or `[]`,
where `p` is the size of the weight matrix.
Only full if `self` is `HierarchicalGaussianStimulusGeneration`.



!!! info "See Also"
    * [BernoulliStimulusGeneration.generate_stimulus](../BernoulliStimulusGeneration/#generate_stimulus)
    * [BrimijoinStimulusGeneration.generate_stimulus](../BrimijoinStimulusGeneration/#generate_stimulus)
    * [BrimijoinGaussianSmoothedStimulusGeneration.generate_stimulus](../BrimijoinGaussianSmoothedStimulusGeneration/#generate_stimulus)
    * [GaussianNoiseNoBinsStimulusGeneration.generate_stimulus](../GaussianNoiseNoBinsStimulusGeneration/#generate_stimulus)
    * [GaussianNoiseStimulusGeneration.generate_stimulus](../GaussianNoiseStimulusGeneration/#generate_stimulus)
    * [GaussianPriorStimulusGeneration.generate_stimulus](../GaussianPriorStimulusGeneration/#generate_stimulus)
    * [HierarchicalGaussianStimulusGeneration.generate_stimulus](../HierarchicalGaussianStimulusGeneration/#generate_stimulus)
    * [NorenaBinnedStimulusGeneration.generate_stimulus](../NorenaBinnedStimulusGeneration/#generate_stimulus)
    * [NorenaStimulusGeneration.generate_stimulus](../NorenaStimulusGeneration/#generate_stimulus)
    * [PowerDistributionStimulusGeneration.generate_stimulus](../PowerDistributionStimulusGeneration/#generate_stimulus)
    * [UniformNoiseNoBinsStimulusGeneration.generate_stimulus](../UniformNoiseNoBinsStimulusGeneration/#generate_stimulus)
    * [UniformNoiseStimulusGeneration.generate_stimulus](../UniformNoiseStimulusGeneration/#generate_stimulus)
    * [UniformPriorStimulusGeneration.generate_stimulus](../UniformPriorStimulusGeneration/#generate_stimulus)
    * [UniformPriorWeightedSampling.generate_stimulus](../UniformPriorWeightedSampling/#generate_stimulus)





-------

### from_config

Set properties from a struct holding config options.



!!! info "See Also"
    * [yaml.loadFile](https://github.com/MartinKoch123/yaml/blob/master/%2Byaml/loadFile.m)





-------

### synthesize_audio
Synthesize audio from spectrum, `X`.
If `X` is an array, each column is treated as a spectrum.



