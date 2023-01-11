% Reconstruct and visualize patient tinnitus

%% Setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';

config_files = dir(pathlib.join(data_dir, '*.yaml'));

reconstructions_binned_lr = cell(length(config_files), 1);
reconstructions_binned_cs = cell(length(config_files), 1);
ID_nums = cell(length(config_files), 1);

my_normalize = @(x) normalize(x, 'zscore', 'std');

%% Generate reconstructions
for i = 1:length(config_files)
    config = parse_config(pathlib.join(config_files(i).folder, config_files(i).name));
    ID_nums{i} = extractAfter(config.subject_ID, '_');

    reconstructions_binned_lr{i} = get_reconstruction('config', config, ...
        'method', 'linear', ...
        'verbose', true, ...
        'data_dir', data_dir);
    reconstructions_binned_cs{i} = get_reconstruction('config', config, ...
        'method', 'cs', ...
        'verbose', true, ...
        'data_dir', data_dir);
end

% Config settings are the same so just use the last one
stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
stimgen = stimgen.from_config(config);

Fs = stimgen.Fs;

%% Plot
rows = ceil(length(config_files)/2);
cols = 4;

label_y = 1:0.5*cols:0.5*(rows*cols);

% Binned
figure;
t = tiledlayout(rows, cols);

for i = 1:length(config_files)
    % Linear
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile([1,2])
    else
        nexttile
    end

    plot(my_normalize(reconstructions_binned_lr{i}), 'k');

    title(['Subject ', ID_nums{i}, ' - linear'], 'FontSize', 18);
    xlabel('Bin #', 'FontSize', 16)
    xlim([1, config.n_bins]);

    if ismember(i, label_y)
        ylabel({'Standardized'; 'Amplitude'}, 'FontSize', 14);
    end

    % CS
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile([1,2])
    else
        nexttile
    end

    plot(my_normalize(reconstructions_binned_cs{i}), 'k');
    
    title(['Subject ', ID_nums{i}, ' - cs'], 'FontSize', 18);
    xlabel('Bin #', 'FontSize', 16)
    xlim([1, config.n_bins]);

end

title(t, 'Binned reconstructions', 'FontSize', 18);

% Unbinned
figure;
t = tiledlayout(rows, cols);

for i = 1:length(config_files)
    % Linear
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile([1,2])
    else
        nexttile
    end

    recon_binrep = rescale(reconstructions_binned_lr{i}, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);

    freqs = linspace(1, floor(Fs/2), length(recon_spectrum))'; % ACL
    indices_to_plot = freqs(:, 1) <= config.max_freq;

    unbinned_lr = stimgen.binnedrepr2spect(reconstructions_binned_lr{i});
    unbinned_lr(unbinned_lr == 0) = NaN;

    plot(1e-3 * freqs(indices_to_plot, 1), my_normalize(unbinned_lr(indices_to_plot)), 'k');
    title(['Subject ', ID_nums{i}, ' - linear'], 'FontSize', 18);
    xlabel('Frequency (kHz)', 'FontSize', 16)
    xlim([0, 1e-3 * config.max_freq]);

    if ismember(i, label_y)
        ylabel({'Standardized'; 'Amplitude'}, 'FontSize', 14);
    end

    % CS
    if i == length(config_files) && mod(length(config_files), 2)
        nexttile([1,2])
    else
        nexttile
    end

    recon_binrep = rescale(reconstructions_binned_cs{i}, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);

    freqs = linspace(1, floor(Fs/2), length(recon_spectrum))'; % ACL
    indices_to_plot = freqs(:, 1) <= config.max_freq;

    unbinned_cs = stimgen.binnedrepr2spect(reconstructions_binned_cs{i});
    unbinned_cs(unbinned_cs == 0) = NaN;

    plot(1e-3 * freqs(indices_to_plot, 1), my_normalize(unbinned_cs(indices_to_plot)), 'k');

    title(['Subject ', ID_nums{i}, ' - cs'], 'FontSize', 18);
    xlabel('Frequency (kHz)', 'FontSize', 16)
    xlim([0, 1e-3 * config.max_freq]);
end

title(t, 'Unbinned reconstructions', 'FontSize', 18);







