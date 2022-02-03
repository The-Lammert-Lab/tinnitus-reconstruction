classdef BernoulliStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method
    % in which each tonotopic bin has a probability `p`
    % of being at 0 dB, otherwise it is at -20 dB.

    properties
        bin_prob (1,1) {mustBePositive, mustBeReal, mustBeLessThanOrEqual(bin_prob, 1)} = 0.3
        n_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 100
    end

end % classdef