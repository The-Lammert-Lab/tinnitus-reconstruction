% Reconstruct and visualize patient tinnitus

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';

config_files = dir(pathlib.join(data_dir, '*.yaml'));

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
                                                                                    'method', 'linear', ...
                                                                                    'verbose', verbose, ...
                                                                                    'data_dir', data_dir ...
                                                                                );

    if CS
        reconstruction_binned_cs = get_reconstruction('config', config, ...
                                                        'method', 'cs', ...
                                                        'verbose', verbose, ...
                                                        'data_dir', data_dir ...
                                                    );
    end

    %%%%% Compare responses to synthetic %%%%% 
    yesses(i) = 100 * length(responses(responses == 1))/length(responses);

%     e = stimuli_matrix' * reconstructions_binned_lr;
    e = (stimuli_matrix - mean(stimuli_matrix,2))' * (reconstruction_binned_lr - mean(reconstruction_binned_lr));
    
    % Percentile is percent of "no" answers for current subject.
    y = double(e >= prctile(e, 100 - yesses(i)));
    y(y == 0) = -1;

    TP = sum((responses==1)&(y==1));
    FP = sum((responses==-1)&(y==1));
    FN = sum((responses==1)&(y==-1));
    TN = sum((responses==-1)&(y==-1));

    specificity(i) = TN/(TN+FP);
    sensitivity(i) = TP/(TP+FN);
    accuracy(i) = (TP + TN) / (TP + TN + FP + FN);

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
    [unbinned_lr, indices_to_plot, freqs] = unbin(reconstruction_binned_lr, stimgen, config.max_freq);

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
        [unbinned_cs, indices_to_plot, freqs] = unbin(reconstruction_binned_cs, stimgen, config.max_freq);
    
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
bal_accuracy = (specificity + sensitivity)/2;

% Create table and print for easy viewing.
T = table(bal_accuracy, accuracy, sensitivity, specificity, yesses, ...
    'VariableNames', ["Balanced Accuracy", "Accuracy", "Sensitivity", "Specificity", "% Yesses"], ...
    'RowNames', cellstr(strcat('Subject', {' '}, string((1:n)))))

%% Predict responses with cross validation
folds = 5;

% NOTE: This breaks if not all the subjects did the same number of trials
leave_out = round(length(responses) / folds);

predicted_responses_cs = zeros(length(responses), n);
predicted_responses_lr = zeros(length(responses), n);
given_responses = zeros(length(responses), n);
corr_lr = zeros(1,n); 
corr_cs = zeros(1,n);

for ii = 1:n
    % Get responses and stimuli
    config = parse_config(pathlib.join(config_files(ii).folder, config_files(ii).name));
    [responses, stimuli_matrix] = collect_data('config', config, 'verbose', verbose, 'data_dir', data_dir);
    for jj = 1:folds
        % Shift data
        responses = circshift(responses, leave_out);
        stimuli_matrix = circshift(stimuli_matrix, leave_out, 2);

        % Split data
        responses_train = responses(1:size(responses,1)-leave_out);
        responses_test = responses(size(responses,1)-leave_out+1:end);
        stimuli_matrix_train = stimuli_matrix(:, 1:size(stimuli_matrix,2)-leave_out);
        stimuli_matrix_test = stimuli_matrix(:, size(stimuli_matrix,2)-leave_out+1:end);

        % Get reconstructions
        gamma = get_gamma_from_config(config, verbose);

        recon_cs = cs(responses_train, stimuli_matrix_train', gamma, 'verbose', verbose);
        recon_lr = gs(responses_train, stimuli_matrix_train');

        % Make predictions
        pred_cs = subject_selection_process(recon_cs, stimuli_matrix_test');
        pred_lr = subject_selection_process(recon_lr, stimuli_matrix_test');

        % Store predictions
        filled = nnz(predicted_responses_cs);
        predicted_responses_cs(filled+1:filled+length(pred_cs), ii) = pred_cs;
        predicted_responses_lr(filled+1:filled+length(pred_lr), ii) = pred_lr;
        given_responses(filled+1:filled+length(responses_test), ii) = responses_test;
    end
    corr_lr(1,ii) = corr(predicted_responses_lr(:,ii), given_responses(:,ii));
    corr_cs(1,ii) = corr(predicted_responses_cs(:,ii), given_responses(:,ii));
end


%% Local functions
function [unbinned_recon, indices_to_plot, freqs] = unbin(binned_recon, stimgen, max_freq)
    recon_binrep = rescale(binned_recon, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);
    
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spectrum))';
    indices_to_plot = freqs(:, 1) <= max_freq;
    
    unbinned_recon = stimgen.binnedrepr2spect(binned_recon);
    unbinned_recon(unbinned_recon == 0) = NaN;
end
