% Reconstruct and visualize patient tinnitus

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';
config_files = dir(pathlib.join(data_dir, '*.yaml'));

% Script parameters
CS = false;
verbose = true;
skip_subjects = {'1', '2', '3', '6'};

% Fields to keep for comparing configs
keep_fields = {'n_trials_per_block', 'n_blocks', 'total_trials', ...
    'min_freq', 'max_freq', 'duration', 'n_bins', 'stimuli_type', ...
    'min_bins', 'max_bins'};

n = length(config_files);

%% Plot setup
rows = n - length(skip_subjects);

if CS
    cols = 2;
else
    cols = 1;
end

fontsize = 32;
ticksize = 20;
linewidth = 3;
linecolor = 'k';

my_normalize = @(x) normalize(x, 'zscore', 'std');  

% Figs
f_binned = figure;
t_binned = tiledlayout(f_binned, rows, cols, 'TileSpacing','compact');

f_unbinned = figure;
t_unbinned = tiledlayout(f_unbinned, rows, cols, 'TileSpacing','compact');

%% Loop and plot
for i = 1:n
    %%%%% Get data %%%%%
    config = parse_config(pathlib.join(config_files(i).folder, config_files(i).name));
    
    % Only create on first iteration since they're all the same.
    if i == 1
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    end

    % Skip config files with target signals (healthy controls) or in
    % skip_subjcts
    if contains(config.subject_ID, skip_subjects) || ...
        (isfield(config, 'target_signal') && ~isempty(config.target_signal))
        continue
    end

    % Get subject ID number 
    ID_num = extractAfter(config.subject_ID, '_');
    if isempty(ID_num)
        ID_num = '???';
    end

    % Get reconstructions
    reconstruction_binned_lr = get_reconstruction('config', config, ...
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
    tile_binned = nexttile(t_binned);
    plot(my_normalize(reconstruction_binned_lr), linecolor, 'LineWidth', linewidth)
    xlim([1, config.n_bins])
%     set(tile_binned, 'ylim', [-3, 3], 'FontWeight', 'bold', 'FontSize', ticksize)
    set(tile_binned, 'FontWeight', 'bold', 'FontSize', ticksize, 'XTickLabels', [])
    ylabel('Power (dB)', 'FontSize', fontsize)

    % CS
    if CS
        tile_binned_cs = nexttile(t_binned);
        plot(my_normalize(reconstruction_binned_cs), linecolor, 'LineWidth', linewidth)
        xlim([1, config.n_bins])
%         set(gca, 'ylim', [-3, 3], 'FontWeight', 'bold', 'FontSize', ticksize)
        set(tile_binned_cs, 'XTickLabels', [], 'FontWeight', 'bold', 'FontSize', ticksize)
    end
 
    %%%%% Unbinned %%%%%
    % Unbin
    [unbinned_lr, indices_to_plot, freqs] = unbin(reconstruction_binned_lr, stimgen, config.max_freq, config.min_freq);

    tile_unbinned = nexttile(t_unbinned);
    plot(freqs(indices_to_plot,1), my_normalize(unbinned_lr(indices_to_plot)), linecolor, 'LineWidth', linewidth)
    xlim([1, config.max_freq])
%     set(tile_unbinned, 'ylim', [-3, 3], 'FontWeight', 'bold', 'FontSize', ticksize)
    set(tile_unbinned, 'FontWeight', 'bold', 'FontSize', ticksize, 'XTickLabels', [])
    ylabel('Power (dB)', 'FontSize', fontsize)

    % CS
    if CS
        % Unbin
        [unbinned_cs, indices_to_plot, freqs] = unbin(reconstruction_binned_cs, stimgen, config.max_freq, config.min_freq);

        tile_unbinned_cs = nexttile(t_unbinned);
        plot(freqs(indices_to_plot,1), my_normalize(unbinned_cs(indices_to_plot)), linecolor, 'LineWidth', linewidth)
        xlim([1, config.max_freq])
%         set(tile_unbinned_cs, 'ylim', [-5, 3], 'FontWeight', 'bold', 'FontSize', ticksize, 'XTickLabels', [])
        set(tile_unbinned_cs, 'ylim', [-5, 3], 'FontWeight', 'bold', 'FontSize', ticksize, 'XTickLabels', [])
    end
end

xticklabels(tile_unbinned, 'auto');
xticklabels(tile_binned, 'auto');
xlabel(tile_unbinned, 'Frequency (Hz)', 'FontSize', fontsize, 'FontWeight', 'bold')
xlabel(tile_binned, 'Bin #', 'FontSize', fontsize, 'FontWeight', 'bold')

if CS
    xticklabels(tile_binned_cs, 'auto');
    xticklabels(tile_unbinned_cs, 'auto');
    xlabel(tile_binned_cs, 'Bin #', 'FontSize', fontsize, 'FontWeight', 'bold')
    xlabel(tile_unbinned_cs, 'Frequency (Hz)', 'FontSize', fontsize, 'FontWeight', 'bold')
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
