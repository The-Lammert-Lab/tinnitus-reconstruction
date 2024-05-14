# Utilities

This folder stores many helpful, and in some cases critical utilities. This folder as added to the path via `setup.m`. Some files are not original to this project, in which case documentation and credit is clearly maintained.

### adjust_volume

For use in A-X experimental protocols.
`adjust_volume` is a utility to dynamically adjust the target sound volume via a scaling factor.
Opens a GUI using a standard MATLAB figure window 
with a slider for scaling the target sound audio 
and a button for replaying the sound compared to an unchanged stimulus noise.  

**ARGUMENTS:**

- target_sound: `n x 1` vector, the target sound.
- target_fs: `1 x 1` scalar, the frequency of target_sound.
- stimuli: `n x 1` vector, a sample stimulus sound.
- Fs: `1 x 1` scalar, the frequency of the sample stimuli.
- scale_factor: `1 x 1` scalar, the scalar by which to multipy the target sound.
default: `1.0`.

**OUTPUTS:**

- scale_factor: `1 x 1` scalar, 
the scalar by which the target signal is multipled 
that results in the preferred volume chosen by the user.





-------

### allcomb

ALLCOMB - All combinations
B = ALLCOMB(A1,A2,A3,...,AN) returns all combinations of the elements
in the arrays A1, A2, ..., and AN. B is P-by-N matrix is which P is the product
of the number of elements of the N inputs. This functionality is also
known as the Cartesian Product. The arguments can be numerical and/or
characters, or they can be cell arrays.

Examples:

```matlab
allcomb([1 3 5],[-3 8],[0 1]) % numerical input:
-> [ 1  -3   0
1  -3   1
1   8   0
...
5  -3   1
5   8   1 ] ; % a 12-by-3 array
```

```matlab
allcomb('abc','XY') % character arrays
-> [ aX ; aY ; bX ; bY ; cX ; cY] % a 6-by-2 character array
``` 

```matlab
allcomb('xy',[65 66]) % a combination
-> ['xA' ; 'xB' ; 'yA' ; 'yB'] % a 4-by-2 character array
```

```matlab 
allcomb({'hello','Bye'},{'Joe', 10:12},{99999 []}) % all cell arrays
-> {  'hello'  'Joe'        [99999]
'hello'  'Joe'             []
'hello'  [1x3 double] [99999]
'hello'  [1x3 double]      []
'Bye'    'Joe'        [99999]
'Bye'    'Joe'             []
'Bye'    [1x3 double] [99999]
'Bye'    [1x3 double]      [] } ; % a 8-by-3 cell array
```

`ALLCOMB(..., 'matlab')` causes the first column to change fastest which
is consistent with matlab indexing. 
Example: 
```matlab
allcomb(1:2,3:4,5:6,'matlab') 
-> [ 1 3 5 ; 1 4 5 ; 1 3 6 ; ... ; 2 4 6 ]
```

If one of the arguments is empty, ALLCOMB returns a `0-by-N` empty array.

Tested in Matlab R2015a
version 4.1 (feb 2016)
(c) Jos van der Geest
email: samelinoa@gmail.com

History:

1.1 (feb 2006), removed minor bug when entering empty cell arrays;
added option to let the first input run fastest (suggestion by JD)

1.2 (jan 2010), using ii as an index on the left-hand for the multiple
output by NDGRID. Thanks to Jan Simon, for showing this little trick

2.0 (dec 2010). Bruno Luong convinced me that an empty input should
return an empty output.

2.1 (feb 2011). A cell as input argument caused the check on the last
argument (specifying the order) to crash.

2.2 (jan 2012). removed a superfluous line of code (ischar(..))

3.0 (may 2012) removed check for doubles so character arrays are accepted

4.0 (feb 2014) added support for cell arrays

4.1 (feb 2016) fixed error for cell array input with last argument being
`matlab`. Thanks to Richard for pointing this out.



!!! info "See Also"
    * [NCHOOSEK](https://www.mathworks.com/help/matlab/ref/nchoosek.html) 
    * [PERMS](https://www.mathworks.com/help/matlab/ref/perms.html?s_tid=doc_ta)
    * [NDGRID](https://www.mathworks.com/help/matlab/ref/ndgrid.html?s_tid=doc_ta)
    * [NCHOOSE](https://www.mathworks.com/matlabcentral/fileexchange/20011-nchoose?s_tid=ta_fx_results)
    * [KTHCOMBN](https://www.mathworks.com/matlabcentral/fileexchange/33922-kthcombn?s_tid=ta_fx_results)





-------

### binnedrepr2spect  

```matlab
T = binnedrepr2spect(binned_repr, B)
T = binnedrepr2spect(binned_repr, B, n_bins)
```

Get the stimuli spectra from a binned representation.

**ARGUMENTS:**

- binned_repr: `n_trials x n_bins` matrix
representing the amplitude in each frequency bin
for each trial.
- B: `1 x n_frequencies` vector
representing the bin numbers
(e.g., `[1, 1, 2, 2, 2, 3, 3, 3, 3, ...]`)
- n_bins: `1 x 1` scalar
representing the number of bins
if not passed as an argument,
it is computed from the maximum of B

**OUTPUTS:**

- T: `n_trials x n_frequencies` matrix
representing the stimulus spectra



!!! info "See Also"
    * [spect2binnedrepr](./#spect2binnedrepr)





-------

### collect_data

Returns the saved responses and stimuli 
from reverse correlation experiments for a given config file.

**ARGUMENTS:**

- config_file: `char`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- config: `struct`, name-value, default: `[]`
An already-loaded config struct.
- data_dir: `char`, name-value, default: `''`
Filepath to directory in which data is stored. 
`config.data_dir` is used if left empty. 
- phase: `1 x 1` positive integer, name-value, default: `1`
Experiment phase from which to collect data. 
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.

**OUTPUTS:**

- responses: `n x 1` numerical vector of {-1,1}, 
all responses associated with this config file, 
where `n` is the number of trials.
- stimuli: `p x n` numerical array, of `config.stimuli_save_type`,
all of the stimulus vectors associated with this config file,
where `p` is the length of the stimulus vector.





-------

### collect_data_pitch_match

Returns the saved responses and stimuli 
from pitch matching experiments for a given config file.

**ARGUMENTS:**

- config_file: `char`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- config: `struct`, name-value, default: `[]`
An already-loaded config struct.
- data_dir: `char`, name-value, default: `''`
Filepath to directory in which data is stored. 
`config.data_dir` is used if left empty. 
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.

**OUTPUTS:**

- responses: `n x 1` cell of vectors containing responses on {0,1},
where `n` is the number of PitchMatch experiments run with this config file.
Each row contains the responses from separate experiments.
- stimuli: `n x 1` cell of vectors containing frequency values 
corresponding to the responses. 
Each row contains the responses from separate experiments.
- octave_responses: `n x 1` cell of vectors containing responses 
on {0,1} to the "octave confusion" section of the PitchMatch experiment. 
Each row contains the responses of separate experiments.
- octave_stimuli: `n x 1` cell of vectors containing frequency values
from the "octave confusion" section of the PitchMatch experiment. 
Each row contains the responses of separate experiments.



!!! info "See Also"
    * [PitchMatch](../experiment/Protocols/#pitchmatch)
    * [get_best_pitch](./#get_best_pitch)





-------

### collect_data_thresh_or_loud

Returns the saved dB levels and corresponding tones
from either threshold determination or loudness matching
experiments for a given config file.

**ARGUMENTS:**

- exp_type: `char`, valid values: 'threshold' or 'loudness',
the type of experimental data to collect.
- config_file: `char`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- config: `struct`, name-value, default: `[]`
An already-loaded config struct.
- data_dir: `char`, name-value, default: `''`
Filepath to directory in which data is stored. 
`config.data_dir` is used if left empty. 
- average: `logical`, name-value, default: `true`,
Flag to average dB values for all repeated tones.
- fill_nans: `logical`, name-value, default: `false`,
Flag to fill in NaN values with the previous non-NaN value
- verbose, `logical`, name-value, default: `true`,
Flag to show informational messages.

**OUTPUTS:**

- pres_dBs: `n x 1` vector containing dB values,
where `n` is the number of unique tones if `average` is `true`,
or is the number of presented stimuli if `average` is `false.
- amp_dBs: `n x 1` vector containing amplitude values.
- tones: `n x 1` vector containing frequency values for each response.





-------

### collect_parameters

Read parameters out from character vectors of text contained in
a character vector or cell array.

**ARGUMENTS:**

- filenames: `cell array` of character vectors or `character vector`
that contains the filenames (or text strings)
out of which to read parameters.

If `filenames` is a cell array, parameters are read from each
character vector contained in the cell array.
Filenames should not have file endings like `'.csv'`.
The regular expressions are not sophisticated enough to skip them.

**OUTPUTS:**

- data_table: `table`

Example:

```matlab
data_table = collect_parameters(filenames)
```



!!! info "See Also"
    * [collect_reconstructions](./#collect_reconstructions)
    * [collect_data](./#collect_data)
    * [config2table](./#config2table)





-------

### collect_reconstructions

Collect reconstructions (or other data) from `.csv` files
following a naming convention.
Returns a matrix of all the data.

While this function was intended to read reconstructions,
it should be able to return data
from any `.csv` files containing data that can be represented
in a MATLAB matrix (e.g., numerical data of the same length).

**ARGUMENTS:**

- data_struct: struct vector or character vector
A struct containing the output of a call to `dir()`
indicating which files to extract from or a character vector
which is used as an argument for `dir()` (e.g., `dir(data_struct)`).
The regular expression
is used to filter the data struct
based on the filenames.

**OUTPUTS:**

- reconstructions: numerical matrix
`m x n` matrix that contains the numerical data,
where `m` is the length of the data
and `n` is the number of files.

- reconstruction_files: cell array of character vectors
Contains the filepaths to each file read,
corresponding to the columns of `reconstructions`.



!!! info "See Also"
    * [collect_data](./#collect_data)
    * [dir](https://www.mathworks.com/help/matlab/ref/dir.html)





-------

### config2table

Take information from directory containing config files and return
a table with all relevant information for each config.

**ARGUMENTS:** 

- curr_dir: `struct`, 
which is the directory information 
containing config file name, path, and other
returns from `dir()` function.

- variables_to_remove: `cell`, default: `{}`,
a cell array of character vectors,
indicating which variables (columns) of
the data table to remove.
If empty, re-defaults to:
`{'n_trials_per_block', 'n_blocks', ...
'min_freq', 'max_freq', 'duration', 'n_bins', ...
'target_signal_filepath', 'bin_target_signal', ...
'data_dir', 'stimuli_save_type'}`.


**OUTPUTS:** 

- data_table: `table`



!!! info "See Also"
    * [parse_config](./#parse_config)
    * [dir](https://www.mathworks.com/help/matlab/ref/dir.html)





-------

### create_files_and_stimuli

Create files for the stimuli, responses, and metadata and create the stimuli.
Write the stimuli into the stimuli file.

**ARGUMENTS:**

- config: `1 x 1` struct, the config struct to associate the files with.
- stimuli_object: `1 x 1` AbstractStimulusGenerationMethod, 
a StimulusGeneration object from which stimuli will be generated.
- hash_prefix: `char`, default: `''`,
the portion of the hash attached to the output files 
that appears before the spectrum matrix hash.

**OUTPUTS:**

- stimuli_matrix: `n x p` numerical array, stimulus waveforms
where `n` is the length of the waveform and `p` is `config.n_trials`
- Fs: `1 x 1` positive scalar, the sampling rate in Hz
- filename_responses: `char` the full path to the empty `CSV` file 
in which responses can be written for this experiment.
- filename_stimuli: `char` the full path to the `CSV` file 
in which the stimuli are written according to `config.stimuli_save_type`.
- filename_meta: `char` the full path to the empty `CSV` file
in which the metadata can be written for this experiment.
- file_hash: `char` the full hash string associated with all the output files.



!!! info "See Also"
    * [RevCorr](../experiment/Protocols/#revcorr)





-------

### create_files_and_stimuli_2afc

Create files for the stimuli, responses, and metadata and create the stimuli
for a 2-AFC experiment.
Write the stimuli into the stimuli file.

**Arguments:**

- config: 1x1 `struct` 
containing a stimulus generation configuration.
- stimuli_object: 1x1 `AbstractStimulusGenerationMethod`
- hash_prefix: 1 x n character vector, default value: `get_hash(config)`

**Outputs:**

- stimuli_matrix_1
- stimuli_matrix_2
- Fs
- filename_responses
- filename_stimuli_1
- filename_stimuli_2
- filename_meta
- file_hash_1
- file_hash_2
- file_hash_combined

Example:

```matlab
[stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, filename_stimuli_1, filename_stimuli_2, filename_meta, file_hash_1, file_hash_2, file_hash_combined] = create_files_and_stimuli_2afc(config, stimuli_object, hash_prefix)
```



!!! info "See Also"





-------

### create_files_and_stimuli_phaseN

For RevCorr_phaseN experiments, 
create files for the stimuli, responses, and metadata and create the stimuli.
Write the stimuli into the stimuli file.

Stimuli are generated by applying random noise and other modifiers 
to the phase 1 reconstruction.

**ARGUMENTS:**

- config: `1 x 1` struct, the config struct to associate the files with.
- phase: `1 x 1` integer > 1, the current phase of experiment. 
Practically, this indicates which phase's reconstruction to perturb from (`phase` - 1).
- pert_bounds: `1 x 2` vector of positive values, 
the min and max factor to perturb by. Ex: `[0.5, 1.5]` will range 
from half to 1.5x the magnitude of the reconstruction values. 
- data_dir: `char`, the directory in which phase (`phase` - 1) 
stimuli-response pairs can be found 
- hash_prefix: `char`, default: `''`,
the hash prefix associated with the 
phase (`phase` - 1) stimuli-response pairs
- reconstruction: `n x 1` numerical vector, default: `[]`,
the reconstruction from which to generate stimuli.
Overrides generating from config if not empty.
- mult_range: `n x m` numerical array, 
the min and max values possible for the mult parameter in `binnedrepr2wav`.
Array can technically be any size, but only min and max are used.
- binrange_range: `n x m` positive numerical array, 
the min and max values possible for the binrange parameter in `binnedrepr2wav`.
Array can technically be any size, but only min and max are used.
- lowcut_range: `n x m` numerical array >= 0, 
the min and max values possible for the low cutoff frequency in `binnedrepr2wav`.
Array can technically be any size, but only min and max are used.
- highcut_range: `n x m` positive numerical array, 
the min and max values possible for the low cutoff frequency in `binnedrepr2wav`.
Array can technically be any size, but only min and max are used.

**OUTPUTS:**

- stimuli_matrix: `n x p` numerical array, stimulus waveforms
where `n` is the length of the waveform and `p` is `config.n_trials`
- Fs: `1 x 1` positive scalar, the sampling rate in Hz
- filename_responses: `char` the full path to the empty `CSV` file 
in which responses can be written for this experiment.
- filename_stimuli: `char` the full path to the `CSV` file 
in which the stimuli are written according to `config.stimuli_save_type`.
- filename_meta: `char` the full path to the empty `CSV` file
in which the metadata can be written for this experiment.
- file_hash: `char` the full hash string associated with all the output files.



!!! info "See Also"
    * [RevCorr_phaseN](../experiment/Protocols/#revcorr_phasen)
    * [AbstractBinnedStimulusGenerationMethod.binnedrepr2wav](../stimgen/AbstractBinnedStimulusGenerationMethod/#binnedrepr2wav)





-------

### crossval_knn

Generate the cross-validated response predictions for a given 
config file or pair of stimuli and responses
using K-Nearest Neighbors.

```matlab
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_knn(folds, k, 'config', config, 'data_dir', data_dir)
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_knn(folds, k, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
Data will be partitioned into `1/folds` for `test` and `dev` sets
and the remaining for the `train` set.
- k: `1 x p` numerical vector or `scalar`,
number of nearest neighbors to consider.
If there are multiple values, 
it will be optimized in the development section.
- method: `char`, name-value, default: 'mode',
class determination style to be passed to knn function.
- percent: `scalar`, name-value, default: 75,
Target percent passed to knn function if `knn_method` is 'percent'.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- norm_stim: `bool`, name-value, default: `false`,
flag to normalize the stimuli after loading.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.    

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector.
- pred_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
- true_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
the original subject responses in the order corresponding 
to the predicted responses on the training data,





-------

### crossval_lda

Generate the cross-validated response predictions for a given 
config file or pair of stimuli and responses
using linear discriminant analysis.


```matlab
[pred_resps, true_resps] = crossval_lda(folds, 'config', config, 'data_dir', data_dir)
[pred_resps, true_resps] = crossval_lda(folds, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.    

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector.



!!! info "See Also"
    * [fitcdiscr](https://mathworks.com/help/stats/fitcdiscr.html)





-------

### crossval_lwlr

Generate the cross-validated response predictions for a given 
config file or pair of stimuli and responses
using locally weighted linear regression.

```matlab
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_lwlr(folds, h, thresh, 'config', config, 'data_dir', data_dir)
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_lwlr(folds, h, thresh, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
Data will be partitioned into `1/folds` for `test` and `dev` sets
and the remaining for the `train` set.
- h: `1 x p` numerical vector or `scalar`,
representing the width parameter(s) for the Gaussian kernel.
If there are multiple values, 
it will be optimized in the development section.
- thresh: `1 x q` numerical vector or `scalar`, 
representing the threshold value in the estimate to response
conversion: `sign(X*b + threshold)`.
If there are multiple values,
it will be optimized in the development section.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- norm_stim: `bool`, name-value, default: `false`,
flag to normalize the stimuli after loading.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.    

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector.
- pred_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
- true_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
the original subject responses in the order corresponding 
to the predicted responses on the training data,





-------

### crossval_pnr

Generate the cross-validated response predictions for a given 
config file or pair of stimuli and responses
using polynomial regression.

```matlab
[pred_resps, true_resps] = crossval_pnr(folds, ords, thresh, 'config', config, 'data_dir', data_dir)
[pred_resps, true_resps] = crossval_pnr(folds, ords, thresh, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
Data will be partitioned into `1/folds` for `test` and `dev` sets
and the remaining for the `train` set.
- ords: `1 x p` numerical vector or `scalar`,
representing the polynomial order(s) on which to perform regression.
If there are multiple values, 
it will be optimized in the development section.
- thresh: `1 x q` numerical vector or `scalar`,
representing the percentile threshold value(s).
If there are multiple values, 
it will be optimized in the development section.
Values must be on (0,100].
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- norm_stimuli: `bool`, name-value, default: `false`,
flag to normalize the stimuli after loading.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.    

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector.



!!! info "See Also"
    * [polyfitn](https://mathworks.com/matlabcentral/fileexchange/34765-polyfitn)





-------

### crossval_predicted_responses

Generate response predictions for a given 
config file or pair of stimuli and responses
using stratified cross validation and either
the subject response model.

```matlab
[given_resps, training_resps, on_test, on_train] = crossval_predicted_responses(folds, 'config', config, 'data_dir', data_dir)
[given_resps, training_resps, on_test, on_train] = crossval_predicted_responses(folds, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
Data will be partitioned into `1/folds` for `test` and `dev` sets
and the remaining for the `train` set.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- normalize: `bool`, name-value, default: `false`,
flag to normalize the stimuli after loading.
- gamma: `1 x 1` scalar, name-value, default: `8`,
- mean_zero: `bool`, name-value, default: `false`,
flag to set the mean of the stimuli to zero when computing the
reconstruction and both the mean of the stimuli and the
reconstruction to zero when generating the predictions.
- from_responses: `bool`, name-value, default: `false`,
flag to determine the threshold from the given responses. 
Overwrites `threshold_values` and does not run threshold
development cycle.
- ridge_reg: `bool`, name-value, default: `false`,
flag to use ridge regression instead of standard linear regression
for reconstruction.
- threshold_values: `1 x m` numerical vector, name-value, default:
`linspace(10,90,200)`, representing the percentile threshold values
on which to perform development to identify optimum. 
Values must be on (0,100].
representing the gamma value to use in 
compressed sensing reconstructions if `config` is empty.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.       

**OUTPUTS:**

- given_resps: `p x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector. `p` is the number of original responses.
- training_resps: `(folds-2)*p x 1` vector,
the original subject responses used in the training phase.
The training data is partially repeated between folds.
- on_test: `struct` with `p x 1` vectors in fields
`cs`, `lr`, predicted responses on testing data.
- on_train: `struct` with `(folds-2)*p x 1` vectors in fields
`cs`, `lr` predicted responses on training data.



!!! info "See Also"
    * [subject_selection_process](./#subject_selection_process)





-------

### crossval_rc

Generate the cross-validated response predictions for a given 
config file or pair of stimuli and responses
using the classical reverse correlation model 
y = sign(Psi * x) or y = sign(Psi * x + thresh).

```matlab
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_rc(folds, thresh, 'config', config, 'data_dir', data_dir)
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_rc(folds, thresh, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
Data will be partitioned into `1/folds` for `test` and `dev` sets
and the remaining for the `train` set.
- thresh: `1 x p` numerical vector or `scalar`, 
representing the threshold value in the estimate to response
conversion: `sign(X*b + threshold)`.
If there are multiple values,
it will be optimized in the development section.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- ridge: `bool`, name-value, default: `false`,
flag to use ridge regression instead of standard linear regression
for reconstruction.
- mean_zero: `bool`, name-value, default: `false`,
flag to set the mean of the stimuli to zero when computing the
reconstruction and both the mean of the stimuli and the
reconstruction to zero when generating the predictions.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.    

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector.
- pred_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
- true_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
the original subject responses in the order corresponding 
to the predicted responses on the training data,





-------

### crossval_rc_adjusted

Generate the cross-validated response predictions for a given
config file using the upsampled and peak sharpened representation in bin form.
Config file must have an associated survey with mult and binrange values.
Reconstruction methods can be the classical reverse correlation model
y = sign(Psi * x) or y = sign(Psi * x + thresh).

```matlab
[pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_rc_adjusted(folds, thresh, 'config', config, 'data_dir', data_dir)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
Data will be partitioned into `1/folds` for `test` and `dev` sets
and the remaining for the `train` set.
- thresh: `1 x p` numerical vector or `scalar`,
representing the threshold value in the estimate to response
conversion: `sign(X*b + threshold)`.
If there are multiple values,
it will be optimized in the development section.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the
config structis stored.
- ridge: `bool`, name-value, default: `false`,
flag to use ridge regression instead of standard linear regression
for reconstruction.
- mean_zero: `bool`, name-value, default: `false`,
flag to set the mean of the stimuli to zero when computing the
reconstruction and both the mean of the stimuli and the
reconstruction to zero when generating the predictions.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding
to the predicted responses, i.e., a shifted version of the
original response vector.
- pred_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
- true_resps_train: `folds*(n-round(n/folds)) x 1` vector,
OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
the predicted responses on the training data.
the original subject responses in the order corresponding
to the predicted responses on the training data,





-------

### crossval_svm

Generate the cross-validated response predictions for a given 
config file or pair of stimuli and responses
using support vector machines.


```matlab
[pred_resps, true_resps] = crossval_svm(folds, 'config', config, 'data_dir', data_dir)
[pred_resps, true_resps] = crossval_svm(folds, 'responses', responses, 'stimuli', stimuli)
```

**ARGUMENTS:**

- folds: `scalar` positive integer, must be greater than 3,
representing the number of cross validation folds to complete.
- config: `struct`, name-value, deafult: `[]`
config struct from which to find responses and stimuli
- data_dir: `char`, name-value, deafult: `''`
the path to directory in which the data corresponding to the 
config structis stored.
- responses: `n x 1` array, name-value, default: `[]`
responses to use in reconstruction, 
where `n` is the number of responses.
Only used if passed with `stimuli`.
- stimuli: `m x n` array, name-value, default: `[]`
stimuli to use in reconstruction,
where `m` is the number of bins.
Only used if passed with `responses`.
- verbose: `bool`, name-value, default: `true`,
flag to print information messages.    

**OUTPUTS:**

- pred_resps: `n x 1` vector,
the predicted responses.
- true_resps: `n x 1` vector,
the original subject responses in the order corresponding 
to the predicted responses, i.e., a shifted version of the 
original response vector.



!!! info "See Also"
    * [fitclinear](https://mathworks.com/help/stats/fitclinear.html)





-------

### cs  

```matlab
[x] = cs(responses, Phi, Gamma)
[x] = cs(responses, Phi)
```

**ARGUMENTS:**

- responses: `n x 1` vector

- Phi: `n x m` matrix,
where `n` is the number of trials/samples
and `m` is the dimensionality of the stimuli/spectrum/bins

- Gamma: Positive scalar, default: 32
optional value for zhangpassivegamma function.

- mean_zero: `bool`, name-value, default: `false`,
a flag for setting the mean of `Phi` to zero.

- verbose: `bool`, name-value, default: `true`,
a flag to print information messages

**OUTPUTS:**

- x: `m x 1` vector,
representing the compressed sensing reconstruction of the signal.



!!! info "See Also"
    * [cs_no_basis](./#cs_no_basis)





-------

### disp_fullscreen

Expand current figure to full screen and fill with an image.

**ARGUMENTS:**

- img: `n x m x 3` array representing an 
image. Typically loaded via imread().
- hFig: handle to figure. 
Defaults to current figure.

**OUTPUTS:**

- hFig now displays an image.





-------

### filematch
Match files by terminal UUID or other identifier.
This function expects filenames in the form

`foo_bar_UUID.baz`

Where foo_bar can be anything,
so long as the UUID or other identifier comes last
before the 'dot filetype'.
The functions returns indices of unmatched files.

Example:

`filematch(files1, files2)`



!!! info "See Also"
    * [collect_data](./#collect_data)





-------

### gen_octaves 

Returns a vector of doubled values from 
min_freq to as close to max_freq as possible 
with optional, equally spaced in-octave values.

**ARGUMENTS:**

- min_freq: `1 x 1` scalar, the minimum and initial frequency
- max_freq: `1 x 1` scalar, the maximum possible frequency, 
not guaranteed to be in the final array.
- n_in_oct: `1 x 1` integer, the number of points inside each octave.
If `spacing_type` == `'semitone'`, 
`n_in_oct` must be in {1,2,3,5,11}. 
Otherwise, can be any integer >= 0.
- spacing_type: `char`, default: `'semitone'`, 
the in-octave spacing method. 
`'linear'` returns linearly spaced spaced values
`'semitone'` splits the octave into half notes 
then chooses `n_in_oct` evenly spaced values.

**OUTPUTS:**

- freqs: `n x 1` numerical vector of octaves starting at `min_freq`.





-------

### get_accuracy_measures

Computes standard accuracy measures between true and predicted labels.
Values greater than or equal to 1 are considered positives,
and values less than 1 are considered negative.

**ARGUMENTS:**

- y: `m x p` numerical matrix,
representing true labels.
- y_hat: `m x n` numerical matrix,
representing predicted labels.

**OUTPUTS:**

- accuracy: `scalar` or `1 x max(n,p)` vector,
the correct prediction rate. 
- balanced_accuracy: `scalar` or `1 x max(n,p)` vector,
the average of `sensitivity` and `specificity`.
- sensitivity: `scalar` or `1 x max(n,p)` vector,
the true positive rate.
- specificity: `scalar` or `1 x max(n,p)` vector,
the true negative rate.





-------

### get_best_pitch

Returns the matched pitch for a given config's PM data 
and whether or not all any octaves were confused

**ARGUMENTS:**

- config_file: `character vector`, name-value, default: `''`
Path to the desired config file.
GUI will open for the user to select a config if no path is supplied.
- config: `struct`, name-value, default: `[]`,
the loaded config.
- data_dir: `character vector`, name-value, default: `''`,
the path to the location of the data. 
If none is supplied, config.data_dir will be used.
- verbose: `bool`, name-value, default: `true`,
flag to print information text.

**OUTPUTS:**

- best_freq: `1x1` scalar, the identified best frequency.
- oct_agree: `bool`, `true` if there was never any octave confusion over all data
`false` if there was ever any octave confusion.



!!! info "See Also"
    * [PitchMatch](../experiment/Protocols/#pitchmatch)
    * [collect_data_pitch_match](./#collect_data_pitch_match)





-------

### get_gamma_from_config

Choose a gamma value to be used in `cs` based on data in the config.

**ARGUMENTS:**

- config: `struct`, config from which to find gamma
- verbose: `bool`, default: `true`,
flag to print information messages.

**OUTPUTS:**

- this_gamma: `scalar`, the chosen gamma value.





-------

### get_highest_power_of_2
Compute the highest power of two less than or equal
to a number.
For example, an input of 9 would return 8.

**EXAMPLE:**

```matlab
n = get_highest_power_of_2(N);
```

**ARGUMENTS:**

- N: a 1x1 scalar, positive, real integer

**OUTPUTS:**

- n: a 1x1 scalar, positive, real power of 2





-------

### get_reconstruction

Compute reconstructions using data specified
by a configuration file.

```matlab
[x, responses_output, stimuli_matrix_output] = get_reconstruction('key', value, ...)
x = get_reconstruction('config_file', 'path_to_config', 'preprocessing', {'bit_flip'}, 'method', 'cs', 'verbose', true)
```

**ARGUMENTS:**

- config_file: string or character array, name-value, default: ``''``
A path to a YAML-spec configuration file.
Either this argument or ``config`` is required.
- config: struct, name-value, default: ``[]``
A configuration file struct
(e.g., one created by ``parse_config``).
- preprocessing: cell array of character vectors, name-value, default: ``{}``
A list of preprocessing steps to take.
Currently, the only supported preprocessing step is ``'bit flip'``,
which flips the sign on all responses before computing the reconstruction.
- method: character vector, name-value, default: ``'cs'``
Which reconstruction algorithm to use. 
Options: ``'cs'``, ``'cs_nb'``, ``'linear'`, ``'linear_ridge'``.
- use_n_trials: Positive scalar, name-value, default: `inf`
Indicates how many trials to use of data. `inf` uses all data.
- bootstrap: Positive scalar, name-value, deafult: 0
Number of bootstrap iterations to perform.





!!! info "See Also"
    * [collect_reconstructions](./#collect_reconstructions)
    * [collect_data](./#collect_data)
    * [config2table](./#config2table)





-------

### gs

Returns the linear reconstruction of stimuli and responses.

```matlab
x = gs(responses, Phi)
x = gs(responses, Phi, 'ridge', true, 'mean_zero', true)
```

**ARGUMENTS:**

- responses: `n x 1` vector of 1 and -1 values,
representing the subject's responses.

- Phi: `n x m` numerical matrix,
where m is the length of each stimulus 
and n is the same length as the responses

- ridge: `boolean`, name-value, default: `false`,
a flag to for using ridge regression.

- mean_zero: `boolean`, name-value, defaut: `false`,
a flag for setting the mean of `Phi` to zero.

**OUTPUTS:**

- x: `m x 1` vector,
representing the linear reconstruction of the signal, 
where m is the length of a stimulus. 





-------

### knn_classify

Returns the estimated class labels for a matrix of 
reference points T, given data points X and labels y.

**ARGUMENTS:**

- y: `n x 1` vector,
representing class labels that correspond to data points in `X`.
- X: `n x p` numerical matrix,
labelled data points.
- T: `m x p` numerical matrix,
representing reference points without/needing class labels
- k: `scalar`,
indicating the number of nearest neighbors to be considered.
- method: `char`, name-value, default: 'mode',
method by which to determine the class label.
Valid methods are 'mode', which takes the most common neighbor label
'min_class', which takes the least common, 
and 'percent', which takes the class with the closest percent occurrance.
- percent: `scalar`, name-value, default: 75,
if method is 'percent', label is assigned based on the class with 
the closest percent occurrance to this argument.

**OUTPUTS:**

- z_hat: `m x 1` vector,
estimated class labels for data points in T.





-------

### munge_hashes

Processes config files, correcting errors.
Then, fixes the hashes for saved data files
associated with changed config files.

```matlab
munge_hashes("file_string", "config*.yaml", "verbose", true)
```

**Arguments:**

- file_string: ``string`` or ``character vector``, name-value, default: ``"config*.yaml"``  
A file pattern, optionally using globs that is passed to ``dir``
to search for configuration files to munge.

- legacy_flag: ``logical scalar``, name-value, default: ``false``  
Whether to load config files in "legacy mode", e.g., with ``ReadYaml``
instead of ``yaml.loadFile``.

- verbose: ``logical scalar``, name-value, default: ``true``  
Whether to print informative text.

- data_dir: ``string`` or ``character vector``, name-value, default: ``"."``  
Path to the directory where the data files to-be-munged are.



!!! info "See Also"
    * [update_hashes](./#update_hashes)





-------

### P

Soft threshold operator used in compressed sensing





-------

### parse_config 

Read a config file and perform any special parsing that is required.

**ARGUMENTS:**

- config_file: character vector, default: []
Path to the config file to be used.
If empty, opens a GUI to find the file using a file browser.
- legacy: `logical`, name-value, default: `false`,
flag to indicate use of legacy `ReadYaml` package. 
- verbose: `logical`, name-value, default: `true`,
flag to show informational messages.

**OUTPUTS:**

- config: `struct`, the parsed config file.
- config_file: `char`, 
the provided path or else the full path chosen from GUI.



!!! info "See Also"
    * [yaml.loadFile](../stimgen/yaml/#loadfile)





-------

### parse_rand_nbins

Parses stimuli and responses into cells 
based on number of bins in the stimuli
For use with UniformPriorRandNBinsStimulusGeneration stimuli

**ARGUMENTS:**

- responses: `n x 1` numerical array, response data, 
where `n` is the number of completed trials.
- stimuli: `m x n`, the stimuli data,
where `m` is the max number of bins

**OUTPUTS:**

- resp_cell: `p x 1` cell, where `p` is the number of unique bins.
Responses organized into arrays within the cell.
- stim_cell: `p x 1` cell, the corresponding stimuli to 
`resp_cell` in increasing bin order.



!!! info "See Also"
    * [UniformPriorRandNBinsStimulusGeneration.generate_stimuli_matrix](../stimgen/UniformPriorRandNBinsStimulusGeneration/#generate_stimuli_matrix)





-------

### play_calibration_sound

Plays a 1000 Hz tone at system volume with a sample rate of 44100 Hz.
No arguments.





-------

### prop2str

```matlab
stringified_properties = prop2str(obj, [], '&&')
```

Converts the property names and values of a struct or object
into a character vector.
For example, a struct, s, with the properties, s.a = 1, s.b = 2,
would become 'a=1-b=2'.
If some of the property values are cell arrays,
they should be character vectors or numerical vectors
and of the same type within each cell array.

**ARGUMENTS:**

- obj: `1 x 1` struct or object,
the object with properties to be stringified

- properties_to_skip: character vector or cell array
Properties to not include in the output character vector.

- property_separator: character vector
What separator to use between parameter statements.

**OUTPUTS:**

- stringified_properties: character vector



!!! info "See Also"
    * [collect_parameters](./#collect_parameters)





-------

### pure_tone

Generate a sinusoidal pure tone stimuli

**ARGUMENTS:**

- tone_freq: `1 x 1` positive scalar, the frequency to play
- dur: `1 x 1` positive scalar, 
the duration of the sound in seconds, default: 0.5  
- Fs: `1 x 1` positive scalar, 
the sample rate of the sound in Hz, deafult: 44100

**OUTPUTS:**

- stim: `1 x n` numerical vector, the sinusoidal waveform





-------

### r_viz

Plots bar charts of r values from table data. 
A separate figure is made for each subject.

**ARGUMENTS:**

- T: `table` that includes r values of interest

**OUTPUTS:**

- n figures, where n is the number of subjects included
in the table.



!!! info "See Also"
    * [pilot_reconstructions](../scripts/#pilot_reconstructions)





-------

### rand_str

Generates a random string of length `len`
with numbers 0-9 and letters Aa-Zz

**ARGUMENTS:**

- len: `1 x 1` positive integer, default: `8`
the length of the string

**OUTPUTS:**

- str: `1 x len` random character vector





-------

### semitones 

Returns one octave of semitones from the initial frequency,
includes both octave endpoints.

**ARGUMENTS:**

- init_freq: `1 x 1` scalar, the initial frequency.
- n: `1 x 1` positive integer, default: `12`,
the number of semitones above init_freq to to return.
- direction: `char`, default: `'up'`, options: `'up'`, `'down'`.
direction in which to generate semitones from `init_freq`.

**OUTPUTS:**

- tones: `n+1 x 1` numerical vector, 
`n+1` semitones starting at `init_freq`.





-------

### spect2binnedrepr

binned_repr = spect2binnedrepr(T, B)
binned_repr = spect2binnedrepr(T, B, n_bins)

Get the binned representation,
which is a vector containing the amplitude
of the spectrum in each frequency bin.

**ARGUMENTS:**

- T: `n_trials x n_frequencies` matrix
representing the stimulus spectra

- B: `1 x n_frequencies` vector
representing the bin numbers
(e.g., `[1, 1, 2, 2, 2, 3, 3, 3, 3, ...]`)

- n_bins: `1x1` scalar
representing the number of bins
if not passed as an argument,
it is computed from the maximum of B

**OUTPUTS:**

- binned_repr: `n_trials x n_bins` matrix
representing the amplitude for each frequency bin
for each trial



!!! info "See Also"
    * [binnedrepr2spect](./#binnedrepr2spect)





-------

### str2prop
Converts a string of properties and values
into a struct or cell array.
TODO: more documentation, use property_separator

**ARGUMENTS:**

- prop_string: character vector
String containing property : value pairs

- properties_to_skip: character vector or cell array
Properties to not incude in the output character vector

- property_separator: character vector
What separator to use between parameter statements.

**OUTPUTS:**

- obj: struct or cell array


Example:
```matlab
obj = str2prop(prop_string, [], '&&')
```



!!! info "See Also"
    * [collect_parameters](./#collect_parameters)





-------

### subject_selection_process

Returns a response vector and the stimuli
where the response vector is made of up -1 and 1 values
corresponding to yes and no statements
about how well the stimuli correspond to the representation.

```matlab
[y, X] = subject_selection_process(representation, stimuli)
[y, X] = subject_selection_process(representation, stimuli, [], responses, 'mean_zero', true, 'from_responses', true)
[y, X] = subject_selection_process(representation, stimuli, 'method', 'sign', 'lambda', 0.5)
[y, X] = subject_selection_process(representation, stimuli, [], [], 'threshold', 90, 'verbose', false)
[y, X] = subject_selection_process(representation, [], n_samples)
```

**ARGUMENTS:**

- representation: `n x 1` numerical vector,
the signal to compare against (e.g., the tinnitus signal).

- stimuli: numerical matrix,
an `m x n` matrix where m is the number of samples/trials
and n is the same length as the representation.
If stimuli is empty, a random Bernoulli matrix (p = 0.5) is used.

- n_samples: integer scalar
representing how many samples are used when generating the Bernoulli matrix default
for stimuli, if the stimuli argument is empty.

- responses: `m x 1` numerical vector, 
which contains only `-1` and `1` values,
used to determine the threshold if using one of the custom options.

- mean_zero: `bool`, name-value, default: `false`, 
representing a flag that centers the mean of the stimuli and representation.

- method: `character vector`, name-value, default: `percentile`,
the method to use to convert estimations into response values.
Options are: `percentile`, which uses the whole estimation vector
and `threshold`, `sign` which computes `sign(e + lambda)`,
and `ten_scale`, which returns values from 0-10 using.

- from_responses: `bool`, name-value, default: `false`,
a flag to determine the threshold from the given responses. 
The default results in 50% threshold. 
If using this option, `responses` must be passed as well.

- threshold: Positive scalar, name-value, default: 50,
representing the percent of -1 responses in `y`.
If `from_responses` is true, this will be ignored.

- lambda: Scalar >= 0, name-value, default: 0,
value for use in `sign(e + lambda)` if `method` is `sign`.

- verbose: `bool`, name-value, default: `true`,
a flag to print information messages

**OUTPUTS:**

- y: numerical vector,
A vector of `-1` and `1` corresponding to negative and positive responses.

- X: numerical matrix,
the stimuli.



!!! info "See Also"
    * [AbstractStimulusGenerationMethod.subject_selection_process](../stimgen/AbstractStimulusGenerationMethod/#subject_selection_process)





-------

### tones_to_binspace

Spaces the values in a frequency vector into bins 
determined by the stimgen object.

**ARGUMENTS:**

- tones: `n x 1` vector of frequency values
- stimgen: Any object that inherets from `AbstractBinnedStimulusGenerationMethod`,
used to inform the spacing (min and max freqs, number of bins)      

**OUTPUTS:**

- tones_bindist: `n_bins x 1` vector in Hz which contains the values in `tones`
placed into the appropriate bin (values are averaged if multiple fit into the same bin)
and the bin center frequency in all bins for which there was no value in `tones`.



!!! info "See Also"
    * [AbstractBinnedStimulusGenerationMethod.get_freq_bins](../stimgen/AbstractBinnedStimulusGenerationMethod/#get_freq_bins)





-------

### update_hashes

Updates data files that match an old hash to a new hash.
Ordinarily this is *not* something that you want to do.
However, there are some situations where the config spec
changed or something was mislabeled
and so the config hash does not match
the hashes in the data file names.
This function re-aligns the data to the config
by updating the hashes.


**Arguments:**

- new_hash: character vector
- old_hash: character vector
- data_dir: character vector
pointing to the directory where the data files are stored.

**Outputs:**

- None



!!! info "See Also"
    * [collect_data](./#collect_data)





-------

### view_table

Filters data table from `pilot_reconstructions.m`
and generates a figure with a uitable for easy viewing.

**Arguments:**

- T: `table` generated by pilot_reconstructions

**OUTPUTS:**

- 1 figure



!!! info "See Also"
    * [pilot_reconstructions](../scripts/#pilot_reconstructions)





-------

### waitforkeypress

Wait for a keypress, ignoring mouse clicks.
Returns 1 when a key is pressed.
Returns -1 when the function encounters an error
which usually happens when the figure is deleted.

**ARGUMENTS:**

- verbose: `bool`, default: true

**OUTPUTS:**

- k: `1 x 1` scalar,
`1` when a key is pressed, `-1` if an error occurs





-------

### wav2spect 

Reads an audio file (e.g., a .wav file) and returns a spectrum
in terms of magnitudes, s (in dB), and frequencies, f (in Hz).

**ARGUMENTS:**

- audio_file: `char`, path to the audio file.
- duration: `1x1` scalar, default: 0.5,
the duration to crop the audio file to in seconds.

**OUTPUTS:**

- s: The spectrum in dB
- f: The associated frequencies in Hz.





-------

### white_noise

Generate a white noise waveform of specified length

**ARGUMENTS:**

- dur: `1 x 1` positive scalar,
the duration of the waveform in seconds.
- Fs: `1 x 1` positive scalar, default: 44100
The sampling rate in Hz.

**OUTPUTS:**

- wav: `n x 1` numerical vector, where `n` is dur*Fs, 
the white noise waveform.





-------

### zhangpassivegamma

Passive algorithm for 1-bit compressed sensing with no basis.



