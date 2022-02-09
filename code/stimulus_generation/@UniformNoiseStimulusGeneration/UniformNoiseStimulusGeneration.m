classdef UniformNoiseStimulusGeneration < AbstractStimulusGenerationMethod
    % no additional properties
    
    properties
        n_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 100
    end
end % classdef