% ### update_hashes

% Updates data files that match an old hash to a new hash.
% Ordinarily this is *not* something that you want to do.
% However, there are some situations where the config spec
% changed or something was mislabeled
% and so the config hash does not match
% the hashes in the data file names.
% This function re-aligns the data to the config
% by updating the hashes.
% 
% 
% **Arguments:**
% 
% - new_hash: character vector
% - old_hash: character vector
% - data_dir: character vector
%       pointing to the directory where the data files are stored.
% 
% **Outputs:**
% - None
% 
% See Also:
% * collect_data

function update_hashes(new_hash, old_hash, data_dir, verbose)

    arguments
        new_hash (1, :) char
        old_hash (1, :) char
        data_dir (1, :) {mustBeFolder}
        verbose (1,1) logical = true
    end

    files = dir(pathlib.join(data_dir, ['*', old_hash, '*']));

    for ii = 1:length(files)
        new_filename = strrep(files(ii).name, old_hash, new_hash);
        corelib.verb(verbose, 'update_hashes', ['moving ', files(ii).name, ' to ', new_filename]);
        movefile(files(ii).name, new_filename);
    end

end % function