classdef BernoulliStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method
    % in which each tonotopic bin has a probability `p`
    % of being at 0 dB, otherwise it is at -20 dB.

    properties
        bin_prob (1,1) {mustBePositive, mustBeReal} = 0.3
        n_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 100
    end

    methods

        function [stim, Fs, X, binned_repr] = generate_stimulus(self)
            % Generate a matrix of stimuli
            % where the matrix is of size nfft x n_trials.
            % Bins are filled with an an amplitude of -20 or 0.
            % Each bin is randomly filled with a change of being filled
            % (amplitude = 0) with a probability of `self.bin_prob`.
            %
            % Class Properties Used
            %   n_bins
            %   bin_prob

            % Define Frequency Bin Indices 1 through self.n_bins
            [binnum, Fs, nfft] = self.get_freq_bins();

            % fill the bins
            X = zeros(nfft/2, 1);
            binned_repr = zeros(self.n_bins, 1);
            
            % get the amplitude values
            amplitude_values = -20 * ones(self.n_bins, 1);
            amplitude_values(rand(self.n_bins, 1) < self.bin_prob) = 0;

            for ii = 1:self.n_bins
                binned_repr(ii) = amplitude_values(ii);
                X(binnum==ii) = amplitude_values(ii);
            end

            % Synthesize Audio
            stim = self.synthesize_audio(X, nfft);
        end % function

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
                [stimuli_matrix(:, ii), ~, spect_matrix(:, 1), binned_repr_matrix(:, ii)] = self.bernoulli_generate_stimuli();
            end
        end % function
            
    end % methods

end % classdef