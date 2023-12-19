classdef UniformPriorRandomNBinsStimulusGeneration < AbstractBinnedStimulusGenerationMethod
    properties
        n_bins_range (1,:) {mustBePositive, mustBeInteger} = 2.^(2:7);
    end
end


