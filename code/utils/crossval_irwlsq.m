function [pred_resps, true_resps, pred_resps_train, true_resps_train] = crossval_irwlsq(folds,thresh,options)

    arguments
        folds (1,1) {mustBeInteger, mustBePositive}
        thresh (1,:) {mustBeReal}
        options.config struct = []
        options.data_dir char = ''
        options.responses (:,1) {mustBeReal, mustBeInteger} = []
        options.stimuli (:,:) {mustBeReal} = []
        options.weight_func char = 'bisquare'
        options.mean_zero logical = false
        options.verbose logical = true
    end

    if isempty(options.responses) && isempty(options.stimuli)
        [resps, stimuli_matrix] = collect_data('config', options.config, 'verbose', options.verbose, 'data_dir', options.data_dir);
    else
        resps = options.responses;
        stimuli_matrix = options.stimuli;
    end

    % Useful
    n = length(resps);
    n_test = round(n / folds);
    test_inds = n-n_test+1:n;

    % Flag to optimize thresh values
    rundev = ~isscalar(thresh);

    if rundev
        train_inds = 1:n-(2*n_test);
        dev_inds = n-(2*n_test)+1:n-n_test;
    else
        train_inds = 1:n-n_test;
    end

    % Containers
    pred_resps = NaN(n,1);
    true_resps = NaN(n,1);
    pred_resps_train = NaN(length(train_inds)*folds,1);
    true_resps_train = NaN(length(train_inds)*folds,1);

    if options.mean_zero
        mdlr = fitlm((stimuli_matrix-mean(stimuli_matrix,2))',resps,'RobustOpts',options.weight_func);
    else
        mdlr = fitlm(stimuli_matrix',resps,'RobustOpts',options.weight_func);
    end

    W = mdlr.Robust.Weights;

    for ii = 1:folds
        resps = circshift(resps, n_test);
        stimuli_matrix = circshift(stimuli_matrix, n_test, 2);

        % Create reconstructions
        recon = make_recon(stimuli_matrix(:,train_inds)',diag(W(train_inds)),resps(train_inds),'mean_zero',options.mean_zero);

        if rundev
            preds_dev = rc(stimuli_matrix(:,dev_inds)', recon, thresh, options.mean_zero);
            [~, bal_acc_dev, ~, ~] = get_accuracy_measures(resps(dev_inds), preds_dev);
            [~, thresh_ind] = max(bal_acc_dev);
        else
            thresh_ind = 1;
        end

        preds_test = rc(stimuli_matrix(:,test_inds)', recon, thresh(thresh_ind), options.mean_zero);
        preds_train = rc(stimuli_matrix(:,train_inds)', recon, thresh(thresh_ind), options.mean_zero);

        % Store
        filled = sum(~isnan(pred_resps));
        filled_train = sum(~isnan(pred_resps_train));

        pred_resps(filled+1:filled+length(preds_test)) = preds_test;
        true_resps(filled+1:filled+length(preds_test)) = resps(test_inds);
        pred_resps_train(filled_train+1:filled_train+length(preds_train)) = preds_train;
        true_resps_train(filled_train+1:filled_train+length(preds_train)) = resps(train_inds);
    end
end

function p = rc(stimuli, representation, thresh, mean_zero)
    arguments
        stimuli
        representation
        thresh (1,:)
        mean_zero logical = false
    end

    % Projection
    if mean_zero
        e = (stimuli - mean(stimuli,2)) * (representation(:) - mean(representation(:)));
    else
        e = stimuli * representation(:);
    end

    % Convert to response
    p = sign(e + thresh);
end

function recon = make_recon(X,W,y,options)
    arguments
        X (:,:)
        W (:,:)
        y (:,1)
        options.mean_zero = false
    end
    if options.mean_zero
        X = X - mean(X,1);
    end
    recon = (X'*W*X)\(X'*W*y);
end
