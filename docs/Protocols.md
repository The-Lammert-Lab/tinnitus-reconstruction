# Protocols 

This folder contains all protocol functions. 
These are experiments that can be run to collect data using a config file.

### adjust_resynth

Runs interactive adjustment of `mult` and `binrange` parameters
for reconstruction resynthesis. Plays target sound as comparison
if one is provided or included in config.

**ARGUMENTS:**

- cal_dB, `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- mult: `1 x 1` positive scalar, default: 0.001
initial value for the peak-sharpening `mult` parameter.
- binrange: `1 x 1` scalar, default: 60,
must be between [1, 100]. The initial value for the 
upper bound of the [0, binrange] dynamic range of 
the peak-sharpened reconstruction.
- data_dir: `character vector`, name-value, default: empty
Directory where data is stored. If blank, config.data_dir is used. 
- project_dir: `character vector`, name-value, default: empty
Set as an input to reduce tasks if running from `Protocol.m`.
- this_hash: `character vector`, name-value, default: empty
Hash to use for output file. Generates from config if blank.
- target_sound: `numeric vector`, name-value, default: empty
Target sound for comparison. Generates from config if blank.
- target_fs: `Positive scalar`, name-value, default: empty
Frequency associated with target_sound
- n_trials: `Positive number`, name-value, default: inf
Number of trials to use for reconstruction. Uses all data if `inf`.
- version:`Positive number`, name-value, default: 0
Question version number. Must be passed or in config.
- config_file: `character vector`, name-value, default: ``''``
A path to a YAML-spec configuration file. 
Can be `'none'` if passing other relevant arguments.
- survey: `logical`, name-value, default: `true`
Flag to run static/survey questions. If `false`, only sound
comarison is shown.
- stimgen: Any `StimulusGenerationMethod`, name-value, default: `[]`,
Stimgen object to use. `options.config` must be `'none'`. 
- recon: `numeric vector`, name-value, default: `[]`
Allows user to supply a specific reconstruction to use, 
rather than generating from config. 
- mult_range: `1 x 2 numerical vector, name-value, default: `[0, 1]`,
The min (1,1) and max (1,2) values for mult parameter.
- binrange_range: `1 x 2 numerical vector, name-value, default: `[1, 100]`,
The min (1,1) and max (1,2) values for binrange parameter.
- del_fig, `logical`, name-value, default: `true`,
Flag to delete figure at the end of the experiment.
- fig: `matlab.ui.Figure`, name-value.
Handle to open figure on which to display questions.
- save: `logical`, name-value, default: `true`.
Flag to save the `mult` and `binrange` outputs to a `.csv` file.
- verbose: `logical`, name-value, default: `true`
Flag to print information and warnings. 

**OUTPUTS:**

- mult: `1 x 1` scalar, the last selected value for this parameter.
- binrange: `1 x 1` scalar, the last selected value for this parameter.
- mult_binrange_XXX.csv: csv file, where XXX is the config hash.
In the data directory. ONLY IF `save` param is `true`.



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.binnedrepr2wav](../stimgen/AbstractBinnedStimulusGenerationMethod/#binnedrepr2wav)





-------

### follow_up

Runs the follow up protocol to ask exit survey and subjective 
reconstruction assessment questions.
Questions are included in code/experiment/fixationscreens/FollowUp_vX,
where X is the version number.
Computes standard linear reconstruction, 
peak-sharpened linear reconstruction,
and generates config-informed white noise for comparison against target
sound. Responses are saved in the specified data directory. 

**ARGUMENTS:**

- cal_dB, `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- data_dir: `character vector`, name-value, default: empty
Directory where data is stored. If blank, config.data_dir is used. 
- project_dir: `character vector`, name-value, default: empty
Set as an input to reduce tasks if running from `Protocol.m`.
- this_hash: `character vector`, name-value, default: empty
Hash to use for output file. Generates from config if blank.
- target_sound: `numeric vector`, name-value, default: empty
Target sound for comparison. Generates from config if blank.
- target_fs: `Positive scalar`, name-value, default: empty
Frequency associated with target_sound
- n_trials: `Positive number`, name-value, default: inf
Number of trials to use for reconstruction. Uses all data if `inf`.
- mult: `Positive number`, name-value, default: `NaN`
The peak-sharpening `mult` parameter. 
Must be passed if no `resynth_params` file exists.
- binrange: `Positive number`, name-value, default: 60,
must be between [1, 100], the upper bound of the [0, binrange]
dynamic range of the peak-sharpened reconstruction.
Must be passed if no `resynth_params` file exists.
- version:`Positive number`, name-value, default: 0
Question version number. Must be passed or in config.
- config_file: `character vector`, name-value, default: ``''``
A path to a YAML-spec configuration file.
- survey: `logical`, name-value, default: `false`
Flag to run static/survey questions. If `false`, only sound
comparison is shown.
- recon: `numeric vector`, name-value, default: `[]`
Allows user to supply a specific reconstruction to use, 
rather than generating from config.
- n_reps: `1 x 1` positive integer, name-value, default: `2`
Number of times to run the resynthesis rating questions.
- fig: `matlab.ui.Figure`, name-value.
Handle to open figure on which to display questions.
- verbose: `logical`, name-value, default: `true`
Flag to print information and warnings. 

**OUTPUTS:**

- survey_XXX.csv: csv file, where XXX is the config hash.
In the data directory. 





-------

### LoudnessMatch

Protocol for matching perceived loudness of tones to tinnitus level.

```matlab
LoudnessMatch(cal_dB) 
LoudnessMatch(cal_dB, 'config', 'path2config')
LoudnessMatch(cal_dB, 'verbose', false, 'fig', gcf, 'del_fig', false)
```

**ARGUMENTS:**

- cal_dB, `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- max_dB_allowed_, `1x1` scalar, name-value, default: `95`.
The maximum dB value at which tones can be played. 
`cal_dB` must be greater than this value. Not intended to be changed from 95.
- config_file, `character vector`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.
- del_fig, `logical`, name-value, default: `true`,
Flag to delete figure at the end of the experiment.
- fig, `matlab.ui.Figure`, name-value.
Handle to figure window in which to display instructions
Function will create a new figure if none is supplied.

**OUTPUTS:**

- Three `CSV` files: `loudness_dBs`, `loudness_noise_dB`, `loudness_tones`
saved to config.data_dir.





-------

### PitchMatch

Protocol for matching tinnitus to a single tone.

Based on the Binary method from:
Henry, James A., et al. 
"Comparison of manual and computer-automated procedures for tinnitus pitch-matching." 
Journal of Rehabilitation Research & Development 41.2 (2004).

Henry, James A., et al. 
"Comparison of two computer-automated procedures for tinnitus pitch matching." 
Journal of Rehabilitation Research & Development 38.5 (2001).

```matlab
PitchMatch(cal_dB) 
PitchMatch(cal_dB, 'config', 'path2config')
PitchMatch(cal_dB, 'verbose', false, 'fig', gcf, 'del_fig', false)
```

**ARGUMENTS:**

- cal_dB, `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- max_dB_allowed_, `1x1` scalar, name-value, default: `95`.
The maximum dB value at which tones can be played. 
`cal_dB` must be greater than this value. Not intended to be changed from 95.
- config_file, `character vector`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.
- del_fig, `logical`, name-value, default: `true`,
Flag to delete figure at the end of the experiment.
- fig, `matlab.ui.Figure`, name-value.
Handle to figure window in which to display instructions
Function will create a new figure if none is supplied.

**OUTPUTS:**

- Six `CSV` files: `PM_tone_responses`, `PM_tones`, 
`PM_octave_responses`, `PM_octaves`,  
`PM_tone_dBs`, `PM_octave_dBs`
saved to config.data_dir.





-------

### RevCorr

Reverse Correlation Protocol for Cognitive Representations of Tinnitus
This function runs the main experimental procedure of this project.

```matlab
RevCorr(cal_dB) 
RevCorr(cal_dB, 'config', 'path2config')
RevCorr(cal_dB, 'verbose', false, 'fig', gcf)
```

**ARGUMENTS:**

- cal_dB, `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- config_file, `character vector`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.
- fig, `matlab.ui.Figure`, name-value.
Handle to figure window in which to display instructions
Function will create a new figure if none is supplied.

**OUTPUTS:**

- Two `CSV` files (`responses` and `stimuli`) saved to `config.data_dir`.





-------

### RunAllExp

This function goes one by one through each of the experimental protocols
using one config file. PitchMatch is repeated 3 times by default. 

**ARGUMENTS:**

- cal_dB: `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- config_path: `character vector`, default: ``''``
A path to a YAML-spec configuration file. 
If empty, a GUI is opened to navigate to the file. 
- n_pm: `1x1` positive integer, the number of times to repeat 
the PitchMatch protocol. Default: `3`.





-------

### ThresholdDetermination

Protocol for identifying the hearing threshold level over a range of frequencies

```matlab
ThresholdDetermination(cal_dB) 
ThresholdDetermination(cal_dB, 'config', 'path2config')
ThresholdDetermination(cal_dB, 'verbose', false, 'fig', gcf, 'del_fig', false
```

**ARGUMENTS:**

- cal_dB, `1x1` scalar, the externally measured decibel level of a 
1kHz tone at the system volume that will be used during the
protocol.
- max_dB_allowed_, `1x1` scalar, name-value, default: `95`.
The maximum dB value at which tones can be played. 
`cal_dB` must be greater than this value. Not intended to be changed from 95.
- config_file, `character vector`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.
- del_fig, `logical`, name-value, default: `true`,
Flag to delete figure at the end of the experiment.
- fig, `matlab.ui.Figure`, name-value.
Handle to figure window in which to display instructions
Function will create a new figure if none is supplied.

**OUTPUTS:**

- Two `CSV` files: `threshold_dBs`, `threshold_tones` saved to config.data_dir.



