% Reconstruct and visualize patient tinnitus

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';

config_files = dir(pathlib.join(data_dir, '*.yaml'));

reconstructions_binned_lr = cell(length(config_files), 1);
reconstructions_binned_cs = cell(length(config_files), 1);
ID_nums = cell(length(config_files), 1);
config = cell(length(config_files), 1);

%% Generate reconstructions
for i = 1:length(config_files)
    config{i} = parse_config(pathlib.join(config_files(i).folder, config_files(i).name));
    ID_nums{i} = extractAfter(config{i}.subject_ID, '_');

    reconstructions_binned_lr{i} = get_reconstruction('config', config{i}, ...
        'method', 'linear', ...
        'verbose', true, ...
        'data_dir', data_dir);
    reconstructions_binned_cs{i} = get_reconstruction('config', config{i}, ...
        'method', 'cs', ...
        'verbose', true, ...
        'data_dir', data_dir);
end

% Get stimgen and Fs from first config
stimgen = eval([char(config{1}.stimuli_type), 'StimulusGeneration()']);
stimgen = stimgen.from_config(config{1});
Fs = stimgen.Fs;

% Fields to remove for comparing configs
fields = {'experiment_name', 'subject_ID', 'data_dir', ...
    'stimuli_save_type', 'follow_up', 'follow_up_version'};

%% Plot setup
rows = ceil(length(config_files)/2);
cols = 4;

label_y = 1:0.5*cols:0.5*(rows*cols);

linewidth = 1.5;
linecolor = 'b';

my_normalize = @(x) normalize(x, 'zscore', 'std');

% Figs
f_binned = figure;
t_binned = tiledlayout(f_binned, rows, cols);

f_unbinned = figure;
t_unbinned = tiledlayout(f_unbinned, rows, cols);

% Loop and plot
for i = 1:length(config_files)
    %%%%% Binned %%%%%

    % Linear
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile(t_binned, [1,2])
    else
        nexttile(t_binned)
    end

    plot(my_normalize(reconstructions_binned_lr{i}), linecolor, ...
        'LineWidth', linewidth);

    xlim([1, config{i}.n_bins]);

    % Label only last row
    if i > rows
        xlabel('Bin #', 'FontSize', 16)
    end

    % Label start of each row
    if ismember(i, label_y)
        ylabel('Power (dB)', 'FontSize', 16);
    end

    title(['Subject ', ID_nums{i}, ' - Linear'], 'FontSize', 18);
    set(gca, 'yticklabels', [], 'FontWeight', 'bold')

    % CS
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile(t_binned, [1,2])
    else
        nexttile(t_binned)
    end

    plot(my_normalize(reconstructions_binned_cs{i}), linecolor, ...
        'LineWidth', linewidth);

    xlim([1, config{i}.n_bins]);

    % Label only last row
    if i > rows
        xlabel('Bin #', 'FontSize', 16)
    end

    title(['Subject ', ID_nums{i}, ' - CS'], 'FontSize', 18);
    set(gca, 'yticklabels', [], 'FontWeight', 'bold')

    %%%%% Unbinned %%%%%

    % Create a new stimgen object if current config settings are different
    if i > 1 && ~isequal(rmfield(config{i}, fields), rmfield(config{i-1}, fields))
        stimgen = eval([char(config{i}.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config{i});
        Fs = stimgen.Fs;
    end

    % Linear
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile(t_unbinned, [1,2])
    else
        nexttile(t_unbinned)
    end

    % Unbin
    recon_binrep = rescale(reconstructions_binned_lr{i}, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);

    freqs = linspace(1, floor(Fs/2), length(recon_spectrum))'; % ACL
    indices_to_plot = freqs(:, 1) <= config{i}.max_freq;

    unbinned_lr = stimgen.binnedrepr2spect(reconstructions_binned_lr{i});
    unbinned_lr(unbinned_lr == 0) = NaN;

    % Plot
    plot(freqs(indices_to_plot, 1), my_normalize(unbinned_lr(indices_to_plot)), ...
        linecolor, 'LineWidth', linewidth);

    xlim([0, config{i}.max_freq]);

    % Label only last row
    if i > rows
        xlabel('Frequency (Hz)', 'FontSize', 16)
    end

    % Label start of each row
    if ismember(i, label_y)
        ylabel('Power (dB)', 'FontSize', 16);
    end

    title(['Subject ', ID_nums{i}, ' - Linear'], 'FontSize', 18);
    set(gca, 'yticklabels', [], 'FontWeight', 'bold')

    % CS
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile(t_unbinned, [1,2])
    else
        nexttile(t_unbinned)
    end

    % Unbin
    recon_binrep = rescale(reconstructions_binned_cs{i}, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);

    freqs = linspace(1, floor(Fs/2), length(recon_spectrum))'; % ACL
    indices_to_plot = freqs(:, 1) <= config{i}.max_freq;

    unbinned_cs = stimgen.binnedrepr2spect(reconstructions_binned_cs{i});
    unbinned_cs(unbinned_cs == 0) = NaN;

    % Plot
    plot(freqs(indices_to_plot, 1), my_normalize(unbinned_cs(indices_to_plot)), ...
        linecolor, 'LineWidth', linewidth);

    xlim([0, config{i}.max_freq]);

    % Label only last row
    if i > rows
        xlabel('Frequency (Hz)', 'FontSize', 16)
    end

    title(['Subject ', ID_nums{i}, ' - CS'], 'FontSize', 18);
    set(gca, 'yticklabels', [], 'FontWeight', 'bold')
end
