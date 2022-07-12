# Utilities

This folder stores many helpful, and in some cases critical, utilities. This folder as added to the path via `setup.m`. Some files are not original to this project, in which case documentation and credit is clearly maintained.

### DataHash

DATAHASH - Checksum for Matlab array of any type
This function creates a hash value for an input of any type. The type and
dimensions of the input are considered as default, such that UINT8([0,0]) and
UINT16(0) have different hash values. Nested STRUCTs and CELLs are parsed
recursively.

Hash = DataHash(Data, Opts...)
INPUT:
Data: Array of these built-in types:
(U)INT8/16/32/64, SINGLE, DOUBLE, (real/complex, full/sparse)
CHAR, LOGICAL, CELL (nested), STRUCT (scalar or array, nested),
function_handle, string.
Opts: Char strings to specify the method, the input and theoutput types:
Input types:
'array': The contents, type and size of the input [Data] are
considered  for the creation of the hash. Nested CELLs
and STRUCT arrays are parsed recursively. Empty arrays of
different type reply different hashs.
'file':  [Data] is treated as file name and the hash is calculated
for the files contents.
'bin':   [Data] is a numerical, LOGICAL or CHAR array. Only the
binary contents of the array is considered, such that
e.g. empty arrays of different type reply the same hash.
'ascii': Same as 'bin', but only the 8-bit ASCII part of the 16-bit
Matlab CHARs is considered.
Output types:
'hex', 'HEX':      Lower/uppercase hexadecimal string.
'double', 'uint8': Numerical vector.
'base64':          Base64.
'short':           Base64 without padding.
Hashing method:
'SHA-1', 'SHA-256', 'SHA-384', 'SHA-512', 'MD2', 'MD5'.
Call DataHash without inputs to get a list of available methods.

Default: 'MD5', 'hex', 'array'

OUTPUT:
Hash: String, DOUBLE or UINT8 vector. The length depends on the hashing
method.
If DataHash is called without inputs, a struct is replied:
.HashVersion: Version number of the hashing method of this tool. In
case of bugs or additions, the output can change.
.Date: Date of release of the current HashVersion.
.HashMethod: Cell string of the recognized hash methods.

EXAMPLES:
Default: MD5, hex:
DataHash([])                      % 5b302b7b2099a97ba2a276640a192485
MD5, Base64:
DataHash(int32(1:10), 'short', 'MD5')  % +tJN9yeF89h3jOFNN55XLg
SHA-1, Base64:
S.a = uint8([]);
S.b = {{1:10}, struct('q', uint64(415))};
DataHash(S, 'SHA-1', 'HEX')       % 18672BE876463B25214CA9241B3C79CC926F3093
SHA-1 of binary values:
DataHash(1:8, 'SHA-1', 'bin')     % 826cf9d3a5d74bbe415e97d4cecf03f445f69225
SHA-256, consider ASCII part only (Matlab's CHAR has 16 bits!):
DataHash('abc', 'SHA-256', 'ascii')
ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
Or equivalently by converting the input to UINT8:
DataHash(uint8('abc'), 'SHA-256', 'bin')

NOTES:
Function handles and user-defined objects cannot be converted uniquely:
- The subfunction ConvertFuncHandle uses the built-in function FUNCTIONS,
but the replied struct can depend on the Matlab version.
- It is tried to convert objects to UINT8 streams in the subfunction
ConvertObject. A conversion by STRUCT() might be more appropriate.
Adjust these subfunctions on demand.

MATLAB CHARs have 16 bits! Use Opt.Input='ascii' for comparisons with e.g.
online hash generators.

Matt Raum suggested this for e.g. user-defined objects:
DataHash(getByteStreamFromArray(Data))
This works very well, but unfortunately getByteStreamFromArray is
undocumented, such that it might vanish in the future or reply different
output.

For arrays the calculated hash value might be changed in new versions.
Calling this function without inputs replies the version of the hash.

The older style for input arguments is accepted also: Struct with fields
'Input', 'Method', 'OutFormat'.

The C-Mex function GetMD5 is 2 to 100 times faster, but obtains MD5 only:
http://www.mathworks.com/matlabcentral/fileexchange/25921

Tested: Matlab 2009a, 2015b(32/64), 2016b, 2018b, Win7/10
Author: Jan Simon, Heidelberg, (C) 2011-2019 matlab.2010(a)n(MINUS)simon.de

Michael Kleder, "Compute Hash", no structs and cells:
http://www.mathworks.com/matlabcentral/fileexchange/8944
Tim, "Serialize/Deserialize", converts structs and cells to a byte stream:
http://www.mathworks.com/matlabcentral/fileexchange/29457
$JRev: R-R V:043 Sum:VbfXFn6217Hp Date:18-Apr-2019 12:11:42 $
$License: BSD (use/copy/change/redistribute on own risk, mention the author) $
$UnitTest: uTest_DataHash $
$File: Tools\GLFile\DataHash.m $
History:
001: 01-May-2011 21:52, First version.
007: 10-Jun-2011 10:38, [Opt.Input], binary data, complex values considered.
011: 26-May-2012 15:57, Fixed: Failed for binary input and empty data.
014: 04-Nov-2012 11:37, Consider Mex-, MDL- and P-files also.
Thanks to David (author 243360), who found this bug.
Jan Achterhold (author 267816) suggested to consider Java objects.
016: 01-Feb-2015 20:53, Java heap space exhausted for large files.
Now files are process in chunks to save memory.
017: 15-Feb-2015 19:40, Collsions: Same hash for different data.
Examples: zeros(1,1) and zeros(1,1,0)
complex(0) and zeros(1,1,0,0)
Now the number of dimensions is included, to avoid this.
022: 30-Mar-2015 00:04, Bugfix: Failed for strings and [] without TYPECASTX.
Ross found these 2 bugs, which occur when TYPECASTX is not installed.
If you need the base64 format padded with '=' characters, adjust
fBase64_enc as you like.
026: 29-Jun-2015 00:13, Changed hash for STRUCTs.
Struct arrays are analysed field by field now, which is much faster.
027: 13-Sep-2015 19:03, 'ascii' input as abbrev. for Input='bin' and UINT8().
028: 15-Oct-2015 23:11, Example values in help section updated to v022.
029: 16-Oct-2015 22:32, Use default options for empty input.
031: 28-Feb-2016 15:10, New hash value to get same reply as GetMD5.
New Matlab version (at least 2015b) use a fast method for TYPECAST, such
that calling James Tursa's TYPECASTX is not needed anymore.
Matlab 6.5 not supported anymore: MException for CATCH.
033: 18-Jun-2016 14:28, BUGFIX: Failed on empty files.
Thanks to Christian (AuthorID 2918599).
035: 19-May-2018 01:11, STRING type considered.
040: 13-Nov-2018 01:20, Fields of Opt not case-sensitive anymore.
041: 09-Feb-2019 18:12, ismethod(class(V),) to support R2018b.
042: 02-Mar-2019 18:39, base64: in Java, short: Base64 with padding.
Unit test. base64->short.
OPEN BUGS:
Nath wrote:
function handle refering to struct containing the function will create
infinite loop. Is there any workaround ?
Example:
d= dynamicprops();
addprop(d,'f');
d.f= @(varargin) struct2cell(d);
DataHash(d.f) % infinite loop
This is caught with an error message concerning the recursion limit now.
#ok<*CHARTEN>
Reply current version if called without inputs: ------------------------------



!!! info "See Also"
    * [TYPECAST](https://www.mathworks.com/help/matlab/ref/typecast.html)
    * [CAST](https://www.mathworks.com/help/matlab/ref/cast.html)





-------

### adjust_volume

For use in A-X experimental protocols.
adjust_volume is a utility to dynamically adjust the target sound volume via a scaling factor.
Opens a GUI using a standard MATLAB figure window with a slider for scaling the target sound audio and a button for replaying the sound compared to an unchanged stimulus noise.  





-------

### allcomb

ALLCOMB - All combinations
B = ALLCOMB(A1,A2,A3,...,AN) returns all combinations of the elements
in the arrays A1, A2, ..., and AN. B is P-by-N matrix is which P is the product
of the number of elements of the N inputs. This functionality is also
known as the Cartesian Product. The arguments can be numerical and/or
characters, or they can be cell arrays.

Examples:
allcomb([1 3 5],[-3 8],[0 1]) % numerical input:
-> [ 1  -3   0
1  -3   1
1   8   0
...
5  -3   1
5   8   1 ] ; % a 12-by-3 array

allcomb('abc','XY') % character arrays
-> [ aX ; aY ; bX ; bY ; cX ; cY] % a 6-by-2 character array

allcomb('xy',[65 66]) % a combination
-> ['xA' ; 'xB' ; 'yA' ; 'yB'] % a 4-by-2 character array

allcomb({'hello','Bye'},{'Joe', 10:12},{99999 []}) % all cell arrays
-> {  'hello'  'Joe'        [99999]
'hello'  'Joe'             []
'hello'  [1x3 double] [99999]
'hello'  [1x3 double]      []
'Bye'    'Joe'        [99999]
'Bye'    'Joe'             []
'Bye'    [1x3 double] [99999]
'Bye'    [1x3 double]      [] } ; % a 8-by-3 cell array

ALLCOMB(..., 'matlab') causes the first column to change fastest which
is consistent with matlab indexing. Example: 
allcomb(1:2,3:4,5:6,'matlab') 
-> [ 1 3 5 ; 1 4 5 ; 1 3 6 ; ... ; 2 4 6 ]

If one of the arguments is empty, ALLCOMB returns a 0-by-N empty array.

Tested in Matlab R2015a
version 4.1 (feb 2016)
(c) Jos van der Geest
email: samelinoa@gmail.com

History
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

T = binnedrepr2spect(binned_repr, B)
T = binnedrepr2spect(binned_repr, B, n_bins)

Get the stimuli spectra from a binned representation.

ARGUMENTS:
binned_repr: n_trials x n_bins matrix
representing the amplitude in each frequency bin
for each trial
B: 1 x n_frequencies vector
representing the bin numbers
(e.g., [1, 1, 2, 2, 2, 3, 3, 3, 3, ...])
n_bins: 1x1 scalar
representing the number of bins
if not passed as an argument,
it is computed from the maximum of B

OUTPUTS:
T: n_trials x n_frequencies matrix
representing the stimulus spectra



!!! info "See Also"
    * [spect2binnedrepr](./#spect2binnedrepr)





-------

### collect_parameters

Read parameters out from character vectors of text contained in
a character vector or cell array.

Arguments:
filenames: cell array of character vectors or character vector
Contains the filenames (or text strings)
to read parameters out of.
If `filenames` is a cell array, parameters are read from each
character vector contained in the cell array.
Filenames should not have file endings like '.csv'.
The regular expressions are not sophisticated enough to skip them.

Outputs:
data_table: table

Example:
data_table = collect_parameters(filenames)



!!! info "See Also"
    * [collect_reconstructions](./#collect_reconstructions)
    * [collect_data](./#collect_data)
    * [config2table](./#config2table)





-------

### collect_reconstructions

Collect reconstructions (or other data) from .csv files
following a naming convention.
Returns a matrix of all the data.

While this function was intended to read reconstructions,
it should be able to return data
from any .csv files containing data that can be represented
in a MATLAB matrix (e.g., numerical data of the same length).

Arguments:
data_struct: struct vector or character vector
A struct containing the output of a call to dir()
indicating which files to extract from or a character vector
which is used as an argument for dir() (e.g., dir(data_struct)).
The regular expression
is used to filter the data struct
based on the filenames.

Outputs:
reconstructions: numerical matrix
m x n matrix that contains the numerical data,
where m is the length of the data
and n is the number of files.

reconstruction_files: cell array of character vectors
Contains the filepaths to each file read,
corresponding to the columns of `reconstructions`.



!!! info "See Also"
    * [collect_data](./#collect_data)
    * [dir](https://www.mathworks.com/help/matlab/ref/dir.html)





-------

### config2table

Take information from directory containing config files and return
a table with all relevant information for each config.

Arguments: 
curr_dir: struct
Directory information containing config file name, path, and other
returns from dir() function.

Outputs: 
data_table: table



!!! info "See Also"
    * [parse_config](./#parse_config)





-------

### create_files_and_stimuli

Create files for the stimuli, responses, and metadata and create the stimuli.
Write the stimuli into the stimuli file.



!!! info "See Also"
    * [Protocol](../experiment/#protocol)





-------

### cs  

[x] = cs(responses, Phi)

ARGUMENTS:
responses: n x 1 vector
Phi: n x m matrix
where n is the number of trials/samples
and m is the dimensionality of the stimuli/spectrum/bins





-------

### filematch
Match files by terminal UUID or other identifier.
This function expects filenames in the form

foo_bar_UUID.baz

Where foo_bar can be anything,
so long as the UUID or other identifier comes last
before the 'dot filetype'.
The functions returns indices of unmatched files.

USAGE:

filematch(files1, files2)



!!! info "See Also"
    * [collect_data](./#collect_data)





-------

### parse_config 

Read a config file and perform any special parsing that is required.

Arguments:
config_file: character vector, default: []
Path to the config file to be used.
If empty, opens a GUI to find the file using a file browser.

Outputs:
config: struct



!!! info "See Also"
    * [ReadYaml](https://github.com/llerussell/ReadYAML/blob/master/ReadYaml.m)





-------

### prop2str

Converts the property names and values of a struct or object
into a character vector.
For example, a struct, s, with the properties, s.a = 1, s.b = 2,
would become 'a=1-b=2'.
If some of the property values are cell arrays,
they should be character vectors or numerical vectors
and of the same type within each cell array.

Arguments:

obj: 1x1 struct or object
Object with properties to be stringified

properties_to_skip: character vector or cell array
Properties to not include in the output character vector.

property_separator: character vector
What separator to use between parameter statements.

Returns:

stringified_properties: character vector

Example:

stringified_properties = prop2str(obj, [], '&&')



!!! info "See Also"
    * [collect_parameters](./#collect_parameters)





-------

### spect2binnedrepr

binned_repr = spect2binnedrepr(T, B)
binned_repr = spect2binnedrepr(T, B, n_bins)

Get the binned representation,
which is a vector containing the amplitude
of the spectrum in each frequency bin.

ARGUMENTS:
T: n_trials x n_frequencies matrix
representing the stimulus spectra

B: 1 x n_frequencies vector
representing the bin numbers
(e.g., [1, 1, 2, 2, 2, 3, 3, 3, 3, ...])

n_bins: 1x1 scalar
representing the number of bins
if not passed as an argument,
it is computed from the maximum of B

OUTPUTS:
binned_repr: n_trials x n_bins matrix
representing the amplitude for each frequency bin
for each trial



!!! info "See Also"
    * [binnedrepr2spect](./#binnedrepr2spect)





-------

### str2prop
Converts a string of properties and values
into a struct or cell array.
TODO: more documentation, use property_separator

Arguments:

prop_string: character vector
String containing property : value pairs

properties_to_skip: character vector or cell array
Properties to not incude in the output character vector

property_separator: character vector
What separator to use between parameter statements.

Returns:

obj: struct or cell array


Example:

obj = str2prop(prop_string, [], '&&')



!!! info "See Also"
    * [collect_parameters](./#collect_parameters)





-------

### subject_selection_process

Returns a response vector and the stimuli
where the response vector is made of up -1 and 1 values
corresponding to yes and no statements
about how well the stimuli correspond to the target signal.

y = subject_selection_process(target_signal, stimuli)

[y, X] = subject_selection_process(target_signal, [], n_samples)

Arguments:

target_signal: n x 1 numerical vector
The signal to compare against (e.g., the tinnitus signal).

stimuli: numerical matrix
An m x n matrix where m is the number of samples/trials
and n is the same length as the target signal.
If stimuli is empty, a random Bernoulli matrix (p = 0.5) is used.

n_samples: integer scalar
How many samples are used when generating the Bernoulli matrix default
for stimuli, if the stimuli argument is empty.

Returns:

y: numerical vector
Vector of -1 and 1 corresponding to negative and positive responses.

X: numerical matrix
The stimuli.



!!! info "See Also"
    * [AbstractStimulusGenerationMethod.subject_selection_process](../stimulus_generation/AbstractStimulusGenerationMethod/#subject_selection_process)





-------

### wav2spect 

Reads an audio file (e.g., a .wav file) and returns a spectrum
in terms of magnitudes, s, and frequencies, f, in Hz.



