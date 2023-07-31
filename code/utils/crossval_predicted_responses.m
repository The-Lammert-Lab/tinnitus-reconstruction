% ### crossval_predicted_responses
% 
% Generate response predictions for a given 
% config file or pair of stimuli and responses
% using stratified cross validation and either
% the subject response model or KNN.
% 
% ```matlab
%   [given_resps, training_resps, on_test, on_train] = crossval_predicted_responses(folds, 'config', config, 'data_dir', data_dir)
%   [given_resps, training_resps, on_test, on_train] = crossval_predicted_responses(folds, 'responses', responses, 'stimuli', stimuli)
% ```
% 
% **ARGUMENTS:**
% 
%   - folds: `scalar` positive integer, must be greater than 3,
%       representing the number of cross validation folds to complete.
%       Data will be partitioned into `1/folds` for `test` and `dev` sets
%       and the remaining for the `train` set.
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
%   - normalize: `bool`, name-value, default: `false`,
%       flag to normalize the stimuli after loading.
%   - knn: `bool`, name-value, default: `false`,
%       flag to run additional K-Nearest-Neighbor analysis
%   - knn_method: `char`, name-value, default: 'mode',
%       class determination flag to be passed to knn function.
%   - knn_percent: `scalar`, name-value, default: 75,
%       Target percent passed to knn function if `knn_method` is 'percent'.
%   - k_vals: `1 x n` numerical vector, name-value, default: `10:5:50`,
%       representing the K values on which to perform development to
%       identify optimum for KNN analysis. Values must be positive integers.
%   - gamma: `1 x 1` scalar, name-value, default: `8`,
%   - mean_zero: `bool`, name-value, default: `false`,
%       flag to set the mean of the stimuli to zero when computing the
%       reconstruction and both the mean of the stimuli and the
%       reconstruction to zero when generating the predictions.
%   - from_responses: `bool`, name-value, default: `false`,
%       flag to determine the threshold from the given responses. 
%       Overwrites `threshold_values` and does not run threshold
%       development cycle.
%   - ridge_reg: `bool`, name-value, default: `false`,
%       flag to use ridge regression instead of standard linear regression
%       for reconstruction.
%   - threshold_values: `1 x m` numerical vector, name-value, default:
%       `linspace(10,90,200)`, representing the percentile threshold values
%       on which to perform development to identify optimum. 
%       Values must be on (0,100].
%       representing the gamma value to use in 
%       compressed sensing reconstructions if `config` is empty.
%   - verbose: `bool`, name-value, default: `true`,
%       flag to print information messages.       
% 
% **OUTPUTS:**
% 
%   - given_resps: `p x 1` vector,
%       the original subject responses in the order corresponding 
%       to the predicted responses, i.e., a shifted version of the 
%       original response vector. `p` is the number of original responses.
%   - training_resps: `(folds-2)*p x 1` vector,
%       the original subject responses used in the training phase.
%       The training data is partially repeated between folds.
%   - on_test: `struct` with `p x 1` vectors in fields
%       `cs`, `lr`, and if `knn = true`, `knn`.
%       Predicted responses on testing data.
%   - on_train: `struct` with `(folds-2)*p x 1` vectors in fields
%       `cs`, `lr`, and if `knn = true`, `knn`.
%       Predicted responses on training data.
% 
% See also:
% subject_selection_process
% knn_classify

function [given_resps, training_resps, on_test, on_train] = crossval_predicted_responses(folds, options)

    arguments
        folds (1,1) {mustBePositive, mustBeInteger, mustBeGreaterThan(folds,3)}
        options.config struct = []
        options.data_dir char = ''
        options.responses (:,1) {mustBeReal, mustBeInteger} = []
        options.stimuli (:,:) {mustBeReal} = []
        options.knn logical = false
        options.knn_method char = 'mode'
        options.knn_percent (:,1) {mustBePositive, mustBeLessThanOrEqual(options.knn_percent,100)} = 75
        options.mean_zero logical = false
        options.from_responses logical = false
        options.ridge_reg logical = false
        options.threshold_values (1,:) {mustBePositive, mustBeLessThanOrEqual(options.threshold_values,100)} = linspace(10,90,200)
        options.k_vals (1,:) {mustBePositive, mustBeInteger} = 10:5:50
        options.gamma (1,1) {mustBePositive, mustBeInteger} = 8
        options.normalize logical = false
        options.verbose logical = true
    end

    if isempty(options.responses) && isempty(options.stimuli)
        [resps, stimuli_matrix] = collect_data('config', options.config, 'verbose', options.verbose, 'data_dir', options.data_dir);
    else
        resps = options.responses;
        stimuli_matrix = options.stimuli;
    end
    
    if options.normalize
        stimuli_matrix = normalize(stimuli_matrix);
    end

    n = length(resps);
    fold_frac = round(length(resps) / folds);

    train_inds = 1:n-(2*fold_frac);
    dev_inds = n-(2*fold_frac)+1:n-fold_frac;
    test_inds = n-fold_frac+1:n;

    train_len = (folds-2)*n;

    % Initialize
    given_resps = zeros(n, 1);
    on_test.cs = zeros(n, 1);
    on_test.lr = zeros(n, 1);

    training_resps = zeros(train_len, 1);
    on_train.cs = zeros(train_len, 1);
    on_train.lr = zeros(train_len, 1);
    
    pred_bal_acc_dev_cs = zeros(size(options.threshold_values));
    pred_bal_acc_dev_lr = zeros(size(options.threshold_values));
    
    if options.knn
        on_test.knn = zeros(n, 1);
        on_train.knn = zeros(train_len, 1);
        if isempty(options.knn_percent)
            knn_hparams = options.k_vals';
        else
            knn_hparams = allcomb(options.k_vals, options.knn_percent);
        end
        pred_bal_acc_dev_knn = zeros(length(knn_hparams),1);
    end

    for ii = 1:folds
        % Shift data
        resps = circshift(resps, fold_frac);
        stimuli_matrix = circshift(stimuli_matrix, fold_frac, 2);
        
        % Split data
        resps_train = resps(train_inds);
        resps_dev = resps(dev_inds);
        resps_test = resps(test_inds);
        
        stimuli_matrix_train = stimuli_matrix(:, train_inds);
        stimuli_matrix_dev = stimuli_matrix(:, dev_inds);
        stimuli_matrix_test = stimuli_matrix(:, test_inds);
        
        % Get reconstructions
        if ~isempty(options.config)
            gamma = get_gamma_from_config(options.config, options.verbose);
        else
            gamma = options.gamma;
        end
        
        recon_cs = cs(resps_train, stimuli_matrix_train', gamma, ...
                        'mean_zero', options.mean_zero, 'verbose', options.verbose);
        recon_lr = gs(resps_train, stimuli_matrix_train', ...
                        'ridge', options.ridge_reg, 'mean_zero', options.mean_zero);


        if ~options.from_responses
            % Collect balanced accuracies for each threshold value using dev set
            for jj = 1:length(options.threshold_values)
                pred_cs = subject_selection_process(recon_cs, stimuli_matrix_dev', [], [], ...
                                                        'mean_zero', options.mean_zero, ...
                                                        'threshold', options.threshold_values(jj), ...
                                                        'from_responses', options.from_responses, ...
                                                        'verbose', options.verbose ...
                                                    );
                pred_lr = subject_selection_process(recon_lr, stimuli_matrix_dev', [], [], ...
                                                        'mean_zero', options.mean_zero, ...
                                                        'threshold', options.threshold_values(jj), ...
                                                        'from_responses', options.from_responses, ...
                                                        'verbose', options.verbose ...
                                                    );
            
    
                [~, pred_bal_acc_dev_cs(jj), ~, ~] = get_accuracy_measures(resps_dev, pred_cs);
                [~, pred_bal_acc_dev_lr(jj), ~, ~] = get_accuracy_measures(resps_dev, pred_lr);
            end
            
            % Identify best threshold values
            [~, ind_cs] = max(pred_bal_acc_dev_cs);
            [~, ind_lr] = max(pred_bal_acc_dev_lr);
        end
        
        % Make predictions on test data
        pred_cs = subject_selection_process(recon_cs, stimuli_matrix_test', [], resps_test, ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_cs), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );
        pred_lr = subject_selection_process(recon_lr, stimuli_matrix_test', [], resps_test, ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_lr), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );
        % Predict on training data
        pred_on_train_cs = subject_selection_process(recon_cs, stimuli_matrix_train', [], resps_test, ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_cs), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );
        pred_on_train_lr = subject_selection_process(recon_lr, stimuli_matrix_train', [], resps_test, ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_lr), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );

        % Store predictions
        filled_test = nnz(on_test.cs);
        unfilled_inds_test = filled_test+1:filled_test+length(resps_test);
        given_resps(unfilled_inds_test) = resps_test;
        on_test.cs(unfilled_inds_test) = pred_cs;
        on_test.lr(unfilled_inds_test) = pred_lr;
        
        % For error estimation
        filled_train = nnz(on_train.cs);
        unfilled_inds_train = filled_train+1:filled_train+length(resps_train);
        training_resps(unfilled_inds_train) = resps_train;
        on_train.cs(unfilled_inds_train) = pred_on_train_cs;
        on_train.lr(unfilled_inds_train) = pred_on_train_lr;

        if options.knn
            % Collect balanced accuracies for each K value using dev set 
            for jj = 1:size(knn_hparams,1)
                if ~strcmp(options.knn_method, 'percent')
                    pred_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_dev',knn_hparams(jj,1),'method',options.knn_method);
                else
                    pred_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_dev',knn_hparams(jj,1),'method',options.knn_method,'percent',knn_hparams(jj,2));
                end
                [~, pred_bal_acc_dev_knn(jj), ~, ~] = get_accuracy_measures(resps_dev, pred_knn);
            end

            % Make predictions on test and train using best k value
            [~, ind_knn] = max(pred_bal_acc_dev_knn);
            if ~strcmp(options.knn_method, 'percent')
                pred_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_test', knn_hparams(ind_knn,1), 'method', options.knn_method);
                pred_on_train_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_train',knn_hparams(ind_knn,1), 'method', options.knn_method);
            else
                pred_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_test',knn_hparams(ind_knn,1),'method',options.knn_method,'percent',knn_hparams(ind_knn,2));
                pred_on_train_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_train',knn_hparams(ind_knn,1),'method',options.knn_method,'percent',knn_hparams(ind_knn,2));
            end

            % Store
            on_test.knn(unfilled_inds_test) = pred_knn;
            on_train.knn(unfilled_inds_train) = pred_on_train_knn;
        end

    end
end
