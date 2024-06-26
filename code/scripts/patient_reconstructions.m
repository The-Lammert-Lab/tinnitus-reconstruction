% ### patient_reconstructions
% Generate reconstructions and visualizatinos for non-target sound data
% Includes lots of flags for response prediction analysis
% NOTE: should also work with make_figures_paper2 (not recently tested though)
% End of documentation

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/ATA-Data/raw/';
% data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data/';

% Script parameters
CS = true; % Run compressed sensing
showfigs = true; % Plots all figures.
n_best_plot = 4; % How many axes to plot linear recon and dBs for
verbose = false;
num_from_config = false; % Some config setups have subject numbers in them. This takes that number.

% Analysis flags for response prediction
rc = true; 
rc_adjusted = false;
knn = false;
lda = false;
lwlr = false;
pnr = false;
randguess = false;
svm = false;
itr_lsq = true;
thresh_loud = true;
sim_prob = true; n_hists = 20;

follow_up_ttest = true;

% Subject IDs to skip (ID must be exact match to config.subject_ID)
% skip_subjects = {'KB_1', 'CH_2', 'JG_3', 'KE_6'};
skip_subjects = {'AM'};

%% Pre-processing: Remove skipped subjects
config_files = dir(pathlib.join(data_dir, '*.yaml'));

skip = false(length(config_files),1);
for ii = 1:length(config_files)
    config = parse_config(fullfile(config_files(ii).folder, config_files(ii).name));
    skip(ii) = ismember(config.subject_ID, skip_subjects);
end

config_files(skip,:) = [];
n = length(config_files);

%% Plot setup
if showfigs
    rows = ceil(n/2);
    
    if CS && n > 1
        cols = 4;
    else
        cols = 2;
    end
    
    label_y = 1:cols:rows*cols;
    
    linewidth = 1.5;
    linecolor = 'b';
    
    my_normalize = @(x) normalize(x, 'zscore', 'std');
    
    % Figs
    f_binned = figure;
    t_binned = tiledlayout(f_binned, rows, cols);
    
    f_unbinned = figure;
    t_unbinned = tiledlayout(f_unbinned, rows, cols);

    f_adjusted = figure;
    t_adjusted = tiledlayout(f_adjusted, 'flow');
    
    %% Loop and plot
    for i = 1:n
        %%%%% Get data %%%%%
        config = parse_config(fullfile(config_files(i).folder, config_files(i).name));
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
        
        % Skip deliberate config files or ones with target signals (healthy controls)
        if isfield(config, 'target_signal') && ~isempty(config.target_signal)
            continue
        end
    
        % Get subject ID number
        if num_from_config
            ID_num = extractAfter(config.subject_ID, '_');
            if isempty(ID_num)
                ID_num = '???';
            end
        else
            ID_num = num2str(i);
        end
    
        % Get reconstructions
        [reconstruction_binned_lr, ~, responses, stimuli_matrix] = get_reconstruction('config', config, ...
                                                                                        'method', 'linear', ...
                                                                                        'verbose', verbose, ...
                                                                                        'data_dir', data_dir ...
                                                                                    );

        if CS
            reconstruction_binned_cs = get_reconstruction('config', config, 'method', 'cs', ...
                                                            'verbose', verbose, 'data_dir', data_dir ...
                                                        );
        end

        T_follow_up = collect_data_follow_up('config',config,'data_dir',data_dir,'verbose',verbose);
        if all(ismember({'mult','binrange'}, T_follow_up.Properties.VariableNames))
            [~, reconstruction_adjusted] = stimgen.binnedrepr2wav(reconstruction_binned_lr, T_follow_up.mult(1), T_follow_up.binrange(1));
        end

        %%%%% Binned %%%%%
    
        % Linear
        if i == n && n > 2 && mod(n,2) % Last row, more than 2, odd num
            tile = nexttile(t_binned, [1,2]);
        else
            tile = nexttile(t_binned);
        end
    
        plot(my_normalize(reconstruction_binned_lr), linecolor, ...
            'LineWidth', linewidth);
    
        xlim([1, config.n_bins]);
    
        % Label only last row
        if tilenum(tile) >= rows-1
            xlabel('Bin #', 'FontSize', 16)
        end
    
        % Label start of each row
        if ismember(tilenum(tile), label_y)
            ylabel('Power (dB)', 'FontSize', 16);
        end
    
        title(['Subject #', ID_num, ' - Linear'], 'FontSize', 18);
        set(gca, 'FontWeight', 'bold')

        % CS
        if CS
            if i == n && n > 2 && mod(n,2) % Last row, more than 2, odd num
                tile = nexttile(t_binned, [1,2]);
            else
                tile = nexttile(t_binned);
            end
        
            plot(my_normalize(reconstruction_binned_cs), linecolor, ...
                'LineWidth', linewidth);
        
            xlim([1, config.n_bins]);
        
            % Label only last row
            if tilenum(tile) >= rows-1
                xlabel('Bin #', 'FontSize', 16)
            end
        
            title(['Subject #', ID_num, ' - CS'], 'FontSize', 18);
            set(gca, 'FontWeight', 'bold')
        end
    
        %%%%% Unbinned %%%%%
    
        % Linear
        if i == n && n > 2 && mod(n,2) % Last row, more than 2, odd num
            tile = nexttile(t_unbinned, [1,2]);
        else
            tile = nexttile(t_unbinned);
        end
    
        % Unbin
        [unbinned_lr, indices_to_plot, freqs] = unbin(reconstruction_binned_lr, stimgen, config.max_freq, config.min_freq);
    
        % Plot
        plot(freqs(indices_to_plot, 1), my_normalize(unbinned_lr(indices_to_plot)), ...
            linecolor, 'LineWidth', linewidth);
    
        xlim([0, config.max_freq]);
    
        % Label only last row
        if tilenum(tile) >= rows-1
            xlabel('Frequency (Hz)', 'FontSize', 16)
        end
    
        % Label start of each row
        if ismember(tilenum(tile), label_y)
            ylabel('Power (dB)', 'FontSize', 16);
        end
    
        title(['Subject #', ID_num, ' - Linear'], 'FontSize', 18);
        set(gca, 'FontWeight', 'bold')

        % CS
        if CS
            if i == n && n > 2 && mod(n,2) % Last row, more than 2, odd num
                tile = nexttile(t_unbinned, [1,2]);
            else
                tile = nexttile(t_unbinned);
            end
        
            % Unbin
            [unbinned_cs, indices_to_plot, freqs] = unbin(reconstruction_binned_cs, stimgen, config.max_freq, config.min_freq);
        
            % Plot
            plot(freqs(indices_to_plot, 1), my_normalize(unbinned_cs(indices_to_plot)), ...
                linecolor, 'LineWidth', linewidth);
        
            xlim([0, config.max_freq]);
        
            % Label only last row
            if tilenum(tile) >= rows-1
                xlabel('Frequency (Hz)', 'FontSize', 16)
            end
        
            title(['Subject #', ID_num, ' - CS'], 'FontSize', 18);
            set(gca, 'FontWeight', 'bold')
        end

        %%%%% Adjusted %%%%%
        tile = nexttile(t_adjusted);
        
        plot(freqs(indices_to_plot, 1), reconstruction_adjusted(indices_to_plot), ...
            linecolor, 'LineWidth', linewidth);
        xlim([0, config.max_freq]);

        title(['Subject #', ID_num, ' - Adjusted'], 'FontSize', 18);
        set(gca, 'FontWeight', 'bold')

    end
end

%% Predict responses with cross validation
row_names = cellstr(strcat('Subject', {' '}, string((1:n))));

% Pre-allocate  
yesses = zeros(n, 1);
IDs = strings(n, 1);

dB_thresh_corrs_lr = NaN(n, 1);
dB_thresh_corrs_cs = NaN(n, 1);
dB_thresh_pvals_lr = NaN(n, 1);
dB_thresh_pvals_cs = NaN(n, 1);

dB_loud_corrs_lr = NaN(n, 1);
dB_loud_corrs_cs = NaN(n, 1);
dB_loud_pvals_lr = NaN(n, 1);
dB_loud_pvals_cs = NaN(n, 1);

% Global settings
folds = 5;

% RC
mean_zero = true;
gs_ridge = false;
thresh_vals_rc = 0;

% KNN
knn_method = 'mode';
knn_percent = 1:5:90;
k_vals = 1:2:50;

% LWLR
gauss_h = 10.^(-12:1);
norm_stim_lwlr = false;
thresh_vals_lwlr = linspace(-5,5,100000);

% PNR
pnr_ords = 2:4;
norm_stim_pnr = false;

% randguess
randtype = 'normal';

% Thresh or Loud
mean_zero_tl = true;
thresh_vals_tl = linspace(-5000,1,1000);

% Iter lsq
mean_zero_irwlsq = true;
weight_func = 'logistic'; % See 'RobustOpts' argument of 'fitlm' for options

% Containers
pred_acc_cs = zeros(n,1);
pred_acc_lr = zeros(n,1); 

pred_bal_acc_cs = zeros(n,1);
pred_bal_acc_lr = zeros(n,1);

pred_acc_on_train_cs = zeros(n,1);
pred_acc_on_train_lr = zeros(n,1); 

pred_bal_acc_on_train_cs = zeros(n,1);
pred_bal_acc_on_train_lr = zeros(n,1);

if rc
    pred_acc_rc = zeros(n,1);
    pred_bal_acc_rc = zeros(n,1);
    pred_acc_rc_train = zeros(n,1);
    pred_bal_acc_rc_train = zeros(n,1);
%     continuous_preds = cell(n,1);
end

if rc_adjusted
    pred_acc_rc_adj = zeros(n,1);
    pred_bal_acc_rc_adj = zeros(n,1);
    pred_acc_rc_adj_train = zeros(n,1);
    pred_bal_acc_rc_adj_train = zeros(n,1);
end

if knn
    pred_acc_knn = zeros(n,1);
    pred_bal_acc_knn = zeros(n,1);
    pred_acc_on_train_knn = zeros(n,1); 
    pred_bal_acc_on_train_knn = zeros(n,1);
end

if lda
    pred_acc_lda = zeros(n,1);
    pred_bal_acc_lda = zeros(n,1);
end

if lwlr
    pred_acc_lwlr = zeros(n,1);
    pred_bal_acc_lwlr = zeros(n,1);
    pred_acc_lwlr_train = zeros(n,1);
    pred_bal_acc_lwlr_train = zeros(n,1);
end

if pnr
    pred_acc_pnr = zeros(n,1);
    pred_bal_acc_pnr = zeros(n,1);
end

if randguess
    pred_acc_randguess = zeros(n,1);
    pred_bal_acc_randguess = zeros(n,1);
end

if svm
    pred_acc_svm = zeros(n,1);
    pred_bal_acc_svm = zeros(n,1);
end

if itr_lsq
    pred_acc_irwlsq = zeros(n,1);
    pred_bal_acc_irwlsq = zeros(n,1);
end

if thresh_loud
    pred_acc_tl_loud = zeros(n,1);
    pred_bal_acc_tl_loud = zeros(n,1);
    pred_acc_tl_thresh = zeros(n,1);
    pred_bal_acc_tl_thresh = zeros(n,1);
end

if showfigs
    f_dBs = figure;
    t_dBs = tiledlayout(f_dBs, 'flow');
end

if follow_up_ttest
    adjusted_rating = zeros(n,1);
    standard_rating = zeros(n,1);
    whitenoise_rating = zeros(n,1);
end

if sim_prob
    % Probability distributions of yes or no given a similarity score
    P_ygs = cell(n,1);
    P_ngs = cell(n,1);
    if showfigs
        f_probs_sep = figure;
        f_probs_comb = figure;
        t_probs_sep = tiledlayout(f_probs_sep,n,2);
        t_probs_comb = tiledlayout(f_probs_comb,n,1);
    end
end

for ii = 1:n
    % Get config
    config = parse_config(pathlib.join(config_files(ii).folder, config_files(ii).name));
    IDs(ii) = config.subject_ID;
    [responses, ~] = collect_data('config', config, 'verbose', verbose, 'data_dir', data_dir);
    yesses(ii) = 100 * length(responses(responses == 1))/length(responses);

    if follow_up_ttest
        T_follow_up = collect_data_follow_up('config',config,'data_dir',data_dir,'verbose',verbose);
        adjusted_rating(ii) = mean(T_follow_up.recon_adjusted);
        whitenoise_rating(ii) = mean(T_follow_up.whitenoise);
        standard_rating(ii) = mean(T_follow_up.recon_standard);
    end

    % Generate cross-validated predictions
    if rc
        [pred_rc, true_rc, pred_rc_train, true_rc_train, pred_rc_continuous] = crossval_rc(folds, thresh_vals_rc, ...
                                                                            'config',config,'data_dir',data_dir, ...
                                                                            'mean_zero',mean_zero,'ridge',gs_ridge, ...
                                                                            'verbose',verbose);
        [pred_acc_rc(ii), pred_bal_acc_rc(ii), ~, ~] = get_accuracy_measures(true_rc, pred_rc);
        [pred_acc_rc_train(ii), pred_bal_acc_rc_train(ii), ~, ~] = get_accuracy_measures(true_rc_train, pred_rc_train);
    end

    if rc_adjusted
        [pred_rc_adj, true_rc_adj, pred_rc_train_adj, true_rc_train_adj] = crossval_rc_adjusted(folds, thresh_vals_rc, ...
            'config',config,'data_dir',data_dir, ...
            'mean_zero',mean_zero,'ridge',gs_ridge, ...
            'verbose',verbose);
        [pred_acc_rc_adj(ii), pred_bal_acc_rc_adj(ii), ~, ~] = get_accuracy_measures(true_rc_adj, pred_rc_adj);
        [pred_acc_rc_adj_train(ii), pred_bal_acc_rc_adj_train(ii), ~, ~] = get_accuracy_measures(true_rc_train_adj, pred_rc_train_adj);
    end

    if itr_lsq
        [pred_irwlsq, true_irwlsq] = crossval_irwlsq(folds, thresh_vals_rc, ...
                                                'config',config,'data_dir',data_dir, ...
                                                'mean_zero',mean_zero_irwlsq,'weight_func',weight_func, ...
                                                'verbose',verbose);
        [pred_acc_irwlsq(ii), pred_bal_acc_irwlsq(ii), ~, ~] = get_accuracy_measures(true_irwlsq, pred_irwlsq);
    end

    if knn
        [pred_knn, true_knn, pred_knn_train, true_knn_train] = crossval_knn(folds,k_vals,'config',config, ...
                                                                            'data_dir',data_dir,'method',knn_method, ...
                                                                            'percent',knn_percent,'verbose',verbose);
        [pred_acc_knn(ii), pred_bal_acc_knn(ii), ~, ~] = get_accuracy_measures(true_knn, pred_knn);
        [pred_acc_on_train_knn(ii), pred_bal_acc_on_train_knn(ii), ~, ~] = get_accuracy_measures(true_knn_train, pred_knn_train);
    end

    if lda
        [pred_lda, true_lda] = crossval_lda(folds,'config',config,'data_dir',data_dir,'verbose',verbose);
        [pred_acc_lda(ii), pred_bal_acc_lda(ii), ~, ~] = get_accuracy_measures(true_lda, pred_lda);
    end

    if lwlr
        [pred_lwlr, true_lwlr, pred_lwlr_train, true_lwlr_train] = crossval_lwlr(folds,gauss_h,thresh_vals_lwlr,'config',config,'data_dir',data_dir,'norm_stim',norm_stim_lwlr,'verbose',verbose);
        [pred_acc_lwlr(ii), pred_bal_acc_lwlr(ii), ~, ~] = get_accuracy_measures(true_lwlr, pred_lwlr);
        [pred_acc_lwlr_train(ii), pred_bal_acc_lwlr_train(ii), ~, ~] = get_accuracy_measures(true_lwlr_train, pred_lwlr_train);
    end

    if pnr
        [pred_pnr, true_pnr] = crossval_pnr(folds, pnr_ords, thresh_vals, 'config',config,'data_dir',data_dir,'norm_stim',norm_stim_pnr,'verbose',verbose);
        [pred_acc_pnr(ii), pred_bal_acc_pnr(ii), ~, ~] = get_accuracy_measures(true_pnr, pred_pnr);
    end

    if randguess
        [pred_randguess, true_randguess] = crossval_rand(folds, thresh_vals, 'config',config,'data_dir',data_dir,'dist',randtype,'verbose',verbose);
        [pred_acc_randguess(ii), pred_bal_acc_randguess(ii), ~, ~] = get_accuracy_measures(true_randguess, pred_randguess);
    end

    if svm
        [pred_svm, true_svm] = crossval_svm(folds,'config',config,'data_dir',data_dir,'verbose',verbose);
        [pred_acc_svm(ii), pred_bal_acc_svm(ii), ~, ~] = get_accuracy_measures(true_svm, pred_svm);
    end

    [dBs_loud, ~, tones_loud] = collect_data_thresh_or_loud('loudness', 'config', config, 'data_dir', data_dir, 'verbose', verbose, 'fill_nans', true);
    [dBs_thresh, ~, tones_thresh] = collect_data_thresh_or_loud('threshold', 'config', config, 'data_dir', data_dir, 'verbose', verbose, 'fill_nans', true);
    if isempty(dBs_loud) && isempty(dBs_thresh)
        continue
    else
        recon_lr = get_reconstruction('config', config, 'method', 'linear', ...
            'verbose', verbose, 'data_dir', data_dir);

        recon_cs = get_reconstruction('config', config, 'method', 'linear', ...
            'verbose', verbose, 'data_dir', data_dir);

        % So nothing errors if only thresh or loud but not both exist
        if isempty(dBs_loud)
            dBs_loud = NaN(size(recon_lr));
        elseif isempty(dBs_thresh)
            dBs_thresh = NaN(size(recon_lr));
        end

        % Get bin distribution information for these settings
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);

        % Space tones by bins and interp dBs to those bins
        tones_loud_bindist = tones_to_binspace(tones_loud, stimgen);
        dBs_loud_bindist = interp1(tones_loud, dBs_loud, tones_loud_bindist, 'linear', 'extrap');
        
        tones_thresh_bindist = tones_to_binspace(tones_thresh, stimgen);
        dBs_thresh_bindist = interp1(tones_thresh, dBs_thresh, tones_thresh_bindist, 'linear', 'extrap');

        [dB_loud_corrs_lr(ii), dB_loud_pvals_lr(ii)] = corr(dBs_loud_bindist,recon_lr);
        [dB_loud_corrs_cs(ii), dB_loud_pvals_cs(ii)] = corr(dBs_loud_bindist,recon_cs);

        [dB_thresh_corrs_lr(ii), dB_thresh_pvals_lr(ii)] = corr(dBs_thresh_bindist,recon_lr);
        [dB_thresh_corrs_cs(ii), dB_thresh_pvals_cs(ii)] = corr(dBs_thresh_bindist,recon_cs);

%         dBs_bindist_prime = [0; diff(smoothdata(dBs_bindist,'gaussian'))];

%         [dB_corrs_lr(ii), dB_pvals_lr(ii)] = corr(dBs_bindist_prime,recon_lr(1:end-1));
%         [dB_corrs_cs(ii), dB_pvals_cs(ii)] = corr(dBs_bindist_prime,recon_cs(1:end-1));
         
%         [dB_corrs_lr(ii), dB_pvals_lr(ii)] = corr(dBs_bindist_prime,recon_lr(2:end));
%         [dB_corrs_cs(ii), dB_pvals_cs(ii)] = corr(dBs_bindist_prime,recon_cs(2:end));

%         [dB_corrs_lr(ii), dB_pvals_lr(ii)] = corr(dBs_bindist_prime,diff(recon_lr));
%         [dB_corrs_cs(ii), dB_pvals_cs(ii)] = corr(dBs_bindist_prime,diff(recon_cs));

%         [dB_corrs_lr(ii), dB_pvals_lr(ii)] = corr(dBs_bindist_prime,recon_lr);
%         [dB_corrs_cs(ii), dB_pvals_cs(ii)] = corr(dBs_bindist_prime,recon_cs);


        if thresh_loud
            [resps, stimuli] = collect_data('config', config, 'verbose', verbose, 'data_dir', data_dir);
            [pred_acc_tl_loud(ii), pred_bal_acc_tl_loud(ii)] = ssp(stimuli, resps, dBs_loud_bindist, thresh_vals_tl, mean_zero_tl);
            [pred_acc_tl_thresh(ii), pred_bal_acc_tl_thresh(ii)] = ssp(stimuli, resps, dBs_thresh_bindist, thresh_vals_tl, mean_zero_tl);
        end
        
        if showfigs        
            nexttile(t_dBs);
            plot(rescale(recon_lr), 'LineWidth', linewidth);
            hold on;
            plot(rescale(dBs_loud_bindist), 'LineWidth', linewidth);
            plot(rescale(dBs_thresh_bindist), 'LineWidth', linewidth);
            legend('Reconstruction', 'Loudness dBs', 'Threshold dBs', 'Location', 'southeast')
            xlim([1,32])
            xlabel('Bin Number', 'FontSize', 16)
            ylabel('Amplitude', 'FontSize', 16)
            title(['Subject #', num2str(ii), ' (', config.subject_ID, ')'], 'FontSize', 16)
        end
    end

    if sim_prob
        ys = true_rc == 1; % Probabilities come from CV so use the rotated true vals
        nos = true_rc == -1;
        bin_edges = linspace(min(pred_rc_continuous), max(pred_rc_continuous), n_hists+1);
        bin_cents = (bin_edges(1:end-1) + bin_edges(2:end))/2; % average of each bin

        % P(ans|similarity) = (P(similarity|ans)*P(ans)) / P(similarity)
        P_ygs{ii} = (histcounts(pred_rc_continuous(ys), bin_edges) * sum(ys)/length(true_rc)) ./ histcounts(pred_rc_continuous, bin_edges);
        P_ngs{ii} = (histcounts(pred_rc_continuous(nos), bin_edges) * sum(nos)/length(true_rc)) ./ histcounts(pred_rc_continuous, bin_edges);
        if showfigs
           nexttile(t_probs_sep);
           bar(P_ygs{ii});
           xticks(1:length(P_ygs{ii}))
           xticklabels(bin_cents)
           title(['Subject #', num2str(ii), ' (', config.subject_ID, ') P(Y|sim)'], 'FontSize', 16)

           nexttile(t_probs_sep);
           bar(P_ngs{ii});
           xticks(1:length(P_ngs{ii}))
           xticklabels(bin_cents)
           title(['Subject #', num2str(ii), ' (', config.subject_ID, ') P(N|sim)'], 'FontSize', 16)

           nexttile(t_probs_comb)
           bar(P_ngs{ii},0.5,'FaceColor',[0.2 0.2 0.5]);
           hold on
           bar(P_ygs{ii},0.25,'FaceColor',[0 0.7 0.7]);
           xticks(1:length(P_ngs{ii}))
           xticklabels(bin_cents)
           title(['Subject #', num2str(ii), ' (', config.subject_ID, ') P(ans|sim)'], 'FontSize', 16)
           legend({'No', 'Yes'})
        end
    end
end

%% Trim tiledlayout to only n_best_plot axes
[~, best_subjs] = maxk(pred_bal_acc_rc, n_best_plot);
for tile = setdiff(1:n,best_subjs)
    delete(nexttile(t_dBs, tile));
end

%% Create tables
T_dB_loud_corrs = table(dB_loud_corrs_lr, dB_loud_pvals_lr, dB_loud_corrs_cs, dB_loud_pvals_cs, IDs, ...
    'VariableNames', ["Loudness Corr LR", "Loudness p val LR", ...
    "Loudness Corr CS", "Loudness p val CS", "subject ID"], ...
    'RowNames', row_names)

T_dB_thresh_corrs = table(dB_thresh_corrs_lr, dB_thresh_pvals_lr, dB_thresh_corrs_cs, dB_thresh_pvals_cs, IDs, ...
    'VariableNames', ["Threshold Corr LR", "Threshold p val LR", ...
    "Threshold Corr CS", "Threshold p val CS", "subject ID"], ...
    'RowNames', row_names)

T_yesses = table(yesses, IDs, 'VariableNames', ["Percent yes", "subject ID"], 'RowNames', row_names);

if follow_up_ttest
    [~, p_sw, ~, tstat_sw] = ttest(standard_rating, whitenoise_rating);
    [~, p_aw, ~, tstat_aw] = ttest(adjusted_rating, whitenoise_rating);
    [~, p_sa, ~, tstat_sa] = ttest(standard_rating, adjusted_rating);

    T_follow_up_ttest = [table([p_sw; p_aw; p_sa], ...
        'VariableNames', "P Value", ...
        'RowNames', {'Standard-White', 'Adjusted-White', 'Adjusted-Standard'}), ...
        struct2table([tstat_sw; tstat_aw; tstat_sa])]

    % Make this table too because it's handy. Only guaranteed if follow_up_ttest is true
    T_ratings = table(standard_rating, adjusted_rating, whitenoise_rating, IDs, ...
        'VariableNames',["Avg Standard Rating", "Avg Adjusted Rating", ...
        "Avg Whitenoise Rating", "subject ID"]);
end

if rc
    T_CV_rc = table(pred_bal_acc_rc, pred_acc_rc, IDs, ...
        'VariableNames', ["RC CV Pred Bal Acc", "RC CV Pred Acc", "subject ID"], ...
        'RowNames', row_names)
    T_CV_rc_train = table(pred_bal_acc_rc_train, pred_acc_rc_train, IDs, ...
        'VariableNames', ["RC CV Pred Bal Acc On Train", "RC CV Pred Acc On Train", "subject ID"], ...
        'RowNames', row_names)
    if length(pred_bal_acc_rc) > 1
        [~, CV_rc_bal_acc_p, ~, CV_rc_bal_acc_tstats] = ttest(pred_bal_acc_rc, 0.5)
    end
end

if rc_adjusted
    T_CV_rc_adj = table(pred_bal_acc_rc_adj, pred_acc_rc_adj, IDs, ...
        'VariableNames', ["RC Adj CV Pred Bal Acc", "RC Adj CV Pred Acc", "subject ID"], ...
        'RowNames', row_names)
    T_CV_rc_adj_train = table(pred_bal_acc_rc_adj_train, pred_acc_rc_adj_train, IDs, ...
        'VariableNames', ["RC Adj CV Pred Bal Acc On Train", "RC Adj CV Pred Acc On Train", "subject ID"], ...
        'RowNames', row_names)
    if length(pred_bal_acc_rc) > 1
        [~, CV_rc_adj_bal_acc_p, ~, CV_rc_adj_bal_acc_tstats] = ttest(pred_bal_acc_rc_adj, 0.5)
    end
end

if itr_lsq
    T_CV_irwlsq = table(pred_bal_acc_irwlsq, pred_acc_irwlsq, IDs, ...
        'VariableNames', ["IRWLSQ CV Pred Bal Acc", "IRWLSQ CV Pred Acc", "subject ID"], ...
        'RowNames', row_names)
end

if knn
    T_CV_knn = table(pred_bal_acc_knn, pred_acc_knn, ...
        'VariableNames', ["KNN CV Pred Bal Acc", "KNN CV Pred Acc"], ...
        'RowNames', row_names)
    
    T_CV_on_train_knn = table(pred_bal_acc_on_train_knn, pred_acc_on_train_knn, ...
        'VariableNames', ["KNN CV Pred Bal Acc On Train", "KNN CV Pred Acc On Train"], ...
        'RowNames', row_names)
end

if lda
    T_CV_lda = table(pred_bal_acc_lda, pred_acc_lda, ...
        'VariableNames', ["LDA CV Pred Bal Acc", "LDA CV Pred Acc"], ...
        'RowNames', row_names)
end

if lwlr
    T_CV_lwlr = table(pred_bal_acc_lwlr, pred_acc_lwlr, ...
        'VariableNames', ["LWLR CV Pred Bal Acc", "LWLR CV Pred Acc"], ...
        'RowNames', row_names)
    T_CV_lwlr_train = table(pred_bal_acc_lwlr_train, pred_acc_lwlr_train, ...
        'VariableNames', ["LWLR CV Pred Bal Acc On Train", "LWLR CV Pred Acc On Train"], ...
        'RowNames', row_names)
end

if pnr
    T_CV_pnr = table(pred_bal_acc_pnr, pred_acc_pnr, ...
        'VariableNames', ["PNR CV Pred Bal Acc", "PNR CV Pred Acc"], ...
        'RowNames', row_names)
end

if randguess
    T_CV_randguess = table(pred_bal_acc_randguess, pred_acc_randguess, ...
        'VariableNames', ["Random CV Pred Bal Acc", "Random CV Pred Acc"], ...
        'RowNames', row_names)
end

if svm
    T_CV_svm = table(pred_bal_acc_svm, pred_acc_svm, ...
        'VariableNames', ["SVM CV Pred Bal Acc", "SVM CV Pred Acc"], ...
        'RowNames', row_names)
end

if thresh_loud
    T_CV_loud = table(pred_bal_acc_tl_loud, pred_acc_tl_loud, IDs, ...
        'VariableNames', ["Loudness dBs Pred Bal Acc", "Loudness dBs Pred Acc", "subject ID"], ...
        'RowNames', row_names)
    T_CV_thresh = table(pred_bal_acc_tl_thresh, pred_acc_tl_thresh, IDs, ...
        'VariableNames', ["Threshold dBs Pred Bal Acc", "Threshold dBs Pred Acc", "subject ID"], ...
        'RowNames', row_names)

    if length(pred_bal_acc_tl_thresh) > 1
        [~, CV_thresh_bal_acc_p, ~, CV_thresh_bal_acc_tstats] = ttest(pred_bal_acc_tl_thresh, 0.5)
    end
    if length(pred_bal_acc_tl_loud) > 1
        [~, CV_loud_bal_acc_p, ~, CV_loud_bal_acc_tstats] = ttest(pred_bal_acc_tl_loud, 0.5)
    end
end

%% Local functions
function [unbinned_recon, indices_to_plot, freqs] = unbin(binned_recon, stimgen, max_freq, min_freq)
    recon_binrep = rescale(binned_recon, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);
    
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spectrum))';
    indices_to_plot = freqs(:,1) <= max_freq & freqs(:,1) >= min_freq;
    
    unbinned_recon = stimgen.binnedrepr2spect(binned_recon);
    unbinned_recon(unbinned_recon == 0) = NaN;
end

function [pred_acc, pred_bal_acc] = ssp(stimuli, responses, repr, thresh_vals, mean_zero)
    if all(isnan(repr))
        pred_acc = 0;
        pred_bal_acc = 0;
        return
    end
    % Projection
    if mean_zero
        e = (stimuli' - mean(stimuli,1)') * (repr - mean(repr));
    else
        e = stimuli' * repr;
    end

    % Convert to response
    thresh_dev = zeros(length(thresh_vals),1);
    for jj = 1:length(thresh_vals)
        p = sign(e + thresh_vals(jj));
        [~, thresh_dev(jj), ~, ~] = get_accuracy_measures(responses, p);
    end
    [~, thresh_ind] = max(thresh_dev);
    p = sign(e + thresh_vals(thresh_ind));
    [pred_acc, pred_bal_acc, ~, ~] = get_accuracy_measures(responses, p);
end
