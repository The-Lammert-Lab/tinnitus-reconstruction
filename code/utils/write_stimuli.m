function write_stimuli(data_dir, stimulus_generation_name, stimuli, OVERWRITE, VERBOSE, properties_to_skip, stimuli_kinds)
    % Generate and save stimuli to a .csv file.

    arguments
        data_dir (1,:) {mustBeText}
        stimulus_generation_name (1,:) {mustBeText}
        stimuli (1,1) AbstractStimulusGenerationMethod
        OVERWRITE (1,1) logical
        VERBOSE (1,1) logical
        properties_to_skip (1,:) cell = {}
        stimuli_kinds (1,:) cell = {'waveform', 'spectrum', 'bins'}
    end

    this_filename = ['stimuli--', 'stimuli_type=', stimulus_generation_name,'&&', prop2str(stimuli, properties_to_skip), '.csv'];
    this_filename = pathlib.join(data_dir, this_filename);
    this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');
    this_binrep_filename = strrep(this_filename, 'stimuli--', 'stimuli-binrep--');

    % If overwrite is true, or if the stimuli file or spectrum file don't exist,
    % or if the bin representation file doesn't exist and the stimulus generation method
    % uses bins,
    % generate data for them.
    if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename) || ~isfile(this_binrep_filename)
        [stimuli_matrix, ~, spect_matrix, binrep_matrix] = stimuli.generate_stimuli_matrix();
    end

    % If overwrite is false, and the stimuli file exists, don't recreate it.
    if any(strcmp(stimuli_kinds, 'waveform'))
        if ~OVERWRITE && isfile(this_filename)
            corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_filename, ' exists, not recreating'])
        else
            corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_filename])
            writematrix(stimuli_matrix, this_filename);
        end
    end
    
    % If overwrite is false and the spectrum file exists, don't recreate it.
    if any(strcmp(stimuli_kinds, 'spectrum'))
        if ~OVERWRITE && isfile(this_spect_filename)
            corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_spect_filename, ' exists, not recreating'])
        else
            corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_spect_filename])
            writematrix(spect_matrix, this_spect_filename);
        end
    end

    % If overwrite is false, and the bin representation file exists (for a stimulus generation method with bins),
    % don't recreate it.
    if any(strcmp(stimuli_kinds, 'bins'))
        if ~OVERWRITE && isfile(this_binrep_filename)
            corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_binrep_filename, ' exists, not recreating'])
        else
            corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_binrep_filename])
            writematrix(binrep_matrix, this_binrep_filename)
        end
    end

end % function