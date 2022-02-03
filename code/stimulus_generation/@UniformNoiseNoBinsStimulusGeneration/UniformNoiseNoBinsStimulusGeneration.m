classdef UniformNoiseNoBinsStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method
    % in which each frequency is chosen from a uniform distribution on [-20, 0] dB.

    properties
        n_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 100
    end

end % classdef