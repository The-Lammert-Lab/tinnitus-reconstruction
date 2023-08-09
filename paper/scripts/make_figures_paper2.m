% Reconstruct and visualize patient tinnitus

%% General setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';
config_files = dir(pathlib.join(data_dir, '*.yaml'));

% Script parameters
CS = false;
verbose = true;
skip_subjects = {'KE_6'};

% Fields to keep for comparing configs
keep_fields = {'n_trials_per_block', 'n_blocks', 'total_trials', ...
    'min_freq', 'max_freq', 'duration', 'n_bins', 'stimuli_type', ...
    'min_bins', 'max_bins'};

n = length(config_files);

%% Plot setup
rows = ceil(n/2);

if CS
    cols = 4;
else
    cols = 2;
end

label_y = 1:cols:rows*cols;

linewidth = 1.5;
linecolor = 'k';

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
    
    if all(ismember(config.subject_ID, skip_subjects))
        continue
    end

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

    two_col = i == n-length(skip_subjects);

    %%%%% Binned %%%%%

    plot_binned(t_binned, my_normalize(reconstruction_binned_lr), ...
        config.n_bins, two_col, ...
        linewidth, linecolor)

    % CS
    if CS
        plot_binned(t_binned, my_normalize(reconstruction_binned_cs), ...
            config.n_bins, two_col, ...
            linewidth, linecolor)
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

    % Unbin
    [unbinned_lr, indices_to_plot, freqs] = unbin(reconstruction_binned_lr, stimgen, config.max_freq, config.min_freq);
    
    plot_unbinned(t_unbinned, freqs(indices_to_plot,1), ...
        my_normalize(unbinned_lr(indices_to_plot)), ...
        config.max_freq, two_col, ...
        linewidth, linecolor)

    % CS
    if CS
        % Unbin
        [unbinned_cs, indices_to_plot, freqs] = unbin(reconstruction_binned_cs, stimgen, config.max_freq, config.min_freq);
        
        plot_unbinned(t_unbinned, freqs(indices_to_plot,1), ...
            my_normalize(unbinned_cs(indices_to_plot)), ...
            config.max_freq, two_col, ...
            linewidth, linecolor)
    end
end

% figlib.pretty(f_unbinned, 'FontSize', 20, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
% figlib.pretty(f_binned, 'FontSize', 20, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');

%% Local functions
function [unbinned_recon, indices_to_plot, freqs] = unbin(binned_recon, stimgen, max_freq, min_freq)
    recon_binrep = rescale(binned_recon, -20, 0);
    recon_spectrum = stimgen.binnedrepr2spect(recon_binrep);
    
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spectrum))';
    indices_to_plot = freqs(:,1) <= max_freq & freqs(:,1) >= min_freq;
    
    unbinned_recon = stimgen.binnedrepr2spect(binned_recon);
    unbinned_recon(unbinned_recon == 0) = NaN;
end

function plot_binned(ax, data, n_bins, two_col, linewidth, linecolor)
    rows = ax.GridSize(1);
    cols = ax.GridSize(2);
    label_y = 1:cols:rows*cols;

    % Linear
    if two_col
        tile = nexttile(ax, [1,2]);
        tile_num = tilenum(tile);
    else
        tile = nexttile(ax);
        tile_num = tilenum(tile);
    end

    plot(data, linecolor, ...
        'LineWidth', linewidth);

    xlim([1, n_bins]);

    % Label only last row
    if tile_num >= rows*(cols-1)
        xlabel('Bin #', 'FontSize', 16)
    end

    % Label start of each row
    if ismember(tile_num, label_y)
        ylabel('Power (dB)', 'FontSize', 16);
    end

%     set(gca, 'yticklabels', [], 'FontWeight', 'bold')
    set(gca, 'ylim', [-3, 3], 'FontWeight', 'bold')
end

function plot_unbinned(ax, x, y, max_freq, two_col, linewidth, linecolor)
    rows = ax.GridSize(1);
    cols = ax.GridSize(2);
    label_y = 1:cols:rows*cols;

    % Linear
    if two_col
        tile = nexttile(ax, [1,2]);
        tile_num = tilenum(tile);
    else
        tile = nexttile(ax);
        tile_num = tilenum(tile);
    end

    plot(x, y, ...
        linecolor, 'LineWidth', linewidth);

    xlim([0, max_freq]);

        % Label only last row
    if tile_num >= rows*(cols-1)
        xlabel('Frequency (Hz)', 'FontSize', 16)
    end

    % Label start of each row
    if ismember(tile_num, label_y)
        ylabel('Power (dB)', 'FontSize', 16);
    end

%     set(gca, 'yticklabels', [], 'FontWeight', 'bold')
    set(gca, 'ylim', [-3, 3], 'FontWeight', 'bold')
end
