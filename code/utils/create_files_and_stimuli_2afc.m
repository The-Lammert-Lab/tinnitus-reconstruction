% ### create_files_and_stimuli_2afc
% 
% Create files for the stimuli, responses, and metadata and create the stimuli
% for a 2-AFC experiment.
% Write the stimuli into the stimuli file.
% 
% **Arguments:**
% 
%   - config: 1x1 `struct` 
%       containing a stimulus generation configuration.
%   - stimuli_object: 1x1 `AbstractStimulusGenerationMethod`
%   - hash_prefix: 1 x n character vector, default value: `get_hash(config)`
% 
% **Outputs:**
%
%   - stimuli_matrix_1
%   - stimuli_matrix_2
%   - Fs
%   - filename_responses
%   - filename_stimuli_1
%   - filename_stimuli_2
%   - filename_meta
%   - file_hash_1
%   - file_hash_2
%   - file_hash_combined
% 
% Example:
% 
% ```matlab
%   [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, filename_stimuli_1, filename_stimuli_2, filename_meta, file_hash_1, file_hash_2, file_hash_combined] = create_files_and_stimuli_2afc(config, stimuli_object, hash_prefix)
% ```
% 
% See also:
% RevCorr

function [stimuli_matrix_1, stimuli_matrix_2, Fs, filename_responses, filename_stimuli_1, filename_stimuli_2, filename_meta, file_hash_1, file_hash_2, file_hash_combined] = create_files_and_stimuli_2afc(config, stimuli_object, hash_prefix)

    arguments
        config (1,1) struct
        stimuli_object (1,1) AbstractStimulusGenerationMethod
        hash_prefix (1,:) char = ''
    end

    if isempty(hash_prefix)
        hash_prefix = get_hash(config);
    end

    % Generate the stimuli
    [stimuli_matrix_1, Fs, spect_matrix_1, binned_repr_matrix_1] = stimuli_object.generate_stimuli_matrix();
    [stimuli_matrix_2, ~, spect_matrix_2, binned_repr_matrix_2] = stimuli_object.generate_stimuli_matrix();
    
    % Hash the stimuli
    stimuli_hash_1 = get_hash(spect_matrix_1);
    stimuli_hash_2 = get_hash(spect_matrix_2);

    % Create the files needed for saving the data
    file_hash_1 = [hash_prefix '_',  stimuli_hash_1];
    file_hash_2 = [hash_prefix '_',  stimuli_hash_2];
    file_hash_combined = [hash_prefix, '_', stimuli_hash_1, '_', stimuli_hash_2];

    filename_responses  = pathlib.join(config.data_dir, ['responses_', file_hash_combined, '.csv']);
    filename_stimuli_1    = pathlib.join(config.data_dir, ['stimuli_', file_hash_1, '.csv']);
    filename_stimuli_2    = pathlib.join(config.data_dir, ['stimuli_', file_hash_2, '.csv']);
    filename_meta       = pathlib.join(config.data_dir, ['meta_', file_hash_combined, '.csv']);

    % Write the stimuli to file
    switch config.stimuli_save_type
    case 'waveform'
        writematrix(stimuli_matrix_1, filename_stimuli_1);
        writematrix(stimuli_matrix_2, filename_stimuli_2);
    case 'spectrum'
        writematrix(spect_matrix_1, filename_stimuli_1);
        writematrix(spect_matrix_2, filename_stimuli_2);
    case 'bins'
        writematrix(binned_repr_matrix_1, filename_stimuli_1);
        writematrix(binned_repr_matrix_2, filename_stimuli_2);
    otherwise
        error(['Stimuli save type: ', config.stimuli_save_type, ' not recognized.'])
    end

end % create_files_and_stimuli