% ### crossval_lwlr
% 
% Generate the cross-validated response predictions for a given 
% config file or pair of stimuli and responses
% using locally weighted linear regression.
% 
% ```matlab
%   [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_lwlr(folds, h, thresh, 'config', config, 'data_dir', data_dir)
%   [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_lwlr(folds, h, thresh, 'responses', responses, 'stimuli', stimuli)
% ```
% 
% **ARGUMENTS:**
% 
%   - folds: `scalar` positive integer, must be greater than 3,
%       representing the number of cross validation folds to complete.
%       Data will be partitioned into `1/folds` for `test` and `dev` sets
%       and the remaining for the `train` set.
%   - h: `1 x p` numerical vector or `scalar`,
%       representing the width parameter(s) for the Gaussian kernel.
%       If there are multiple values, 
%       it will be optimized in the development section.
%   - thresh: `1 x q` numerical vector or `scalar`, 
%       representing the threshold value in the estimate to response
%       conversion: `sign(X*b + threshold)`.
%       If there are multiple values,
%       it will be optimized in the development section.
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
%   - norm_stim: `bool`, name-value, default: `false`,
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
%   - pred_resps_train: `folds*(n-round(n/folds)) x 1` vector,
%       OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
%       the predicted responses on the training data.
%   - true_resps_train: `folds*(n-round(n/folds)) x 1` vector,
%       OR `folds*(2*(n-round(n/folds))) x 1` vector if dev is run.
%       the predicted responses on the training data.
%       the original subject responses in the order corresponding 
%       to the predicted responses on the training data,

function [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_lwlr(folds, h, thresh, options)
    arguments
        folds (1,1) {mustBeInteger, mustBePositive}
        h (:,1) {mustBePositive}
        thresh (1,:) {mustBeReal}
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
%         stimuli_matrix = stimuli_matrix - mean(stimuli_matrix,1);
        stimuli_matrix = normalize(stimuli_matrix);
    end

    % Flag to optimize h and/or thresh values
    rundev = ~isscalar(h) || ~isscalar(thresh);

    % Useful
    n = length(resps);
    n_test = round(n / folds);
    test_inds = n-n_test+1:n;

    if rundev
        train_inds = 1:n-(2*n_test);
        dev_inds = n-(2*n_test)+1:n-n_test;
        bal_acc_dev = zeros(length(h),length(thresh));
    else
        train_inds = 1:n-n_test;
    end

    % Containers
    pred_resps = NaN(n,1);
    true_resps = NaN(n,1);
    pred_resps_train = NaN(length(train_inds)*folds,1);
    true_resps_train = NaN(length(train_inds)*folds,1);

    for ii = 1:folds
        % Rotate the data
        resps = circshift(resps, n_test);
        stimuli_matrix = circshift(stimuli_matrix, n_test, 2);

        % Development section
        if rundev
            for jj = 1:length(h)
                % Get estimations
                z_hat = lwlr(stimuli_matrix(:,train_inds)', resps(train_inds), ...
                            stimuli_matrix(:,dev_inds)', h(jj));

                % Convert estimations to binary choices.
                preds = sign(z_hat + thresh);
                
                % Get bal acc for each threshold value for this h 
                [~, bal_acc_dev(jj,:), ~, ~] = get_accuracy_measures(resps(dev_inds),preds);
            end
            % Get row and column of max balanced accuracy index.
            [~, lin_ind] = max(bal_acc_dev,[],'all');
            [h_ind, thresh_ind] = ind2sub(size(bal_acc_dev),lin_ind);
        else
            h_ind = 1;
            thresh_ind = 1;
        end

        fprintf(['h = ', num2str(h(h_ind)), '\n'])
        fprintf(['thresh = ', num2str(thresh(thresh_ind)), '\n'])

        % Do regression/evaluation with best h and threshold
        z_hat = lwlr(stimuli_matrix(:,train_inds)',resps(train_inds), ...
                    stimuli_matrix(:,test_inds)',h(h_ind));
        preds = sign(z_hat + thresh(thresh_ind));

        z_hat_train = lwlr(stimuli_matrix(:,train_inds)',resps(train_inds), ...
                            stimuli_matrix(:,train_inds)',h(h_ind));
        preds_train = sign(z_hat_train + thresh(thresh_ind));

        % Store
        filled_test = sum(~isnan(pred_resps));
        store_inds_test = filled_test+1:filled_test+n_test;

        filled_train = sum(~isnan(pred_resps_train));
        store_inds_train = filled_train+1:filled_train+length(preds_train);

        pred_resps(store_inds_test) = preds;
        true_resps(store_inds_test) = resps(test_inds);

        pred_resps_train(store_inds_train) = preds_train;
        true_resps_train(store_inds_train) = resps(train_inds);
    end
end % func

function w = gaussiankernel(x1, x2, h)
    % INPUTS
    %    x1: the first data vector
    %    x2: the second data vector
    %    h: kernel width parameter
    % OUTPUTS
    %    w: the kernel weight
    H = h.*eye(length(x1));
    w = exp(-0.5*(x1 - x2)'*H*(x1 - x2));
end

function b_hat = regress_fit_weighted(y,X,W)
    % Inputs:
    %    y - A n-by-1 vector of response variable values
    %    X - A n-by-p design matrix 
    %        (where n is number of data points; p is number of features)
    %    W - A n-by-n (diagonal) weighting matrix
    % Outputs:
    %    b_hat - a p-by-1 vector of regression coefficients
    %        (oriented such that rows of b_hat correspond to columns of X) 
%     b_hat = (X'*W*X)\(X'*W*y);
    b_hat = (X'*W*X + 0.01*eye(size(X,2)))\(X'*W*y);
end

function z_hat = lwlr(X,y,T,h)
    n_train = size(X,1);
    n_test = size(T,1);
    z_hat = zeros(n_test,1);
    % Iterate over every test point
    for itor = 1:n_test
        % Get similarity b/t test and train points
        W = zeros(n_train);
        for jtor = 1:n_train
            W(jtor,jtor) = gaussiankernel(X(jtor,:)',T(itor,:)',h);
        end
        % Get regression coefficients
        b = regress_fit_weighted(y,X,W);
        % Estimate val
        z_hat(itor) = T(itor,:)*b;
    end
end
