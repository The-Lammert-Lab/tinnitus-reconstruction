% Reconstruct and visualize patient tinnitus

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';

config_files = dir(pathlib.join(data_dir, '*.yaml'));

CS = true;

% Fields to keep for comparing configs
keep_fields = {'n_trials_per_block', 'n_blocks', 'total_trials', ...
    'min_freq', 'max_freq', 'duration', 'n_bins', 'stimuli_type', ...
    'min_bins', 'max_bins'};

n = length(config_files);

% Pre-allocate
sensitivity = zeros(n,1);
specificity = zeros(n, 1);
accuracy = zeros(n, 1);

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
    [reconstructions_binned_lr, ~, responses, stimuli_matrix] = get_reconstruction('config', config, ...
        'method', 'linear', ...
        'verbose', true, ...
        'data_dir', data_dir);

    if CS
        reconstructions_binned_cs = get_reconstruction('config', config, ...
            'method', 'cs', ...
            'verbose', true, ...
            'data_dir', data_dir);
    end

    %%%%% Compare responses to synthetic %%%%% 
    e = stimuli_matrix' * reconstructions_binned_lr;
    y = double(e >= prctile(e, 100 * length(find(responses == -1))/length(responses)));
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

    plot(my_normalize(reconstructions_binned_lr), linecolor, ...
        'LineWidth', linewidth);

    xlim([1, config.n_bins]);

    % Label only last row
    if i > rows
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
            nexttile(t_binned, [1,2])
        else
            nexttile(t_binned)
        end
    
        plot(my_normalize(reconstructions_binned_cs), linecolor, ...
            'LineWidth', linewidth);
    
        xlim([1, config.n_bins]);
    
        % Label only last row
        if i > rows
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
    [unbinned_lr, indices_to_plot, freqs] = unbin(reconstructions_binned_lr, stimgen, config.max_freq);

    % Plot
    plot(freqs(indices_to_plot, 1), my_normalize(unbinned_lr(indices_to_plot)), ...
        linecolor, 'LineWidth', linewidth);

    xlim([0, config.max_freq]);

    % Label only last row
    if i > rows
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
            nexttile(t_unbinned, [1,2])
        else
            nexttile(t_unbinned)
        end
    
        % Unbin
        [unbinned_cs, indices_to_plot, freqs] = unbin(reconstructions_binned_cs, stimgen, config.max_freq);
    
        % Plot
        plot(freqs(indices_to_plot, 1), my_normalize(unbinned_cs(indices_to_plot)), ...
            linecolor, 'LineWidth', linewidth);
    
        xlim([0, config.max_freq]);
    
        % Label only last row
        if i > rows
            xlabel('Frequency (Hz)', 'FontSize', 16)
        end
    
        title(['Subject #', ID_num, ' - CS'], 'FontSize', 18);
        set(gca, 'yticklabels', [], 'FontWeight', 'bold')
    end
end

bal_accuracy = (specificity + sensitivity)/2;

%% Local functions
function [unbinned_recon, indices_to_plot, freqs] = unbin(binned_recon, stimgen, max_freq)
    recon_binrep = rescale(binned_recon, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);
    
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spectrum))';
    indices_to_plot = freqs(:, 1) <= max_freq;
    
    unbinned_recon = stimgen.binnedrepr2spect(binned_recon);
    unbinned_recon(unbinned_recon == 0) = NaN;
end

