function write_stimuli(data_dir, stimulus_generation_name, stimuli, OVERWRITE, VERBOSE)
    % Generate and save stimuli to a .csv file.

    arguments
        data_dir (1,:) {mustBeText}
        stimulus_generation_name (1,:) {mustBeText}
        stimuli (1,1)
        OVERWRITE (1,1)
        VERBOSE (1,1)
    end

    this_filename = ['stimuli--', 'method=', stimulus_generation_name,'&&', prop2str(stimuli), '.csv'];
    this_filename = pathlib.join(data_dir, this_filename);
    this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');

    if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename)
        [stimuli_matrix, ~, spect_matrix] = stimuli.generate_stimuli_matrix();
    end

    if ~OVERWRITE && isfile(this_filename)
        corelib.verb(VERBOSE, 'INFO', [this_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_filename])
        csvwrite(this_filename, stimuli_matrix);
    end
    
    if ~OVERWRITE && isfile(this_spect_filename)
        corelib.verb(VERBOSE, 'INFO', [this_spect_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_spect_filename])
        csvwrite(this_spect_filename, spect_matrix);
    end

end % function