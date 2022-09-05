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

**OUTPUTS:*
- x: compressed sensing reconstruction of the signal.





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

### get_reconstruction

Compute reconstructions using data specified
by a configuration file.

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


```matlab
[x, responses_output, stimuli_matrix_output] = get_reconstruction('key', value, ...)
x = get_reconstruction('config_file', 'path_to_config', 'preprocessing', {'bit_flip'}, 'method', 'cs', 'verbose', true)
```

Compute the reconstruction, given the response vector and the stimuli matrix with a preprocessing step and a method chosen from {'cs', 'cs_nb', 'linear'}



!!! info "See Also"
    * [collect_reconstructions](./#collect_reconstructions)
    * [collect_data](./#collect_data)
    * [config2table](./#config2table)





-------

### munge_hashes
Processes config files, correcting errors.
Then, fixes the hashes for saved data files
associated with changed config files.


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

**Example:**

```matlab
munge_hashes("file_string", "config*.yaml", "verbose", true)
```


!!! info "See Also"
