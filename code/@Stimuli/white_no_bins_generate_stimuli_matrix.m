function [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = white_no_bins_generate_stimuli_matrix(self)

    % generate first stimulus
    binned_repr_matrix = [];
    [stim1, Fs, spect, ~] = self.white_no_bins_generate_stimuli();

    % instantiate stimuli matrix
    stimuli_matrix = zeros(length(stim1), self.n_trials);
    spect_matrix = zeros(length(spect), self.n_trials);
    stimuli_matrix(:, 1) = stim1;
    spect_matrix(:, 1) = spect;
    for ii = 2:self.n_trials
        [stimuli_matrix(:, ii), ~, spect_matrix(:, ii), ~] = self.white_no_bins_generate_stimuli();
    end
    
end