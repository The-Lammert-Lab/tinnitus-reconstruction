classdef UniformPriorStimulusGeneration < AbstractBinnedStimulusGenerationMethod    
    % Stimulus generation method
    % in which the number of filled bins is selected
    % from a uniform distribution on [min_bins, max_bins].

    properties
        min_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 10
        max_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 50
        % n_bins (1,1) {mustBePositive, mustBeInteger, mustBeReal} = 100
    end

end % classdef