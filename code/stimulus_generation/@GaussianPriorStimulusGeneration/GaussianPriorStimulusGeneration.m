classdef GaussianPriorStimulusGeneration < AbstractBinnedStimulusGenerationMethod
    % Stimulus generation method
    % in which the number of filled bins is selected
    % from a Gaussian distribution with known mean and variance parameters.

    properties
        % n_bins (1,1) {mustBePositive, mustBeReal, mustBeInteger} = 100
        n_bins_filled_mean (1,1) {mustBePositive, mustBeReal, mustBeInteger} = 20
        n_bins_filled_var (1,1) {mustBePositive, mustBeReal} = 1
    end

end % classdef