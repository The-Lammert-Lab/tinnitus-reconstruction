function write_stimuli(data_dir, stimulus_generation_name, stimuli, OVERWRITE, VERBOSE, properties_to_skip)
    % Generate and save stimuli to a .csv file.

    arguments
        data_dir (1,:) {mustBeText}
        stimulus_generation_name (1,:) {mustBeText}
        stimuli (1,1)
        OVERWRITE (1,1)
        VERBOSE (1,1)
        properties_to_skip = {}
    end

    this_filename = ['stimuli--', 'method=', stimulus_generation_name,'&&', prop2str(stimuli, properties_to_skip), '.csv'];
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
    if ~OVERWRITE && isfile(this_filename)
        corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_filename])
        csvwrite(this_filename, stimuli_matrix);
    end
    
    % If overwrite is false and the spectrum file exists, don't recreate it.
    if ~OVERWRITE && isfile(this_spect_filename)
        corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_spect_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_spect_filename])
        csvwrite(this_spect_filename, spect_matrix);
    end

    % If overwrite is false, and the bin representation file exists (for a stimulus generation method with bins),
    % don't recreate it.
    if ~OVERWRITE && isfile(this_binrep_filename)
        corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_binrep_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_binrep_filename])
        csvwrite(this_binrep_filename, binrep_matrix)
    end

end % function