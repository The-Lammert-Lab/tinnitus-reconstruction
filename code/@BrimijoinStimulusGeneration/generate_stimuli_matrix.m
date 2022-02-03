function [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)
    % Generate matrix of stimuli
    % where the matrix is of size nfft x n_trials.

    % generate first stimulus
    binned_repr_matrix = zeros(self.n_bins, self.n_trials);
    [stim1, Fs, spect, binned_repr_matrix(:, 1)] = self.brimijoin_generate_stimuli();

    % instantiate stimuli matrix
    stimuli_matrix = zeros(length(stim1), self.n_trials);
    spect_matrix = zeros(length(spect), self.n_trials);
    stimuli_matrix(:, 1) = stim1;
    spect_matrix(:, 1) = spect;
    for ii = 2:self.n_trials
        [stimuli_matrix(:, ii), ~, spect_matrix(:, 1), binned_repr_matrix(:, ii)] = self.brimijoin_generate_stimuli();
    end

end % function