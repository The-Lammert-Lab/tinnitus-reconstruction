classdef HierarchicalGaussianStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method in which 
    % stimuli are formed by applying random weights 
    % to a predetermined basis of Gaussians.

    properties
        n_broad {mustBeInteger, mustBeGreaterThanOrEqual(n_broad,0)} = 3
        n_med {mustBeInteger, mustBeGreaterThanOrEqual(n_med,0)} = 8
        n_narrow {mustBeInteger, mustBeGreaterThanOrEqual(n_narrow,0)} = 6

        broad_std {mustBePositive, mustBeReal} = 8000
        med_std {mustBePositive, mustBeReal} = 2000
        narrow_std {mustBePositive, mustBeReal} = 100

        scale_fact {mustBePositive, mustBeReal} = 40
    end
end
