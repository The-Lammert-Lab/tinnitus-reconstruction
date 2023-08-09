% ### crossval_knn
% 
% Generate the cross-validated response predictions for a given 
% config file or pair of stimuli and responses
% using K-Nearest Neighbors.
% 
% ```matlab
%   [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_knn(folds, k, 'config', config, 'data_dir', data_dir)
%   [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_knn(folds, k, 'responses', responses, 'stimuli', stimuli)
% ```
% 
% **ARGUMENTS:**
% 
%   - folds: `scalar` positive integer, must be greater than 3,
%       representing the number of cross validation folds to complete.
%       Data will be partitioned into `1/folds` for `test` and `dev` sets
%       and the remaining for the `train` set.
%   - k: `1 x p` numerical vector or `scalar`,
%       number of nearest neighbors to consider.
%       If there are multiple values, 
%       it will be optimized in the development section.
%   - method: `char`, name-value, default: 'mode',
%       class determination style to be passed to knn function.
%   - percent: `scalar`, name-value, default: 75,
%       Target percent passed to knn function if `knn_method` is 'percent'.
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

function [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_knn(folds, k, options)
    arguments
        folds (1,1) {mustBeInteger, mustBePositive}
        k (:,1) {mustBePositive}
        options.method char = 'mode'
        options.percent (:,1) {mustBePositive, mustBeLessThanOrEqual(options.percent,100)} = 75
        options.config struct = []
        options.data_dir char = ''
        options.responses (:,1) {mustBeReal, mustBeInteger} = []
        options.stimuli (:,:) {mustBeReal} = []
        options.norm_stim logical = false
        options.verbose logical = true
    end

    % Load data
    if isempty(options.responses) && isempty(options.stimuli)
        [resps, stimuli_matrix] = collect_data('config', options.config, 'verbose', options.verbose, 'data_dir', options.data_dir);
    else
        resps = options.responses;
        stimuli_matrix = options.stimuli;
    end
    
    if options.norm_stim
        stimuli_matrix = normalize(stimuli_matrix);
    end

    % Flag to run development to optimize k and/or percent
    rundev = ~isscalar(k) || (strcmp(options.method, 'percent') && ~isscalar(options.percent));

    % Setup
    n = length(resps);
    n_test = round(n / folds);
    test_inds = n-n_test+1:n;


    if ~strcmp(options.method, 'percent')
        hparams = k;
    else
        hparams = allcomb(k, options.percent);
    end

    if rundev
        train_inds = 1:n-(2*n_test);
        dev_inds = n-(2*n_test)+1:n-n_test;
        bal_acc_dev = zeros(length(hparams),1);
    else
        train_inds = 1:n-n_test;
    end

    % Containers
    pred_resps = zeros(n,1);
    true_resps = zeros(n,1);
    pred_resps_train = zeros(length(train_inds)*folds,1);
    true_resps_train = zeros(length(train_inds)*folds,1);

    for ii = 1:folds
        resps = circshift(resps, n_test);
        stimuli_matrix = circshift(stimuli_matrix, n_test, 2);

        % Development
        if rundev
            for jj = 1:size(hparams,1)
                if ~strcmp(options.method, 'percent')
                    preds = knn_classify(resps(train_inds),stimuli_matrix(:,train_inds)', ...
                                        stimuli_matrix(:,dev_inds)',hparams(jj,1), ...
                                        'method',options.method);
                else
                    preds = knn_classify(resps(train_inds),stimuli_matrix(:,train_inds)', ...
                                        stimuli_matrix(:,dev_inds)',hparams(jj,1), ...
                                        'method',options.method,'percent',hparams(jj,2));
                end
                [~, bal_acc_dev(jj), ~, ~] = get_accuracy_measures(resps(dev_inds), preds);
            end
            % Make predictions on test and train using best k value
            [~, ind_hparam] = max(bal_acc_dev);
        else
            ind_hparam = 1;
        end

        if ~strcmp(options.method, 'percent')
            preds = knn_classify(resps(train_inds),stimuli_matrix(:,train_inds)', ...
                                stimuli_matrix(:,test_inds)', hparams(ind_hparam,1), ...
                                'method', options.method);
            preds_ontrain = knn_classify(resps(train_inds),stimuli_matrix(:,train_inds)', ...
                                        stimuli_matrix(:,train_inds)',hparams(ind_hparam,1), ...
                                        'method', options.method);
        else
            preds = knn_classify(resps(train_inds),stimuli_matrix(:,train_inds)', ...
                                stimuli_matrix(:,test_inds)',hparams(ind_hparam,1), ...
                                'method',options.method,'percent',hparams(ind_hparam,2));
            preds_ontrain = knn_classify(resps(train_inds),stimuli_matrix(:,train_inds)', ...
                                        stimuli_matrix(:,train_inds)',hparams(ind_hparam,1), ...
                                        'method',options.method,'percent',hparams(ind_hparam,2));
        end
        
        % Store
        filled_test = nnz(pred_resps);
        filled_train = nnz(pred_resps_train);

        pred_resps(filled_test+1:filled_test+n_test) = preds;
        true_resps(filled_test+1:filled_test+n_test) = resps(test_inds);

        pred_resps_train(filled_train+1:filled_train+length(train_inds)) = preds_ontrain;
        true_resps_train(filled_train+1:filled_train+length(train_inds)) = resps(train_inds);
    end
end
