function [stimuli_matrix, filename_responses, filename_stimuli, filename_meta, file_hash] = create_files_and_stimuli_phaseN(config, phase, pert_bounds, data_dir, hash_prefix)
  arguments
        config (1,1) struct
        phase (1,1) {mustBeInteger, mustBeGreaterThan(phase,1)}
        pert_bounds (1,2) {mustBePositive}
        data_dir (1,:) char
        hash_prefix (1,:) char = ''
    end

    if isempty(hash_prefix)
        hash_prefix = get_hash(config);
    end

    % Get reconstructions for previous phase
    reconstruction = get_reconstruction('config', config, 'phase', phase-1, ...
                                        'method', 'linear', 'data_dir', data_dir);

    % Generate a matrix of random values between pert_bounds
    pert_min = pert_bounds(1);
    pert_max = pert_bounds(2);

    perturbations = pert_min + (pert_min+pert_max)*rand(length(reconstruction),config.n_trials_per_block);

    % Scale approparitely
    noise = perturbations .* reconstruction;

    % Add noise to reconstruction
    stimuli_matrix = noise + repmat(reconstruction,1,config.n_trials_per_block);

    % Hash the stimuli
    stimuli_hash = get_hash(stimuli_matrix);

    % Create the files needed for saving the data
    phase_prefix = ['phase', num2str(phase), '_'];
    file_hash = [hash_prefix '_',  stimuli_hash];

    filename_responses  = pathlib.join(config.data_dir, [phase_prefix, file_hash, '.csv']);
    filename_stimuli    = pathlib.join(config.data_dir, [phase_prefix, file_hash, '.csv']);
    filename_meta       = pathlib.join(config.data_dir, [phase_prefix, file_hash, '.csv']);

    % Write the stimuli to file
    writematrix(binned_repr_matrix, filename_stimuli);

end
