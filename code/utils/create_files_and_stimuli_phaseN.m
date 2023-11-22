function [stimuli_matrix, filename_responses, filename_stimuli, filename_meta, file_hash] = create_files_and_stimuli_phaseN(config, phase, pert_bounds, data_dir, hash_prefix, reconstruction, options)
  arguments
        config (1,1) struct
        phase (1,1) {mustBeInteger, mustBeGreaterThan(phase,1)}
        pert_bounds (1,2) {mustBePositive}
        data_dir (1,:) char
        hash_prefix (1,:) char = ''
        reconstruction (:,1) {mustBeReal} = []
        options.mult_range (:,:) {mustBeReal} = []
        options.binrange_range (:,:) {mustBePositive} = []
        options.lowcut_range (:,:) {mustBeGreaterThanOrEqual(options.lowcut_range,0)} = []
        options.highcut_range (:,:) {mustBePositive} = []
    end

    modify_spectrum = ~all(structfun(@isempty,options));

    if isempty(hash_prefix)
        hash_prefix = get_hash(config);
    end

    % Get reconstructions for previous phase
    if ~isempty(config) && isempty(options.reconstruction)
        reconstruction = get_reconstruction('config', config, 'phase', phase-1, ...
                                            'method', 'linear', 'data_dir', data_dir);
    end

    % Generate a matrix of random values between pert_bounds
    % Pert bounds are tretaed as percentages
    p = min(pert_bounds) + (max(pert_bounds)-min(pert_bounds))*rand(length(reconstruction),config.n_trials_per_block);

    % Apply noise
    binned_repr_matrix = p .* reconstruction;
    
    % Generate spect and waveforms
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);
    if modify_spectrum
        filt = false;
        lc = zeros(size(binned_repr_matrix,2),1);
        hc = stimgen.max_freq*ones(size(binned_repr_matrix,2),1);
        mult = 0;
        binrange = 1;
        if ~isempty(options.mult_range)
            mult = rand_vec_in_range(config.n_trials_per_block, min(options.mult_range), max(options.mult_range));
        end

        if ~isempty(options.binrange_range)
            binrange = rand_vec_in_range(config.n_trials_per_block, min(options.binrange_range), max(options.binrange_range));
        end

        if ~isempty(options.lowcut_range)
            lc = rand_vec_in_range(config.n_trials_per_block, min(options.lowcut_range), max(options.lowcut_range));
            filt = true;
        end

        if ~isempty(options.highcut_range)
            hc = rand_vec_in_range(config.n_trials_per_block, min(options.highcut_range), max(options.highcut_range));
            filt = true;
        end
        
        [stimuli_matrix, spect_matrix] = stimgen.binnedrepr2wav(binned_repr_matrix,mult,binrange,'filter',filt,'cutoff',[lc, hc]);
        binned_repr_matrix = stimgen.spect2binnedrepr(spect_matrix);
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

    filename_responses  = pathlib.join(config.data_dir, [phase_prefix, 'responses_', file_hash, '.csv']);
    filename_stimuli    = pathlib.join(config.data_dir, [phase_prefix, 'stimuli_', file_hash, '.csv']);
    filename_meta       = pathlib.join(config.data_dir, [phase_prefix, 'meta_', file_hash, '.csv']);

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
end % function

function r = rand_vec_in_range(n,minimum,maximum)
        r = minimum + (maximum-minimum)*rand(n,1);
end
