# Utilities

This folder stores many helpful, and in some cases critical utilities. This folder as added to the path via `setup.m`. Some files are not original to this project, in which case documentation and credit is clearly maintained.

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

tone_freq: `1 x 1` positive scalar, the frequency to play
dur: `1 x 1` positive scalar, 
the duration of the sound in seconds, default: 0.5  
Fs: `1 x 1` positive scalar, 
the sample rate of the sound in Hz, deafult: 44100

**OUTPUTS:**

stim: `1 x n` numerical vector, the sinusoidal waveform





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



