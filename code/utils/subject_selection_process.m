% ### subject_selection_process
% 
% Returns a response vector and the stimuli
% where the response vector is made of up -1 and 1 values
% corresponding to yes and no statements
% about how well the stimuli correspond to the target signal.
% 
% ```matlab
%   y = subject_selection_process(target_signal, stimuli)
%   [y, X] = subject_selection_process(target_signal, [], n_samples)
% ```
% 
% **ARGUMENTS:**
% 
%   - target_signal: `n x 1` numerical vector,
%       the signal to compare against (e.g., the tinnitus signal).
% 
%   - stimuli: numerical matrix,
%       an `m x n` matrix where m is the number of samples/trials
%       and n is the same length as the target signal.
%       If stimuli is empty, a random Bernoulli matrix (p = 0.5) is used.
%   
%   - n_samples: integer scalar
%       representing how many samples are used when generating the Bernoulli matrix default
%       for stimuli, if the stimuli argument is empty.
% 
% **OUTPUTS:**
% 
%   - y: numerical vector,
%       A vector of `-1` and `1` corresponding to negative and positive responses.
% 
%   - X: numerical matrix,
%       the stimuli.
% 
% See Also: 
% AbstractStimulusGenerationMethod.subject_selection_process

function [y, X] = subject_selection_process(target_signal, stimuli, n_samples, responses, options)
    
    arguments
        target_signal (:,1) {mustBeNumeric}
        stimuli (:,:) {mustBeNumeric, mustBeReal}
        n_samples {mustBeNumeric, mustBePositive, mustBeInteger} = []
        responses (:,1) {mustBeNumeric} = []
        options.mean_zero {mustBeNumericOrLogical} = false
        options.response_thresh char = ''
    end

    if isempty(stimuli)
        X = round(rand(n_samples, length(target_signal)));
    else
        X = stimuli;
    end

    % Projection
    if options.mean_zero
        e = (X - mean(X,2)) * (target_signal(:) - mean(target_signal(:)));
    else
        e = X * target_signal(:);
    end

    % Percentile is percent of "yes" or "no" answers if specified.
    % Otherwise, it is 50.
    if ~isempty(responses) && strcmp(options.response_thresh, 'yesses')
        thresh = 100 * sum(responses == 1)/length(responses);
    elseif ~isempty(responses) && strcmp(options.response_thresh, 'noes')
        thresh = 100 * sum(responses == -1)/length(responses);
    else
        thresh = 50;
    end

    % Make selection
    y = double(e >= prctile(e, thresh));
    y(y == 0) = -1;
end
