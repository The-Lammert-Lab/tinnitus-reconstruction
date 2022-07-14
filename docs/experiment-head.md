# Experiment

This folder contains the experimental protocols, ATA sounds, fixation screens, and config files, each of which is be detailed below: 

### ATA

The files within this folder are the same as those presented on the American Tinnitus Association website (* [here](https://www.ata.org/listen-sample-tinnitus-sounds)). They are representitive of the range of sounds experienced by those with tinnitus and function in this project as the target sound for A-X protocol experiments.

### Fixation screens

This folder holds the images displayed while running the protocol. Specifically, subject instructions for which keys to press at which times, notices for the completion of blocks and for the full completion 

### Configs

Config files contain all of the information necessary to run trials and gather data. Configs are in `.yaml` format. These files should be carefully written before beginning any experiment to ensure the desired stimulus is generated and data are labeled and stored as intended. The name of the config file itself does not require a specific format. 

To allow for unique naming and organization, label experiment name and subject ID fields. These are not required fields for performing the experiment, but are highly encouraged. 

```display
experiment_name: paper1-buzzing-AH
subject_ID: AH
```

These fields describe the number of trials in the experiment. `n_trial_per_block` is the number of trials per block of the experiment. A block is a set of contiguous trials without a break a break. Subjects get a break between blocks. These are both required fields.

```display
n_trials_per_block: 100
n_blocks: 20
```

The total trials should be the number of trials per block times the number of blocks. This is not a required field.

```display
total_trials: 2000
```

These "freq" fields describe the frequency range of the stimuli, including the minimum frequency and maximum frequency, both in Hz. The duration field describes the duration of the stimului in seconds. These are not required fields. Default values are set to `min_freq = 100, max_freq = 22000, and duration = 0.5`. These defaults are defined in * [@AbstractStimulusGenerationMethod](../code/stimulus_generation/%40AbstractBinnedStimulusGenerationMethod/).

```display
min_freq: 100
max_freq: 13000
duration: 0.5
```

For a stimulus type that uses bins, the number of bins are set here. This should be a positive scalar integer.

```display
n_bins: 100
```

This required parameter gives the stimuli type. The name is the class that defines the stimuli type without "StimulusGeneration".

```display
stimuli_type: UniformPrior
```

Some stimulus generation methods have other parameters associated with them. For example, the Gaussian Prior stimulus generation method requires an n_bins_filled_mean and n_bins_filled_var property. You can see what extra parameters are required for your method by inspecting the class definition for the method, e.g., at * [stimulus-generation/](../code/stimulus_generation/). If you do not overwrite values in the config, default values are used, which are described in the class definition.

```display
min_bins: 30
max_bins: 30
```

For an experiment with a target signal (i.e., for pilot subjects) this field describes the full filepath to the target signal audio file.

```display
target_audio_filepath: /home/alec/code/tinnitus-project/code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav
bin_target_signal: true
```

This is the path where the output files are saved. This is not a required field. If it is is unset, it will default to `tinnitus-project/code/experiment/Data`.

```display
data_dir: /home/alec/code/tinnitus-project/code/experiment/Data/data_pilot
```

This field determines in what form the stimuli are saved. The available options are `bins`, `waveform`, or `spectrum`. If not set, it will default to `waveform`.

```display
stimuli_save_type: bins
```