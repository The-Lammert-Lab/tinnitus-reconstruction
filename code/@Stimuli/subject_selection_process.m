function [y, X] = subject_selection_process(self, signal, stimulus_type)

    % Model of a subject performing the task.
    % Takes in a signal (the gold standard)
    % and returns an n_samples x 1 vector
    % of -1 for "no"
    % and 1 for "yes"

    if nargin < 3
        stimulus_type = 'default';
    end

    switch stimulus_type
    case 'default'
        X = round(rand(length(signal), self.n_trials));
    case 'brimijoin'
        [~, ~, X, ~] = self.brimijoin_generate_stimuli_matrix();
    case 'custom'
        [~, ~, X, ~] = self.custom_generate_stimuli_matrix();
    case 'white'
        [~, ~, X, ~] = self.white_generate_stimuli_matrix();
    end

    e = X' * signal();
    y = double(e <= prctile(e, 50));
    y(y == 0) = -1;

end % function
