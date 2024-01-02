classdef BrimijoinStimulusGeneration < AbstractBinnedStimulusGenerationMethod
    % Stimulus generation method
    % in which each tonotopic bin is filled with an amplitude
    % value from an equidistant list with equal probability.

    properties
        amplitude_values (1,:) {mustBeReal} = linspace(-20, 0, 6)
    end

end % classdef