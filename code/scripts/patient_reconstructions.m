% Reconstruct and visualize patient tinnitus

%%%%% NOTE: Figure generation is tempermental. make_figures_paper2 is
%%%%% better but doesn't label figures the same.

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';
config_files = dir(pathlib.join(data_dir, '*.yaml'));

% Script parameters
CS = true;
showfigs = false;
verbose = false;

n = length(config_files);
skip_subjects = {'KB_1', 'CH_2', 'JG_3', 'KE_6'};

% Pre-allocate  
yesses = zeros(n, 1); 

%% Plot setup
if showfigs
    rows = ceil((n - length(skip_subjects))/2);
    
    if CS
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
    
    %% Loop and plot
    for i = 1:n
        %%%%% Get data %%%%%
        config = parse_config(pathlib.join(config_files(i).folder, config_files(i).name));
        
        % Skip deliberate config files or ones with target signals (healthy controls)
        if all(ismember(config.subject_ID, skip_subjects)) || ...
            (isfield(config, 'target_signal') && ~isempty(config.target_signal))
            continue
        end
    
        % Get subject ID number 
        ID_num = extractAfter(config.subject_ID, '_');
        if isempty(ID_num)
            ID_num = '???';
        end
    
        % Get reconstructions
        [reconstruction_binned_lr, ~, responses, stimuli_matrix] = get_reconstruction('config', config, ...
                                                                                        'method', 'linear_ridge', ...
                                                                                        'verbose', verbose, ...
                                                                                        'data_dir', data_dir ...
                                                                                    );

        if CS
            reconstruction_binned_cs = get_reconstruction('config', config, 'method', 'cs', ...
                                                            'verbose', verbose, 'data_dir', data_dir ...
                                                        );
        end
    
        %%%%% Binned %%%%%
    
        % Linear
        if i == n-length(skip_subjects)
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
            if i == n-length(skip_subjects)
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
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    
        % Linear
        if i == n-length(skip_subjects)
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
            if i == n-length(skip_subjects)
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
    end
end
%% Predict responses with cross validation
row_names = cellstr(strcat('Subject', {' '}, string((1:n))));

% Analysis flags
rc = true;
knn = false;
lda = false;
lwlr = false;
pnr = false;
randguess = false;
svm = false;

% Global settings
folds = 5;
% thresh_vals = linspace(-1,1,100000);
% thresh_vals = linspace(-10000,10000,1000000);

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

for ii = 1:n
    % Get config
    config = parse_config(pathlib.join(config_files(ii).folder, config_files(ii).name));
    [responses, ~] = collect_data('config', config, 'verbose', verbose, 'data_dir', data_dir);
    yesses(ii) = 100 * length(responses(responses == 1))/length(responses);

    if all(ismember(config.subject_ID, skip_subjects))
        continue
    end

    % Generate cross-validated predictions
    if rc
        [pred_rc, true_rc, pred_rc_train, true_rc_train] = crossval_rc(folds, thresh_vals_rc, ...
                                                                            'config',config,'data_dir',data_dir, ...
                                                                            'mean_zero',mean_zero,'ridge',gs_ridge, ...
                                                                            'verbose',verbose);
        [pred_acc_rc(ii), pred_bal_acc_rc(ii), ~, ~] = get_accuracy_measures(true_rc, pred_rc);
        [pred_acc_rc_train(ii), pred_bal_acc_rc_train(ii), ~, ~] = get_accuracy_measures(true_rc_train, pred_rc_train);
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
end

if rc
    T_CV_rc = table(pred_bal_acc_rc, pred_acc_rc, ...
        'VariableNames', ["RC CV Pred Bal Acc", "RC CV Pred Acc"], ...
        'RowNames', row_names)
    T_CV_rc_train = table(pred_bal_acc_rc_train, pred_acc_rc_train, ...
        'VariableNames', ["RC CV Pred Bal Acc On Train", "RC CV Pred Acc On Train"], ...
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

%% Local functions
function [unbinned_recon, indices_to_plot, freqs] = unbin(binned_recon, stimgen, max_freq, min_freq)
    recon_binrep = rescale(binned_recon, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);
    
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spectrum))';
    indices_to_plot = freqs(:,1) <= max_freq & freqs(:,1) >= min_freq;
    
    unbinned_recon = stimgen.binnedrepr2spect(binned_recon);
    unbinned_recon(unbinned_recon == 0) = NaN;
end
