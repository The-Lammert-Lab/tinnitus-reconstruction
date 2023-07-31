% ### crossval_pnr
% 
% Generate the cross-validated response predictions for a given 
% config file or pair of stimuli and responses
% using polynomial regression.
% 
% ```matlab
%   [pred_resps, true_resps] = crossval_pnr(folds, ords, thresh, 'config', config, 'data_dir', data_dir)
%   [pred_resps, true_resps] = crossval_pnr(folds, ords, thresh, 'responses', responses, 'stimuli', stimuli)
% ```
% 
% **ARGUMENTS:**
% 
%   - folds: `scalar` positive integer, must be greater than 3,
%       representing the number of cross validation folds to complete.
%       Data will be partitioned into `1/folds` for `test` and `dev` sets
%       and the remaining for the `train` set.
%   - h: `1 x p` numerical vector or `scalar`,
%       representing the polynomial order(s) on which to perform regression.
%       If there are multiple values, 
%       it will be optimized in the development section.
%   - thresh: `1 x q` numerical vector or `scalar`,
%       representing the percentile threshold value(s).
%       If there are multiple values, 
%       it will be optimized in the development section.
%       Values must be on (0,100].
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
%   - norm_stimuli: `bool`, name-value, default: `false`,
%       flag to normalize the stimuli after loading.
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
% * [polyfitn](https://mathworks.com/matlabcentral/fileexchange/34765-polyfitn)

function [pred_resps, true_resps] = crossval_pnr(folds,ords,thresh,options)
    arguments
        folds (1,1) {mustBeInteger, mustBePositive}
        ords (1,:) {mustBePositive}
        thresh (1,:) {mustBePositive} = 50
        options.config struct = []
        options.data_dir char = ''
        options.responses (:,1) {mustBeReal, mustBeInteger} = []
        options.stimuli (:,:) {mustBeReal} = []
        options.norm_stim logical = false
        options.verbose logical = true
    end

    if isempty(options.responses) && isempty(options.stimuli)
        [resps, stimuli_matrix] = collect_data('config', options.config, 'verbose', options.verbose, 'data_dir', options.data_dir);
    else
        resps = options.responses;
        stimuli_matrix = options.stimuli;
    end

    if options.norm_stim
        stimuli_matrix = normalize(stimuli_matrix);
    end

    % Useful
    n = length(resps);
    n_test = round(n / folds);
    train_inds = 1:n-(2*n_test);
    dev_inds = n-(2*n_test)+1:n-n_test;
    test_inds = n-n_test+1:n;

    % Containers
    pred_resps = NaN(n,1);
    true_resps = NaN(n,1);
    bal_acc_dev = zeros(length(ords),length(thresh));

    for ii = 1:folds
        % Rotate the data 
        resps = circshift(resps, n_test);
        stimuli_matrix = circshift(stimuli_matrix, n_test, 2);

        % Development section
        for jj = 1:length(ords)
            % Create polynomial
            p = polyfitn(stimuli_matrix(:,train_inds)',resps(train_inds),ords(jj));
            % Evaluate
            est_dev = polyvaln(p,stimuli_matrix(:,dev_inds)');
            % Convert estimate to -1 or 1.
            preds_dev = double(est_dev >= prctile(est_dev, thresh));
            preds_dev(preds_dev == 0) = -1;

            % Get bal acc for each threshold value for this order 
            for kk = 1:length(thresh)
                [~, bal_acc_dev(jj,kk), ~, ~] = get_accuracy_measures(resps(dev_inds),preds_dev(:,kk));
            end
        end

        % Get row and column of max balanced accuracy index.
        [~, lin_ind] = max(bal_acc_dev,[],'all');
        [ord_ind, thresh_ind] = ind2sub(size(bal_acc_dev),lin_ind);

        % Create and evaluate polynomial with best order
        p = polyfitn(stimuli_matrix(:,train_inds)',resps(train_inds),ords(ord_ind));
        est = polyvaln(p,stimuli_matrix(:,test_inds)');

        % Convert to -1 and 1.
        preds = double(est >= prctile(est, thresh(thresh_ind)));
        preds(preds == 0) = -1;

        % Store
        filled = sum(~isnan(pred_resps));
        unfilled_inds = filled+1:filled+n_test;
        pred_resps(unfilled_inds) = preds;
        true_resps(unfilled_inds) = resps(test_inds);
    end
end
