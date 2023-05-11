% ### subject_selection_process
% 
% Returns a response vector and the stimuli
% where the response vector is made of up -1 and 1 values
% corresponding to yes and no statements
% about how well the stimuli correspond to the representation.
% 
% ```matlab
%   y = subject_selection_process(representation, stimuli)
%   y = subject_selection_process(representation, stimuli, [], responses, 'mean_zero', true, 'response_thresh', 'noes')
%   [y, X] = subject_selection_process(representation, [], n_samples)
% ```
% 
% **ARGUMENTS:**
% 
%   - representation: `n x 1` numerical vector,
%       the signal to compare against (e.g., the tinnitus signal).
% 
%   - stimuli: numerical matrix,
%       an `m x n` matrix where m is the number of samples/trials
%       and n is the same length as the representation.
%       If stimuli is empty, a random Bernoulli matrix (p = 0.5) is used.
%   
%   - n_samples: integer scalar
%       representing how many samples are used when generating the Bernoulli matrix default
%       for stimuli, if the stimuli argument is empty.
% 
%   - responses: `m x 1` numerical vector, 
%       which contains only `-1` and `1` values,
%       used to determine the threshold if using one of the custom options.
% 
%   - options.mean_zero: `bool`, default: false, 
%       representing a flag that centers the mean of the stimuli and representation.
% 
%   - options.response_thresh: `char`, either: `'yesses'` or `'noes'`, default: `''`,
%       which determines by what measure the threshold 
%       for choosing a "yes" response is determined. The default results in
%       50% threshold. If using this option, `responses` must be passed as well.
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

function [y, X] = subject_selection_process(representation, stimuli, n_samples, responses, options)
    
    arguments
        representation (:,1) {mustBeReal}
        stimuli (:,:) {mustBeReal}
        n_samples {mustBePositive, mustBeInteger} = []
        responses (:,1) {mustBeNumeric} = []
        options.mean_zero (1,1) logical = false
        options.from_responses (1,1) logical = false
        options.threshold {mustBePositive} = 50
        options.verbose (1,1) logical = true
    end

    if isempty(stimuli)
        X = round(rand(n_samples, length(representation)));
    else
        X = stimuli;
    end

    % Projection
    if options.mean_zero
        e = (X - mean(X,2)) * (representation(:) - mean(representation(:)));
    else
        e = X * representation(:);
    end

    % Threshold is percent of "no" answers in given responses or 50%.
    % Thresh is percent of "no" answers in predicted resopnse.
    if options.from_responses
        if options.verbose
            corelib.verb(options.verbose, 'INFO: subject_selection_process', 'setting threshold from responses')
        end
        thresh = 100 * sum(responses == -1)/length(responses);
    else
        thresh = options.threshold;
    end

    % Make selection
    y = double(e >= prctile(e, thresh));
    y(y == 0) = -1;
end
