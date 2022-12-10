classdef BrimijoinGaussianSmoothedStimulusGeneration < AbstractBinnedStimulusGenerationMethod
    % TODO: write some documentation

    properties
        amplitude_values (1, :) {mustBeReal} = linspace(-20, 0, 6)
    end

end % classdef