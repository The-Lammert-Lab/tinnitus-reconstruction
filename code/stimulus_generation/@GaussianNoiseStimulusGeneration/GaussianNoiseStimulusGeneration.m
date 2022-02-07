classdef GaussianNoiseStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method
    % in which each tonotopic bin is filled
    % with amplitude chosen from a Gaussian distribution.

    properties
        n_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 100
        amplitude_mean (1,1) {mustBeReal} = -10
        amplitude_var (1,1) {mustBeReal} = 3
    end

end % classdef