# Documentation Styleguide

This is a styleguide for the documentation of tinnitus-project. 
Documentation is created by running `build_docs.py`, which processes every `.m` file in the repository.
This guide is intended as both a reference for consistency of documentation and syntax processable by `build_docs.py`.

## Header Files

In order for documentation to be written for the contents of a directory, there must exist a file in the `tinnitus-project/docs` directory named `dirname-head.md`, where `dirname` is the name of the directory for which the documentation is being generated. 
The contents of this file will be placed at the beginning of the documentation page, after which in-file documentation will be written. 
This header file is only editable directly and is *not* overwritten at each regeneration of the documentation. 

## Beginning Documentaiton

For all functions and scripts, the documentation must be in the form of comments preceeding all code in the file ([Abstract Class Documentation](#abstract-class-documentation) is an exception to this). 
In order for a code file to be incorporated into the documentation, the filename, excluding `.m` must be written at the beginning of the documentation text. 
Be sure to place three `#` signs in front of the filename so that the file is formatted as "Heading level 3". For example, documentation for `Protocol.m` would begin with: `% ### Protocol`.

!!! note
    Documentation will still be created so long as the filename is present, regardless of heading style.

If one wishes to exclude documentation from the site for any reason, simply do not put the filename as a standalone comment line.

## Ending Documentation

For all functions and scripts, the recorded documentation will end at the beginning of the code. 
However, for scripts (which do not have a clear `function` demarcation for the beginning of the code), it is best practice to mark the desired end of the documentation with `% End of documentation` (case insensitive).
This will avoid capturing any code-specific comments, such as section headers, in the documentation.

## Formatting

At minimum, all documentation should include two things:

- **A description of the purpose of the code**
    - Plain English description of what the code does.
- **A list of outputs**
    - Written with the header `**OUTPUTS:**` followed by a blank new line and the ouputs listed on subsequent lines with `-` markers.
    Place a colon before the output description and enclose any dimensionality information (e.g., matrix size) within backticks. 
    Scripts should also have outputs listed even for figures, saved files, etc.
    See the [here](#example) for an example.

Additional information may include:

- **An example of a function call**
    - This is most useful if there are optional arguments to illustrate the ways in which the function may be called.
    Enclose the example using a fenced code block as in:
    ~~~display
    ```matlab
    function call example
    ```
    ~~~
- **A list of arguments**
    - Written with the header `**ARGUMENTS:**` followed by a blank new line and the arguments listed on subsequent lines with `-` markers.
    Place a colon before the argument description and enclose any dimensionality information (e.g., matrix size) within backticks. 
    Be sure to note optional arguments and their default values.
    See the [here](#example) for an example.
- **A "See Also" section**
    - A list of other functions relevant to the current file. 
    Write `See Also:` (case insensitive, colon not necessary) on its own line followed by the relevant filenames on subsequent, individual lines.
    Documentation will autoformat to the proper call-out box. 
    
    For basic scripts and functions, just write the filename:
    ```matlab
    % See Also: 
    % collect_reconstructions
    % collect_data
    % config2table
    ```
    Class methods must be written as `classname.method`:
    ```matlab
    % See Also: 
    % PowerDistributionStimulusGeneration.from_file
    ```
    To preformat the reference, use the syntax ``* [reference](link)``, 
    where `reference` is the text that will be hyperlinked, and `link` is the redirection location. 
    This is useful for references to other repositories or documentation:
    ```matlab
    % See Also: 
    % * [ReadYaml](https://github.com/llerussell/ReadYAML/blob/master/ReadYaml.m)
    ```

## Example

An example of a fully documented and formatted function:

```matlab
% ### binnedrepr2spect  
% 
% ```matlab
%   T = binnedrepr2spect(binned_repr, B)
%   T = binnedrepr2spect(binned_repr, B, n_bins)
% ```
%
% Get the stimuli spectra from a binned representation.
%
% **ARGUMENTS:**
% 
%   - binned_repr: `n_trials x n_bins` matrix
%       representing the amplitude in each frequency bin
%       for each trial.
%   - B: `1 x n_frequencies` vector
%       representing the bin numbers
%       (e.g., `[1, 1, 2, 2, 2, 3, 3, 3, 3, ...]`)
%   - n_bins: `1 x 1` scalar
%       representing the number of bins
%       if not passed as an argument,
%       it is computed from the maximum of B
% 
% **OUTPUTS:**
% 
%   - T: `n_trials x n_frequencies` matrix
%       representing the stimulus spectra
% 
% See Also:
% spect2binnedrepr
```

!!! note
    Be sure to avoid too much text on a single line so as to maintain readability of the documentation within the file itself.

## Abstract Class Documentation

For abstract classes, the preferred documentation style is slightly different. 
Because the abstract methods are all written within the same file, it improves code readability to keep the documentation inside each function, rather than before the `function` statement as done elsewhere. 
Choosing to place comments before or after the `function` statement does not affect the generated documentation, only the readability for those working directly with the code. 