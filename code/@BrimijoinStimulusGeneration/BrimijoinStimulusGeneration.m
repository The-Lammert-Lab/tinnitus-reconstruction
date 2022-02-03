classdef BrimijoinStimulusGeneration < AbstractStimulusGenerationMethod
    % Stimulus generation method
    % in which each tonotopic bin is filled with an amplitude
    % value from an equidistant list with equal probability.

    properties
        amplitude_values (1,:) {mustBeReal} = linspace(-20, 0, 6)
        n_bins (1,1) {mustBePositive, mustBeReal} = 100
    end

end % classdef