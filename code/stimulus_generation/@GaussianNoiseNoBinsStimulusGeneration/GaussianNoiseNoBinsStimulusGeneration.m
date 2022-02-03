classdef GaussianNoiseNoBinsStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method
    % in which each frequency's amplitude is chosen according to a Gaussian distribution.

    properties
        amplitude_mean (1,1) {mustBeReal} = -10
        amplitude_var (1,1) {mustBeReal} = 3
    end

end % classdef