% Reconstruct and visualize patient tinnitus

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';
% data_dir = '~/repos/TinnitusStimulusFitter.jl/data/smote_patient_data';
config_files = dir(pathlib.join(data_dir, '*.yaml'));

% Script parameters
CS = true;
verbose = true;

% Fields to keep for comparing configs
keep_fields = {'n_trials_per_block', 'n_blocks', 'total_trials', ...
    'min_freq', 'max_freq', 'duration', 'n_bins', 'stimuli_type', ...
    'min_bins', 'max_bins'};

n = length(config_files);

% Pre-allocate  
sensitivity = zeros(n, 1);
specificity = zeros(n, 1);
accuracy = zeros(n, 1);
bal_accuracy = zeros(n, 1);
yesses = zeros(n, 1);

%% Plot setup
rows = ceil(n/2);

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
    
    % Keep previous config obj. and rm_fields for setting comparison
    if i > 1
        prev_config = config;
        prev_rm_fields = rm_fields;
        prev_names = names;
    end

    config = parse_config(pathlib.join(config_files(i).folder, config_files(i).name));
    
    % Skip config files with target signals (healthy controls)
    if isfield(config, 'target_signal') && ~isempty(config.target_signal)
        continue
    end

    % Get subject ID number 
    ID_num = extractAfter(config.subject_ID, '_');
    if isempty(ID_num)
        ID_num = '???';
    end

    % Non-critical fields in current config
    names = fieldnames(config);
    rm_fields = ~ismember(names, keep_fields);

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

    %%%%% Compare responses to synthetic %%%%% 
    y_hat = subject_selection_process(reconstruction_binned_lr, ...
                                    stimuli_matrix', [], responses, ...
                                    'mean_zero', true, ...
                                    'from_responses', true, ...
                                    'verbose', verbose ...
                                );

    yesses(i) = 100 * length(responses(responses == 1))/length(responses);
    [accuracy(i), bal_accuracy(i), sensitivity(i), specificity(i)] = get_accuracy_measures(responses, y_hat);

    %%%%% Binned %%%%%

    % Linear
    if i == n && mod(n, 2)
        tile = nexttile(t_binned, [1,2]);
        tile_num = tilenum(tile);
    else
        tile = nexttile(t_binned);
        tile_num = tilenum(tile);
    end

    plot(my_normalize(reconstruction_binned_lr), linecolor, ...
        'LineWidth', linewidth);

    xlim([1, config.n_bins]);

    % Label only last row
    if tile_num >= rows*(cols-1)
        xlabel('Bin #', 'FontSize', 16)
    end

    % Label start of each row
    if ismember(tile_num, label_y)
        ylabel('Power (dB)', 'FontSize', 16);
    end

    title(['Subject #', ID_num, ' - Linear'], 'FontSize', 18);
    set(gca, 'yticklabels', [], 'FontWeight', 'bold')

    % CS
    if CS
        if i == n && mod(n, 2)
            tile = nexttile(t_binned, [1,2]);
            tile_num = tilenum(tile);
        else
            tile = nexttile(t_binned);
            tile_num = tilenum(tile);
        end
    
        plot(my_normalize(reconstruction_binned_cs), linecolor, ...
            'LineWidth', linewidth);
    
        xlim([1, config.n_bins]);
    
        % Label only last row
        if tile_num >= rows*(cols-1)
            xlabel('Bin #', 'FontSize', 16)
        end
    
        title(['Subject #', ID_num, ' - CS'], 'FontSize', 18);
        set(gca, 'yticklabels', [], 'FontWeight', 'bold')
    end

    %%%%% Unbinned %%%%%

    % Create a new stimgen object if current config settings are different
    if i == 1
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    elseif ~isequal(rmfield(config, names(rm_fields)), rmfield(prev_config, prev_names(prev_rm_fields)))
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    end

    % Linear
    if i == n && mod(n, 2)
        tile = nexttile(t_unbinned, [1,2]);
        tile_num = tilenum(tile);
    else
        tile = nexttile(t_unbinned);
        tile_num = tilenum(tile);
    end

    % Unbin
    [unbinned_lr, indices_to_plot, freqs] = unbin(reconstruction_binned_lr, stimgen, config.max_freq, config.min_freq);

    % Plot
    plot(freqs(indices_to_plot, 1), my_normalize(unbinned_lr(indices_to_plot)), ...
        linecolor, 'LineWidth', linewidth);

    xlim([0, config.max_freq]);

    % Label only last row
    if tile_num >= rows*(cols-1)
        xlabel('Frequency (Hz)', 'FontSize', 16)
    end

    % Label start of each row
    if ismember(tile_num, label_y)
        ylabel('Power (dB)', 'FontSize', 16);
    end

    title(['Subject #', ID_num, ' - Linear'], 'FontSize', 18);
    set(gca, 'yticklabels', [], 'FontWeight', 'bold')

    % CS
    if CS
        if i == n && mod(n, 2)
            tile = nexttile(t_unbinned, [1,2]);
            tile_num = tilenum(tile);
        else
            tile = nexttile(t_unbinned);
            tile_num = tilenum(tile);
        end
    
        % Unbin
        [unbinned_cs, indices_to_plot, freqs] = unbin(reconstruction_binned_cs, stimgen, config.max_freq, config.min_freq);
    
        % Plot
        plot(freqs(indices_to_plot, 1), my_normalize(unbinned_cs(indices_to_plot)), ...
            linecolor, 'LineWidth', linewidth);
    
        xlim([0, config.max_freq]);
    
        % Label only last row
        if tile_num >= rows*(cols-1) 
            xlabel('Frequency (Hz)', 'FontSize', 16)
        end
    
        title(['Subject #', ID_num, ' - CS'], 'FontSize', 18);
        set(gca, 'yticklabels', [], 'FontWeight', 'bold')
    end
end

%% Accuracy
row_names = cellstr(strcat('Subject', {' '}, string((1:n))));

% Create table and print for easy viewing.
T = table(bal_accuracy, accuracy, sensitivity, specificity, yesses, ...
    'VariableNames', ["Balanced Accuracy", "Accuracy", "Sensitivity", "Specificity", "% Yesses"], ...
    'RowNames', row_names);

%% Predict responses with cross validation

% Prediction settings
folds = 5;
knn = false;
mean_zero = true;
from_responses = false;
gs_ridge = true;
thresh_vals = linspace(10,90,200);
k_vals = 1:2:15;

% Initialize
pred_acc_cs = zeros(n,1);
pred_acc_lr = zeros(n,1); 

pred_bal_acc_cs = zeros(n,1);
pred_bal_acc_lr = zeros(n,1);

pred_acc_on_train_cs = zeros(n,1);
pred_acc_on_train_lr = zeros(n,1); 

pred_bal_acc_on_train_cs = zeros(n,1);
pred_bal_acc_on_train_lr = zeros(n,1);

if knn
    pred_acc_knn = zeros(n,1);
    pred_bal_acc_knn = zeros(n,1);
    pred_acc_on_train_knn = zeros(n,1); 
    pred_bal_acc_on_train_knn = zeros(n,1);
end

for ii = 1:n
    % Get config
    config = parse_config(pathlib.join(config_files(ii).folder, config_files(ii).name));

    % Generate cross-validated predictions
    [given_responses, training_responses, pred_on_test, pred_on_train] = crossval_predicted_responses(folds, ...
                                                                            'config', config, 'data_dir', data_dir, ...
                                                                            'knn', knn, 'from_responses', from_responses, ...
                                                                            'mean_zero', mean_zero, 'ridge_reg', gs_ridge, ...
                                                                            'threshold_values', thresh_vals, 'k_vals', k_vals, ...
                                                                            'verbose', verbose ...
                                                                        );

    % Assess prediction quality
    [pred_acc_cs(ii), pred_bal_acc_cs(ii), ~, ~] = get_accuracy_measures(given_responses, pred_on_test.cs);
    [pred_acc_lr(ii), pred_bal_acc_lr(ii), ~, ~] = get_accuracy_measures(given_responses, pred_on_test.lr);

    [pred_acc_on_train_cs(ii), pred_bal_acc_on_train_cs(ii), ~, ~] = get_accuracy_measures(training_responses, pred_on_train.cs);
    [pred_acc_on_train_lr(ii), pred_bal_acc_on_train_lr(ii), ~, ~] = get_accuracy_measures(training_responses, pred_on_train.lr);

    if knn
        [pred_acc_knn(ii), pred_bal_acc_knn(ii), ~, ~] = get_accuracy_measures(given_responses, pred_on_test.knn);
        [pred_acc_on_train_knn(ii), pred_bal_acc_on_train_knn(ii), ~, ~] = get_accuracy_measures(training_responses, pred_on_train.knn);
    end
end

% Print results
T_CV = table(pred_bal_acc_lr, pred_bal_acc_cs, pred_acc_lr, pred_acc_cs, ...
    'VariableNames', ["LR CV Pred Bal Acc", "CS CV Pred Bal Acc", "LR CV Pred Acc", "CS CV Pred Acc"], ...
    'RowNames', row_names)

T_CV_on_train = table(pred_bal_acc_on_train_lr, pred_bal_acc_on_train_cs, pred_acc_on_train_lr, pred_acc_on_train_cs, ...
    'VariableNames', ["LR CV Pred Bal Acc On Train", "CS CV Pred Bal Acc On Train", "LR CV Pred Acc On Train", "CS CV Pred Acc On Train"], ...
    'RowNames', row_names)

if knn
    T_CV_knn = table(pred_bal_acc_knn, pred_acc_knn, ...
        'VariableNames', ["KNN CV Pred Bal Acc", "KNN CV Pred Acc"], ...
        'RowNames', row_names)
    
    T_CV_on_train_knn = table(pred_bal_acc_on_train_knn, pred_acc_on_train_knn, ...
        'VariableNames', ["KNN CV Pred Bal Acc On Train", "KNN CV Pred Acc On Train"], ...
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
