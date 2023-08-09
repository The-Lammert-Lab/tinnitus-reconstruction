function [pred_resps, true_resps] = crossval_rand(folds,thresh,options)
    arguments
        folds (1,1) {mustBeInteger, mustBePositive}
        thresh (1,:) {mustBePositive} = 50
        options.config struct = []
        options.data_dir char = ''
        options.responses (:,1) {mustBeReal, mustBeInteger} = []
        options.dist char = 'uniform'
        options.verbose logical = true
    end

    if isempty(options.responses)
        [resps, ~] = collect_data('config', options.config, 'verbose', options.verbose, 'data_dir', options.data_dir);
    else
        resps = options.responses;
    end

    switch options.dist
        case 'uniform'
            randfunc = @rand;
        case 'normal'
            randfunc = @randn;
    end

    % Useful
    n = length(resps);
    n_test = round(n / folds);
    test_inds = n-n_test+1:n;

    % Flag to optimize thresh values
    rundev = ~isscalar(thresh);

    if rundev
        dev_inds = n-(2*n_test)+1:n-n_test;
    end

    % Containers
    pred_resps = NaN(n,1);
    true_resps = NaN(n,1);
    bal_acc_dev = zeros(length(thresh),1);

    for ii = 1:folds
        % Rotate the data
        resps = circshift(resps, n_test);

        % Development section
        if rundev
            % Get estimations
            y_hat = randfunc(length(dev_inds),1);
            % Convert estimations to binary choices.
            preds = sign(y_hat + thresh);
            [~, bal_acc_dev, ~, ~] = get_accuracy_measures(resps(dev_inds),preds);
        end

        % Get row and column of max balanced accuracy index.
        [~, thresh_ind] = max(bal_acc_dev);

        y_hat = randfunc(length(test_inds),1);
        preds = sign(y_hat + thresh(thresh_ind));
        
        % Store
        filled = sum(~isnan(pred_resps));
        store_inds = filled+1:filled+n_test;
        pred_resps(store_inds) = preds;
        true_resps(store_inds) = resps(test_inds);
    end
end
