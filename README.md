# Tinnitus Reconstruction via reverse correlation
[![docs-passing](https://img.shields.io/static/v1?label=docs&message=passing&color=green)](https://The-Lammert-Lab.github.io/tinnitus-reconstruction/)
[![paper](https://img.shields.io/badge/paper-IEEE-green)](https://ieeexplore.ieee.org/document/10129035)
[![paper](https://img.shields.io/static/v1?label=paper&message=bioRxiv&color=green)](https://www.biorxiv.org/content/10.1101/2022.12.23.521795v1)

Reconstructing high-dimensional representations of tinnitus using reverse correlation and compressed sensing.

## Installing

For most users, it is best to install the MATLAB toolbox from the latest [Release](https://www.biorxiv.org/content/10.1101/2022.12.23.521795v1).
For development, clone the following projects:

* [mtools](https://github.com/sg-s/srinivas.gs_mtools)
* [tinnitus-reconstruction](https://github.com/The-Lammert-Lab/tinnitus-reconstruction)
* [ReadYAML](https://github.com/llerussell/ReadYAML) (only for legacy use)
* [yaml](https://github.com/MartinKoch123/yaml)

Then add the functions to your path. The commands should look similar to this:

```matlab
addpath ~/code/yaml
addpath ~/code/srinivas.gs_mtools/src
savepath
```

Finally, in the `tinnitus-reconstruction/code` directory,
run `setup.m` as a MATLAB script.

## Quickstart

### Installing

Install the latest [Release](https://github.com/The-Lammert-Lab/tinnitus-reconstruction/releases#latest).

### Running the experiments

There are multiple experiments available in this repository. 
All experiments can be found in the `tinnitus-reconstruction/code/experiment/Protocols` directory.
The published, novel experimental protocol is in `RevCorr.m`. 

To run any experiment, copy the template configuration file found
[here](https://github.com/The-Lammert-Lab/tinnitus-reconstruction/blob/main/code/experiment/configs/config_template.yaml)
and modify it as you see fit.

Then, using a decibel meter (many are available for smartphones),
record the decibel output through the headphones of sound that plays after running the following function:

```matlab
play_calibration_sound()
```

Raise your system volume until the measured dB value is above 95dB.
Save this value in the MATLAB workspace. For example `cal_dB = 97.8;`
Don't worry, no sounds will be played above 65 dB unless made to do so by the user.

Then, run any of the Protocol functions with this measured dB value in your MATLAB prompt.

```matlab
ThresholdDetermination(cal_dB)
LoudnessMatch(cal_dB)
PitchMatch(cal_dB)
RevCorr(cal_dB)
```

The function `RunAllExp(cal_dB)` uses one config file 
to run the protocol functions in the above order, repeating PitchMatch `3` times by default.

### Results

To inspect reverse correlation results from AX (template sound) experiments, run:

```matlab
pilot_reconstruction
reconstruction_viz
```

Use `patient_reconstructions` to inspect results from non-AX experiments.

Data can be collected from the other protocols by running

```matlab
collect_data_pitch_match()
collect_data_thresh_or_loud()
```

## Configuration files

An experiment is specified by a configuration file.
These are YAML file that generally live in `tinnitus-reconstruction/code/experiment/configs/`,
but you can put them anywhere.

A template config file can be found [here](https://github.com/The-Lammert-Lab/tinnitus-reconstruction/blob/main/code/experiment/configs/config_template.yaml).
This template file includes inline comments
that describe a sample configuration file
and what fields are available.

In brief,
the following fields are required to run a reverse correlation experiment:

* stimuli_type
* n_trials_per_block
* n_blocks
* subjectID

To run a threshold determination, loudness matching, or pitch matching experiment, 
the following two fiels are additionally required. 

* min_tone_freq
* max_tone_freq

**Note:** `stimuli_type`, `n_trials_per_block`, and `n_blocks` 
have no effect on non-reverse correlation protocols, but are still required to exist in a config file.
Similarly, `min_tone_freq` and `max_tone_freq` 
do not interact with reverse correlation protocols and are _not_ required in a config file.

Other config fields include:

* **data_dir**: path to directory where output files from the experiment should be saved
* **stimuli_save_type**: either `waveform`, `spectrum`, or `bins`. Determines in what form
data from the experiment should be saved.
* various stimuli parameters including:
    - **min_freq**: the minimum frequency (in Hz) of the stimuli
    - **max_freq**: the maximum frequency (in Hz) of the stimuli
    - **n_bins**: how many tonotopic bins the stimuli has
    - **duration**: the duration of the stimuli (in seconds)
* stimuli hyperparameters specific to each stimulus generation type (see the
[stimuli](https://github.com/The-Lammert-Lab/tinnitus-reconstruction/tree/main/code/stimulus_generation) class definitions for details)

You can load a config file into memory:

```matlab
config = parse_config('path/to/config_file.yaml');
```

and generate a stimulus generation object from the config: 

```matlab
stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
```

To set parameters in a stimulus generation object, use the `from_config()` method, 
which takes a path or a config struct:

```matlab
stimgen = GaussianPriorStimulusGeneration();
stimgen = stimgen.from_config('path/to/config_file.yaml'); % stimgen.from_config(config); 
```

You can generate a serialized experiment ID via:

```matlab
expID = get_experiment_ID(config);
```

Or a hash via:

```matlab
this_hash = get_hash(config);
```

## Stimulus generation methods

Stimulus generation classes are defined [here](https://github.com/The-Lammert-Lab/tinnitus-reconstruction/tree/main/code/stimulus_generation).
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
* `nfft = duration*Fs`: *Dependant property*, the number of fast Fourier transform points.

Methods:
* `[y, spect, binned_repr] = subject_selection_process(self, signal)`
* `[stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)`
* `freq = get_freq(self)`
* `self = from_config(self, options)`
* `stim = synthesize_audio(X, nfft)`

### AbstractBinnedStimulusGenerationMethod

This abstract class includes three additional properties:
* `n_bins = 100`: The number of bins to use to represent the frequency axis.
* `unfilled_dB = -100`: The value of a bin labeled "unfilled" (dB).
* `filled_dB = 0`: The value of a bin labeled "filled" (dB)

Methods:
* `[y, spect, binned_repr] = subject_selection_process(self,representation)`
* `[binnum, Fs, nfft, frequency_vector] = get_freq_bins(self)`
* `spect = get_empty_spectrum(self)`
* `binned_repr = spect2binnedrepr(self, T)`
* `T = binnedrepr2spect(self, binned_repr)`
* `[wav, X, binned_rep] = binnedrepr2wav(self, binned_rep, mult, binrange, new_n_bins, options)`
* `W = bin_signal(self, W, Fs)`

### StimulusGeneration classes

Any `StimulusGeneration` class such as `GaussianPriorStimulusGeneration`
includes the `generate_stimulus` method.

```matlab
[stim, Fs, X, binned_repr] = generate_stimulus(self)
```

## Running an experiment

The `RevCorr`, `ThresholdDetermination`, `LoudnessMatch`, and `PitchMatch` 
functions run an experiment. You can invoke any of them in two ways:

```matlab
RevCorr(cal_dB)
RevCorr(cal_dB, 'config', 'path_to_config_file')
```

In the first case, a dialog box opens and asks you to select a `.yaml` config file.
In the second case, you specify the path to a config file directly. 
The `cal_dB` parameter is described above.

## Collecting data

Data are saved in `config.data_dir` which is usually
`tinnitus-reconstruction/code/experiment/Data`.
For `RevCorr`, each block has a separate stimuli and response file saved for it,
labeled by the subject ID and a unique hash.
For the other experiments, each experiment has separate stimuli and responses saved and similarly marked.

You can use the `collect_data` functions to gather the data into output matrices.

```matlab
[responses, stimuli] = collect_data('config', 'path_to_config_file');
[responses, stimuli, octave_responses, octave_stimuli] = collect_data_pitch_match('config', 'path_to_config_file')
[dBs, tones] = collect_data_thresh_or_loud('loudness', 'config', 'path_to_config_file')
[dBs, tones] = collect_data_thresh_or_loud('threshold', 'config', 'path_to_config_file')
```

## Tinnitus representation reconstruction

You can use compressed sensing (`cs`), compressed sensing without a basis (`cs_no_basis`), linear regression (`gs`) or ridge regression (`gs('ridge',true)`).

To generate a reconstruction with one of these methods, pass it as a name-value argument with 'method':

```matlab
[x, responses_output, stimuli_matrix_output] = get_reconstruction('config', config, 'method', 'cs');
[x, responses_output, stimuli_matrix_output] = get_reconstruction('config', config, 'method', 'linear');
[x, responses_output, stimuli_matrix_output] = get_reconstruction('config_file', 'path/to/config/file.yaml', 'method', 'cs_ridge');
[x, responses_output, stimuli_matrix_output] = get_reconstruction('config_file', 'path/to/config/file.yaml', 'method', 'linear_ridge');
```

# Citation

```
@article{Hoyland2023,
	author={Hoyland, Alec and Barnett, Nelson V. and Roop, Benjamin W. and Alexandrou, Danae and Caplan, Myah and Mills, Jacob and Parrell, Benjamin and Chari, Divya A. and Lammert, Adam C.},
	journal={IEEE Open Journal of Engineering in Medicine and Biology}, 
	title={Reverse Correlation Uncovers More Complete Tinnitus Spectra}, 
	year={2023},
	volume={4},
	number={},
	pages={116-118},
	doi={10.1109/OJEMB.2023.3275051}
}
```
