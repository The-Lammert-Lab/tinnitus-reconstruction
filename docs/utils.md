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



!!! info "See Also"
    * [Protocol](../experiment/#protocol)





-------

### crossval_predicted_responses

Generate response predictions for a given 
config file or pair of stimuli and responses
using stratified cross validation.

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
- knn: `bool`, name-value, default: `false`,
flag to run additional K-Nearest-Neighbor analysis
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
- k_vals: `1 x n` numerical vector, name-value, default: `10:5:50`,
representing the K values on which to perform development to
identify optimum for KNN analysis. Values must be positive integers.
- gamma: `1 x 1` scalar, name-value, default: `8`,
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
`cs`, `lr`, and if `knn = true`, `knn`.
Predicted responses on testing data.
- on_train: `struct` with `(folds-2)*p x 1` vectors in fields
`cs`, `lr`, and if `knn = true`, `knn`.
Predicted responses on training data.





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





-------

### disp_fullscreen

Fill full screen figure with new image.

**ARGUMENTS:**

- img: image loaded via imread()
- hFig: handle to maximized figure. 
Defaults to current figure handle.

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

### follow_up

Runs the follow up protocol to ask exit survey questions.
Questions are included in code/experiment/fixationscreens/FollowUp_vX,
where X is the version number.
Also asks reconstruction quality assessment. Computes linear reconstruction
and generates config-informed white noise for comparison against target
sound. Responses are saved in the specified data directory. 

**ARGUMENTS:**

- data_dir: character vector, name-value, default: empty
Directory where data is stored. If blank, config.data_dir is used. 
- project_dir: character vector, name-value, default: empty
Set as an input to reduce tasks if running from `Protocol.m`.
- this_hash: character vector, name-value, default: empty
Hash to use for output file. Generates from config if blank.
- target_sound: numeric vector, name-value, default: empty
Target sound for comparison. Generates from config if blank.
- target_fs: Positive scalar, name-value, default: empty
Frequency associated with target_sound
- n_trials: Positive number, name-value, default: inf
Number of trials to use for reconstruction. Uses all data if `inf`.
- version: Positive number, name-value, default: 1
Question version number.
- config_file: character vector, name-value, default: ``''``
A path to a YAML-spec configuration file.
- fig: matlab.ui.Figure, name-value.
Handle to open figure on which to display questions.
- verbose: logical, name-value, default: `true`
Flag to print information and warnings. 

**OUTPUTS:**

- survey_XXX.csv: csv file, where XXX is the config hash.
In the data directory. 





-------

### get_accuracy_measures

Computes standard accuracy measures between true and predicted labels

**ARGUMENTS:**

- y: `m x n` numerical matrix,
representing true labels. Values must be either `1` or `-1`.

- y_hat: `m x n` numerical matrix,
representing predicted labels. Values must be either `1` or `-1`.

**OUTPUTS:**

- accuracy: `scalar`,
the correct prediction rate.

- balanced_accuracy: `scalar`,
the average of `sensitivity` and `specificity`.

- sensitivity: `scalar`,
the true positive rate.

- specificity: `scalar`,
the true negative rate.





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

### parse_config 

Read a config file and perform any special parsing that is required.

**ARGUMENTS:**

- config_file: character vector, default: []
Path to the config file to be used.
If empty, opens a GUI to find the file using a file browser.

**OUTPUTS:**

- varargout: `1 x 2` cell array:
varargout{1} = config: `struct`, the parsed config file.
varargout{2} = config_file OR abs_path, `char`,
if path provided, return the path, else return path chosen
from GUI.



!!! info "See Also"
    * [yaml.loadFile](../stimgen/yaml/#loadfile)





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
y = subject_selection_process(representation, stimuli)
y = subject_selection_process(representation, stimuli, [], responses, 'mean_zero', true, 'from_responses', true)
y = subject_selection_process(representation, stimuli, [], [], 'threshold', 90, 'verbose', false)
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

- mean_zero: `bool`, default: false, 
representing a flag that centers the mean of the stimuli and representation.

- from_responses: `bool`, name-value, default: `false`,
a flag to determine the threshold from the given responses. 
The default results in 50% threshold. 
If using this option, `responses` must be passed as well.

- threshold: Positive scalar, name-value, default: 50,
representing a variable by which to manually set the response
threshold. If `from_responses` is true, this will be ignored.

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

### wav2spect 

Reads an audio file (e.g., a .wav file) and returns a spectrum
in terms of magnitudes, s, and frequencies, f, in Hz.





-------

### white_noise
Generate a white noise stimulus based on a config file's settings.

**ARGUMENTS:**

- config_file: string or character array, name-value, default: ``''``
A path to a YAML-spec configuration file.
Either this argument or ``config`` is required.
- config: struct, name-value, default: ``[]``
A configuration file struct
(e.g., one created by ``parse_config``).

**OUTPUTS:**

- white_waveform: `n x 1` white noise waveform.
- fs: `1 x 1` Associated frequency of waveform.



