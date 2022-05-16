# Tinnitus Project

Reconstructing high-dimensional representations of tinnitus using reverse correlation and compressed sensing.

## Configuration files

An experiment is specified by a configuration file.
These are YAML file that generally live in `tinnitus-project/code/experiment/configs/`,
but you can put them anywhere.
There are four required fields:
* **stimuli_type**: which stimulus generation method to use
* **n_trials_per_block**: how many trials to do in a single block
* **n_blocks**: how many blocks of trials to do
* **subjectID**: unique identifier for the experiment/subject

Other fields include:

* **data_dir**: path to directory where output files from the experiment should be saved
* **stimuli_save_type**: either `waveform`, `spectrum`, or `bins`. Determines in what form
data from the experiment should be saved.
* various stimuli parameters including:
    - **min_freq**: the minimum frequency (in Hz) of the stimuli
    - **max_freq**: the maximum frequency (in Hz) of the stimuli
    - **n_bins**: how many tonotopic bins the stimuli has
    - **bin_duration**: the duration of the stimuli (in seconds)
* stimuli hyperparameters specific to each stimulus generation type (see the `Stimuli` class definition for details)

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
x = cs(responses, stimuli');
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
