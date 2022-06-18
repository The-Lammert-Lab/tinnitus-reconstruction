# Tinnitus Project

Reconstructing high-dimensional representations of tinnitus using reverse correlation and compressed sensing.

## Configuration files

An experiment is specified by a configuration file.
These are YAML file that generally live in `tinnitus-project/code/experiment/configs/`,
but you can put them anywhere.

A template config file can be found [here](https://github.com/alec-hoyland/tinnitus-project/blob/main/code/experiment/configs/config_template.yaml).
This template file includes inline comments
that describe a sample configuration file
and what fields are available.

In brief,
the following fields are required:

* stimuli_type
* n_trials_per_block
* n_blocks
* subjectID

Other fields include:

* **data_dir**: path to directory where output files from the experiment should be saved
* **stimuli_save_type**: either `waveform`, `spectrum`, or `bins`. Determines in what form
data from the experiment should be saved.
* various stimuli parameters including:
    - **min_freq**: the minimum frequency (in Hz) of the stimuli
    - **max_freq**: the maximum frequency (in Hz) of the stimuli
    - **n_bins**: how many tonotopic bins the stimuli has
    - **duration**: the duration of the stimuli (in seconds)
* stimuli hyperparameters specific to each stimulus generation type (see the
[stimuli](https://github.com/alec-hoyland/tinnitus-project/tree/main/code/stimulus_generation) class definitions for details)

To set parameters in a stimulus generation object, use the `from_config()` method:

```matlab
stimgen = GaussianPriorStimulusGeneration();
stimgen = stimgen.from_config('path/to/config_file.yaml');
```

## Stimulus generation methods

Stimulus generation classes are defined [here](https://github.com/alec-hoyland/tinnitus-project/tree/main/code/stimulus_generation).
All stimulus generation classes inherit from `AbstractStimulusGenerationMethod`.
Non-binned classes inherit directly
and binned classes through the intermediate class `AbstractBinnedStimulusGeneratioMethod`.

### AbstractStimulusGenerationMethod

This class defines common properties of all stimulus generation methods.
They are described here in brief with default values, e.g., `property_name = default_value`.
They include:

* `min_freq = 100`: the minimum frequency of stimuli generated by this method (Hz).
* `max_freq = 22000`: the maximum frequency of stimuli generated by this method (Hz).
* `duration = 0.5`: the duration of stimuli generation by this method (seconds).
* `n_trials = 100`: the number of trials in a single block.
* `Fs = 44100`: the sample frequency of the stimuli generated by this method (samples/sec).


Methods:
* `[y, spect, binned_repr] = subject_selection_process(self, signal)`
* `[stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)`
* `freq = get_freq(self)`
* `self = from_config(self, options)`
* `stim = synthesize_audio(X, nfft)`

### AbstractBinnedStimulusGenerationMethod

This abstract class includes one additional property, `n_bins`.

Methods:
* `[binnum, Fs, nfft, frequency_vector] = get_freq_bins(self)`
* `spect = get_empty_spectrum(self)`
* `binned_repr = spect2binnedrepr(self, T)`
* `T = binnedrepr2spect(self, binned_repr)`

### StimulusGeneration classes

Any `StimulusGeneration` class such as `GaussianPriorStimulusGeneration`
includes the `generate_stimulus` method.

```matlab
[stim, Fs, X, binned_repr] = generate_stimulus(self)
```

## Running an experiment

The `Protocol` function runs an experiment. You can invoke it two ways:

```matlab
Protocol()
Protocol('config', 'path_to_config_file')
```

In the first case, a dialog box opens and asks you to select a `.yaml` config file.
In the second case, you specify the path to a config file directly.

## Collecting data

Data are saved in `config.data_dir` which is usually
`tinnitus-project/code/experiment/Data`.
Each block has a separate stimuli and response file saved for it,
labeled by the subject ID and a unique hash.

You can use the `collect_data` function to gather the data into output matrices.

```matlab
[responses, stimuli] = collect_data('config', 'path_to_config_file');
```

## Tinnitus representation reconstruction

You can use compressed sensing (`cs`), compressed sensing without a basis (`cs_no_basis`) or linear regression (`gs`).

Then do:

```matlab
[x, responses_output, stimuli_matrix_output] = get_reconstruction(...
    'config_file', 'path/to/config_file.yaml', ...
    'preprocessing', {'bins'}, ...
    'method', 'cs' ...
)
```

## Installing

For most users, it is best to install the MATLAB toolbox from the latest [Release](https://github.com/alec-hoyland/tinnitus-project/releases#latest).
For development, clone the following projects:

* [mtools](https://github.com/sg-s/srinivas.gs_mtools)
* [tinnitus-project](https://github.com/alec-hoyland/tinnitus-project)
* [ReadYAML](https://github.com/llerussell/ReadYAML)

Then add the functions to your path. The commands should look similar to this:

```matlab
addpath ~/code/ReadYAML
addpath ~/code/srinivas.gs_mtools/src
savepath
```

Finally, in the `tinnitus-project/code` directory,
run `setup.m` as a MATLAB script.
