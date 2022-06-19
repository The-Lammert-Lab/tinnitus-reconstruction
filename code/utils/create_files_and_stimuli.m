function [stimuli_matrix, Fs, filename_responses, filename_stimuli, filename_meta, file_hash] = create_files_and_stimuli(config, stimuli_object, posix_time)
    % Create files for the stimuli, responses, and metadata
    % and create the stimuli.
    % Write the stimuli into the stimuli file.


    % Hash the config struct to get a unique string representation
    config_hash = DataHash(config);
    config_hash = config_hash(1:8);

    % Generate the stimuli
    [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = stimuli_object.generate_stimuli_matrix();
    
    % Hash the stimuli
    stimuli_hash = DataHash(spect_matrix);
    stimuli_hash = stimuli_hash(1:8);

    % Create the files needed for saving the data
    file_hash = [posix_time, '_', config_hash, '_', stimuli_hash];

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