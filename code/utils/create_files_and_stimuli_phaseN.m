function [stimuli_matrix, filename_responses, filename_stimuli, filename_meta, file_hash] = create_files_and_stimuli_phaseN(config, phase, pert_bounds, data_dir, hash_prefix, options)
  arguments
        config (1,1) struct
        phase (1,1) {mustBeInteger, mustBeGreaterThan(phase,1)}
        pert_bounds (1,2) {mustBePositive}
        data_dir (1,:) char
        hash_prefix (1,:) char = ''
        options.mult_range (1,2) {mustBeReal} = []
        options.binrange_range (1,2) {mustBePositive} = []
        options.lowpass_range (1,2) {mustBePositive} = []
        options.highpass_range (1,2) {mustBePositive} = []
    end

    modify_spectrum = all(structfun(@isempty,options));

    if isempty(hash_prefix)
        hash_prefix = get_hash(config);
    end

    % Get reconstructions for previous phase
    reconstruction = get_reconstruction('config', config, 'phase', phase-1, ...
                                        'method', 'linear', 'data_dir', data_dir);

    % Generate a matrix of random values between pert_bounds
    % Pert bounds are tretaed as percentages
    perturbations = min(pert_bounds) + (max(pert_bounds)-min(pert_bounds))*rand(length(reconstruction),config.n_trials_per_block);

    % Apply noise
    binned_repr_matrix = perturbations .* reconstruction;
    
    % Generate spect and waveforms
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);
    if modify_spectrum
        filt = false;
        lp = zeros(size(binned_repr_matrix,2),1);
        hp = stimgen.max_freq*ones(size(binned_repr_matrix,2),1);
        mult = 0;
        binrange = 1;
        if ~isempty(options.mult_range)
            mult = min(options.mult_range) + (max(options.mult_range)-min(options.mult_range))*rand(config.n_trials_per_block,1);
        end

        if ~isempty(options.binrange_range)
            binrange = min(options.binrange_range) + (max(options.binrange_range)-min(options.binrange_range))*rand(config.n_trials_per_block,1);
        end

        if ~isempty(options.lowpass_range)
            lp = min(options.lowpass_range) + (max(options.lowpass_range)-min(options.lowpass_range))*rand(config.n_trials_per_block,1);
            filt = true;
        end

        if ~isempty(options.highpass_range)
            hp = min(options.highpass_range) + (max(options.highpass_range)-min(options.highpass_range))*rand(config.n_trials_per_block,1);
            filt = true;
        end
        
        [stimuli_matrix, spect_matrix] = stimgen.binnedrepr2wav(binned_repr_matrix,mult,binrange,'filter',filt,'cutoff',[lp, hp]);
    else
        % Otherwise just get spectrum and synthesize audio
        spect_matrix = stimgen.binnedrepr2spect(binned_repr_matrix);
        stimuli_matrix = stimgen.synthesize_audio(spect_matrix,stimgen.nfft);
    end

    % Hash the stimuli
    stimuli_hash = get_hash(spect_matrix);

    % Create the files needed for saving the data
    phase_prefix = ['phase', num2str(phase), '_'];
    file_hash = [hash_prefix '_',  stimuli_hash];

    filename_responses  = pathlib.join(config.data_dir, [phase_prefix, file_hash, '.csv']);
    filename_stimuli    = pathlib.join(config.data_dir, [phase_prefix, file_hash, '.csv']);
    filename_meta       = pathlib.join(config.data_dir, [phase_prefix, file_hash, '.csv']);

    % Write the stimuli to file
    if modify_spectrum && strcmp(config.stimuli_save_type,'bins')
        corelib.verb('INFO create_files_and_stimuli_phaseN', ...
            'Save type set to bins, but spectrum modifiers passed. Saving stimuli as spectrum.')
        writematrix(spect_matrix, filename_stimuli);
    else
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
    end
end
