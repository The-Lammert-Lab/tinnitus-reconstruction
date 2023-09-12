% ### subject_selection_process
% 
% Returns a response vector and the stimuli
% where the response vector is made of up -1 and 1 values
% corresponding to yes and no statements
% about how well the stimuli correspond to the representation.
% 
% ```matlab
%   y = subject_selection_process(representation, stimuli)
%   y = subject_selection_process(representation, stimuli, [], responses, 'mean_zero', true, 'from_responses', true)
%   y = subject_selection_process(representation, stimuli, [], [], 'threshold', 90, 'verbose', false)
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
%   - mean_zero: `bool`, default: `false`, 
%       representing a flag that centers the mean of the stimuli and representation.
% 
%   - method: `character vector`, default: `percentile`,
%       the method to use to convert estimations into response values.
%       Options are: `percentile`, which uses the whole estimation vector
%       and `threshold`, `sign` which computes `sign(e + lambda)`,
%       and `ten_scale`, which returns values from 0-10 using.
% 
%   - from_responses: `bool`, name-value, default: `false`,
%       a flag to determine the threshold from the given responses. 
%       The default results in 50% threshold. 
%       If using this option, `responses` must be passed as well.
% 
%   - threshold: Positive scalar, name-value, default: 50,
%       representing a variable by which to manually set the response
%       threshold. If `from_responses` is true, this will be ignored.
% 
%   - ten_scale: `bool`, name-value, default: `false`,
%       a flag to return responses from 1-10 instead of 1 or -1.
%       Scale used in Norena paper.
% 
%   - verbose: `bool`, name-value, default: `true`,
%       a flag to print information messages
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
        options.threshold (1,1) {mustBePositive} = 50
        options.method (1,:) char = 'percentile' 
        options.lambda (1,1) {mustBeGreaterThanOrEqual(options.lambda,0)} = 0;
        options.mean_zero (1,1) logical = false
        options.from_responses (1,1) logical = false
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

    % Make selection
    if strcmp(options.method,'ten_scale')
        N = 10;
        resp_vals = 0:N;
%         thresholds = [quantile(e,0:1/(N+1):1-(1/(N+1))), inf];
        thresholds = [quantile([min(e), max(e)],0:1/(N+1):1-(1/(N+1))), inf];
        y = zeros(length(e), 1);
        for i = 1:length(resp_vals)
            y(e >= thresholds(i) & e < thresholds(i + 1)) = resp_vals(i);
        end
    elseif strcmp(options.method,'percentile')
        % Set threshold
        if options.from_responses
            if options.verbose
                corelib.verb(options.verbose, 'INFO: subject_selection_process', 'setting threshold from responses')
            end
            thresh = 100 * sum(responses == -1)/length(responses);
        else
            thresh = options.threshold;
        end
        y = double(e >= prctile(e, thresh));
        y(y == 0) = -1;
    elseif strcmp(options.method,'sign')
        y = sign(e + options.lambda);
    else
        error('Unknown method to convert continuous estimation to responses')
    end
end
