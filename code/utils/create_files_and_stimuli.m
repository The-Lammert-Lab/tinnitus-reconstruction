% ### create_files_and_stimuli
% 
% Create files for the stimuli, responses, and metadata and create the stimuli.
% Write the stimuli into the stimuli file.
% 
% **ARGUMENTS:**
% 
%   - config: `1 x 1` struct, the config struct to associate the files with.
%   - stimuli_object: `1 x 1` AbstractStimulusGenerationMethod, 
%       a StimulusGeneration object from which stimuli will be generated.
%   - hash_prefix: `char`, default: `''`,
%       the portion of the hash attached to the output files 
%       that appears before the spectrum matrix hash.
% 
% **OUTPUTS:**
% 
%   - stimuli_matrix: `n x p` numerical array, stimulus waveforms
%       where `n` is the length of the waveform and `p` is `config.n_trials`
%   - Fs: `1 x 1` positive scalar, the sampling rate in Hz
%   - filename_responses: `char` the full path to the empty `CSV` file 
%       in which responses can be written for this experiment.
%   - filename_stimuli: `char` the full path to the `CSV` file 
%       in which the stimuli are written according to `config.stimuli_save_type`.
%   - filename_meta: `char` the full path to the empty `CSV` file
%       in which the metadata can be written for this experiment.
%   - file_hash: `char` the full hash string associated with all the output files.
% 
% See also:
% RevCorr

function [stimuli_matrix, Fs, filename_responses, filename_stimuli, filename_meta, file_hash] = create_files_and_stimuli(config, stimuli_object, hash_prefix)

    arguments
        config (1,1) struct
        stimuli_object (1,1) AbstractStimulusGenerationMethod
        hash_prefix (1,:) char = ''
    end

    if isempty(hash_prefix)
        hash_prefix = get_hash(config);
    end

    % Generate the stimuli
    [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = stimuli_object.generate_stimuli_matrix();
    
    % Hash the stimuli
    stimuli_hash = get_hash(spect_matrix);

    % Create the files needed for saving the data
    file_hash = [hash_prefix '_',  stimuli_hash];

    filename_responses  = pathlib.join(config.data_dir, ['responses_', file_hash, '.csv']);
    filename_stimuli    = pathlib.join(config.data_dir, ['stimuli_', file_hash, '.csv']);
    filename_meta       = pathlib.join(config.data_dir, ['meta_', file_hash, '.csv']);

    % Write the stimuli to file
    switch config.stimuli_save_type
        case 'waveform'
            writematrix(stimuli_matrix, filename_stimuli);
        case 'spectrum'
            writematrix(spect_matrix, filename_stimuli);
        case 'bins'
            writematrix(binned_repr_matrix, filename_stimuli);
        otherwise
            error(['Stimuli save type: ', config.stimuli_save_type, ' not recognized.'])
    end

end % create_files_and_stimuli