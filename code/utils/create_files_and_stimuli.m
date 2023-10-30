% ### create_files_and_stimuli
% 
% Create files for the stimuli, responses, and metadata and create the stimuli.
% Write the stimuli into the stimuli file.
% 
% See also:
% Protocol

function [stimuli_matrix, Fs, filename_responses, filename_stimuli, filename_meta, file_hash] = create_files_and_stimuli(config, stimuli_object, hash_prefix, exp_phase)

    arguments
        config (1,1) struct
        stimuli_object (1,1) AbstractStimulusGenerationMethod
        hash_prefix (1,:) char = ''
        exp_phase (1,1) {mustBeInteger} = 1
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

    if exp_phase > 1
        phase_prefix = ['phase', num2str(exp_phase), '_'];
    else
        phase_prefix = '';
    end

    filename_responses  = pathlib.join(config.data_dir, [phase_prefix, 'responses_', file_hash, '.csv']);
    filename_stimuli    = pathlib.join(config.data_dir, [phase_prefix, 'stimuli_', file_hash, '.csv']);
    filename_meta       = pathlib.join(config.data_dir, [phase_prefix, 'meta_', file_hash, '.csv']);

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