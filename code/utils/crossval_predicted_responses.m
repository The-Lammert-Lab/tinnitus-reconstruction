function [given_resps, training_resps, on_test, on_train] = crossval_predicted_responses(config, folds, data_dir, options)

    arguments
        config struct
        folds (1,1) {mustBePositive, mustBeInteger}
        data_dir char
        options.knn logical = false
        options.mean_zero logical = false
        options.from_responses logical = false
        options.ridge_reg logical = false
        options.threshold_values (1,:) {mustBePositive} = linspace(10,90,200)
        options.k_vals (1,:) {mustBePositive, mustBeInteger} = 10:5:50
        options.verbose logical = true
    end

    [resps, stimuli_matrix] = collect_data('config', config, 'verbose', options.verbose, 'data_dir', data_dir);

    fold_frac = round(length(resps) / folds);

    % Initialize
    given_resps = zeros(length(resps), 1);
    on_test.cs = zeros(length(resps), 1);
    on_test.lr = zeros(length(resps), 1);

    training_resps = zeros(3*fold_frac*folds, 1);
    on_train.cs = zeros(3*fold_frac*folds, 1);
    on_train.lr = zeros(3*fold_frac*folds, 1);
    
    pred_bal_acc_dev_cs = zeros(size(options.threshold_values));
    pred_bal_acc_dev_lr = zeros(size(options.threshold_values));
    
    if options.knn
        on_test.knn = zeros(length(resps), 1);
        on_train.knn = zeros(3*fold_frac*folds, 1);
        pred_bal_acc_dev_knn = zeros(size(options.k_vals));
    end

    for ii = 1:folds
        % Shift data
        resps = circshift(resps, fold_frac);
        stimuli_matrix = circshift(stimuli_matrix, fold_frac, 2);
        
        % Split data
        resps_train = resps(1:size(resps,1)-(2*fold_frac));
        resps_dev = resps(size(resps,1)-(2*fold_frac)+1:end-fold_frac);
        resps_test = resps(size(resps,1)-fold_frac+1:end);
        
        stimuli_matrix_train = stimuli_matrix(:, 1:size(stimuli_matrix,2)-(2*fold_frac));
        stimuli_matrix_dev = stimuli_matrix(:, size(stimuli_matrix,2)-(2*fold_frac)+1:end-fold_frac);
        stimuli_matrix_test = stimuli_matrix(:, size(stimuli_matrix,2)-fold_frac+1:end);
        
        % Get reconstructions
        gamma = get_gamma_from_config(config, options.verbose);
        
        recon_cs = cs(resps_train, stimuli_matrix_train', gamma, ...
                        'mean_zero', options.mean_zero, 'verbose', options.verbose);
        recon_lr = gs(resps_train, stimuli_matrix_train', ...
                        'ridge', options.ridge_reg, 'mean_zero', options.mean_zero);
        
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
        
        % Make predictions on test data
        pred_cs = subject_selection_process(recon_cs, stimuli_matrix_test', [], [], ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_cs), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );
        pred_lr = subject_selection_process(recon_lr, stimuli_matrix_test', [], [], ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_lr), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );
        
        pred_on_train_cs = subject_selection_process(recon_cs, stimuli_matrix_train', [], [], ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_cs), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );
        pred_on_train_lr = subject_selection_process(recon_lr, stimuli_matrix_train', [], [], ...
                                            'mean_zero', options.mean_zero, ...
                                            'threshold', options.threshold_values(ind_lr), ...
                                            'from_responses', options.from_responses, ...
                                            'verbose', options.verbose ...
                                        );

        % Store predictions
        filled = nnz(on_test.cs);
        given_resps(filled+1:filled+length(resps_test)) = resps_test;
        on_test.cs(filled+1:filled+length(pred_cs)) = pred_cs;
        on_test.lr(filled+1:filled+length(pred_lr)) = pred_lr;
        
        % For error estimation
        filled_on_train = nnz(on_train.cs);
        training_resps(filled_on_train+1:filled_on_train+length(resps_train)) = resps_train;
        on_train.cs(filled_on_train+1:filled_on_train+length(pred_on_train_cs)) = pred_on_train_cs;
        on_train.lr(filled_on_train+1:filled_on_train+length(pred_on_train_lr)) = pred_on_train_lr;

        if options.knn
            for jj = 1:length(options.k_vals)
                pred_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_dev',options.k_vals(jj));
                [~, pred_bal_acc_dev_knn(jj), ~, ~] = get_accuracy_measures(resps_dev, pred_knn);
            end

            [~, ind_k] = max(pred_bal_acc_dev_knn);
            pred_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_test',options.k_vals(ind_k));
            pred_on_train_knn = knn_classify(resps_train,stimuli_matrix_train',stimuli_matrix_train',options.k_vals(ind_k));
            on_test.knn(filled+1:filled+length(pred_knn)) = pred_knn;
            on_train.knn(filled_on_train+1:filled_on_train+length(pred_on_train_knn)) = pred_on_train_knn;
        end

    end
end
