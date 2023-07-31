% ### crossval_lda
% 
% Generate the cross-validated response predictions for a given 
% config file or pair of stimuli and responses
% using linear discriminant analysis.
% 
% 
% ```matlab
%   [pred_resps, true_resps] = crossval_lda(folds, 'config', config, 'data_dir', data_dir)
%   [pred_resps, true_resps] = crossval_lda(folds, 'responses', responses, 'stimuli', stimuli)
% ```
% 
% **ARGUMENTS:**
% 
%   - folds: `scalar` positive integer, must be greater than 3,
%       representing the number of cross validation folds to complete.
%   - config: `struct`, name-value, deafult: `[]`
%       config struct from which to find responses and stimuli
%   - data_dir: `char`, name-value, deafult: `''`
%       the path to directory in which the data corresponding to the 
%       config structis stored.
%   - responses: `n x 1` array, name-value, default: `[]`
%       responses to use in reconstruction, 
%       where `n` is the number of responses.
%       Only used if passed with `stimuli`.
%   - stimuli: `m x n` array, name-value, default: `[]`
%       stimuli to use in reconstruction,
%       where `m` is the number of bins.
%       Only used if passed with `responses`.
%   - verbose: `bool`, name-value, default: `true`,
%       flag to print information messages.    
% 
% **OUTPUTS:**
% 
%   - pred_resps: `n x 1` vector,
%       the predicted responses.
%   - true_resps: `n x 1` vector,
%       the original subject responses in the order corresponding 
%       to the predicted responses, i.e., a shifted version of the 
%       original response vector.
% 
% See Also:
% * [fitcdiscr](https://mathworks.com/help/stats/fitcdiscr.html)

function [pred_resps, true_resps] = crossval_lda(folds, options)
    arguments
        folds (1,1) {mustBeInteger, mustBePositive}
        options.config struct = []
        options.data_dir char = ''
        options.responses (:,1) {mustBeReal, mustBeInteger} = []
        options.stimuli (:,:) {mustBeReal} = []
        options.verbose logical = true
    end

    if isempty(options.responses) && isempty(options.stimuli)
        [resps, stimuli_matrix] = collect_data('config', options.config, 'verbose', options.verbose, 'data_dir', options.data_dir);
    else
        resps = options.responses;
        stimuli_matrix = options.stimuli;
    end

    % Inds
    n = length(resps);
    fold_frac = round(n / folds);
    train_inds = 1:n-fold_frac;
    test_inds = n-fold_frac+1:n;

    % Containers
    pred_resps = zeros(n,1);
    true_resps = zeros(n,1);

    for ii = 1:folds
        resps = circshift(resps, fold_frac);
        stimuli_matrix = circshift(stimuli_matrix, fold_frac, 2);

        % Create and optimize model
        model = fitcdiscr(stimuli_matrix(:,train_inds)', resps(train_inds), ...
            'OptimizeHyperparameters', 'auto', 'DiscrimType', 'linear', ...
            'HyperparameterOptimizationOptions', ...
            struct('Verbose',0,'ShowPlots',false));
    
        % Make predictions
        [p, ~] = predict(model, stimuli_matrix(:,test_inds)');

        % Store
        filled = nnz(pred_resps);
        pred_resps(filled+1:filled+length(p)) = p;
        true_resps(filled+1:filled+length(p)) = resps(test_inds);
    end
end
