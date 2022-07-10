# Abstract Stimulus Generation Method

Abstract class describing all features common a stimulus generation method.
Properties common to all stimulus generation methods. These are automatically instantiated for subclasses, since they are not abstract themselves.

The generate_stimulus method is common to every stimulus generation type. 

### subject_selection_process

[y, spect, binned_repr] = subject_selection_process(self, signal)

Model of a subject performing the task.
Takes in a signal (the gold standard)
and returns an n_samples x 1 vector
of -1 for "no"
and 1 for "yes"





### generate_stimuli_matrix

[stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)

Generates a matrix of stimuli.
Explicitly calls the `generate_stimulus()`
class method.

Returns:
stim: n x self.n_trials numerical vector
The stimulus waveform,
where n is self.get_nfft() + 1.

Fs: 1x1 numerical scalar
The sample rate in Hz.

spect: m x self.n_trials numerical vector
The half-spectrum,
where m is self.get_nfft() / 2,
in dB.

binned_repr: self.n_bins x self.n_trials numerical vector
The binned representation.

frequency_vector: m x self.n_trials numerical vector
The frequencies associated with the spectrum,
where m is self.get_nfft() / 2,
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
    * [ReadYaml](https://github.com/llerussell/ReadYAML/blob/master/ReadYaml.m)





### synthesize_audio
Synthesize audio from spectrum, X.



