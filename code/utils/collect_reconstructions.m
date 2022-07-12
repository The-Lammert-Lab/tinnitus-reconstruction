% ### collect_reconstructions
% 
% Collect reconstructions (or other data) from .csv files
% following a naming convention.
% Returns a matrix of all the data.
% 
% While this function was intended to read reconstructions,
% it should be able to return data
% from any .csv files containing data that can be represented
% in a MATLAB matrix (e.g., numerical data of the same length).
% 
% Arguments:
%   data_struct: struct vector or character vector
%       A struct containing the output of a call to dir()
%       indicating which files to extract from or a character vector
%       which is used as an argument for dir() (e.g., dir(data_struct)).
%       The regular expression
%       is used to filter the data struct
%       based on the filenames.
% 
% Outputs:
%   reconstructions: numerical matrix
%      m x n matrix that contains the numerical data,
%      where m is the length of the data
%      and n is the number of files.
% 
%   reconstruction_files: cell array of character vectors
%       Contains the filepaths to each file read,
%       corresponding to the columns of `reconstructions`.
% 
% See Also: 
% collect_data
% * [dir](https://www.mathworks.com/help/matlab/ref/dir.html)

function [reconstructions, reconstruction_files] = collect_reconstructions(data_struct)

    arguments
        data_struct (:,1)
    end

    % Force conversion to dir-like struct
    if isa(data_struct, 'char')
        data_struct = dir(data_struct);
    end

    reconstructions = cell(size(data_struct));
    reconstruction_files = cell(size(data_struct));

    for ii = 1:length(reconstructions)
        reconstruction_files{ii} = pathlib.join(data_struct(ii).folder, data_struct(ii).name);
        reconstructions{ii} = csvread(reconstruction_files{ii});
    end

    % Convert to a matrix of n_fft x n_param_sets
    reconstructions = [reconstructions{:}];

end % function