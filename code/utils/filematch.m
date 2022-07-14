% ### filematch
% Match files by terminal UUID or other identifier.
% This function expects filenames in the form
% 
%   `foo_bar_UUID.baz`
% 
% Where foo_bar can be anything,
% so long as the UUID or other identifier comes last
% before the 'dot filetype'.
% The functions returns indices of unmatched files.
% 
% Example:
%   
%   `filematch(files1, files2)`
% 
% See Also: 
% collect_data

function [not_matched_files1, not_matched_files2] = filematch(files1, files2, options)

    arguments
        files1 (:,1) cell
        files2 (:,1) cell
        options.delimiter (:,1) char = '_' 
    end

    % Instantiate containers for UUIDs
    files1_uuid = cell(size(files1));
    files2_uuid = cell(size(files2));

    % Extract the UUIDs from the filenames
    for ii = 1:length(files1_uuid)
        this_split = strsplit(files1{ii}, options.delimiter);
        this_split_split = strsplit(this_split{end}, '.');
        files1_uuid{ii} = this_split_split{1};
    end

    for ii = 1:length(files2_uuid)
        this_split = strsplit(files2{ii}, options.delimiter);
        this_split_split = strsplit(this_split{end}, '.');
        files2_uuid{ii} = this_split_split{1};
    end

    % Compare the UUIDs between the two containers
    not_matched_files1 = 1:length(files1_uuid);
    not_matched_files2 = 1:length(files2_uuid);

    for ii = 1:length(files1_uuid)
        % Get the current UUID from files1
        this_uuid = files1_uuid{ii};
        % Match against the remaining unmatched files2 UUIDs
        files2_match_index = strcmp(this_uuid, files2_uuid);
        % Remove matched UUIDs from files2
        % as well as from the index vectors
        if any(files2_match_index)
            files2_uuid(files2_match_index) = [];
            not_matched_files1(not_matched_files1 == ii) = [];
            not_matched_files2(files2_match_index) = [];
        end
        
    end

