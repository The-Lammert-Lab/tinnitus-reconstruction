%% Make figures for the main paper

% DATA_DIR = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper';

% Set rng seed
rng(112358, 'twister');

%% Collect and analyze the data

% Run the collection and analysis script (run the following line)
% pilot_reconstructions

% Table with only data to show in the paper

T2 = T(T.n_bins == 8, :);
summary(T2);

%% Violin plots with buzzing and roaring 

% [ax, data_container] = plot_violin(T2, 'N', 1000, 'parallel', false);

% figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
% axlib.equalize(ax(:), 'x', 'y');
% % figlib.tight();
% figlib.label('XOffset', -0.01, 'YOffset', 0.03, 'FontSize', 36);

%% Reconstructions

% How many exemplars to plot
n_traces = 3;

% Colors
cmap = colormaps.linspecer(n_traces);

% Sort the dataset by r-value
T3 = sortrows(T2, ["r_lr_bins_1", "subject_ID"], "descend");
T3_buzzing = T3(strcmp(T3.target_signal_name, 'buzzing'), :);
T3_roaring = T3(strcmp(T3.target_signal_name, 'roaring'), :);

% Create a stimgen object for binning and unbinning
config = parse_config(pathlib.join(DATA_DIR, T3.config_filename{1}));
stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
stimgen = stimgen.from_config(config);

% target_signal is the non-binned spectra of the target signals
% this_binned_target_signal is the binned representation of the target signals
this_binned_target_signal = stimgen.spect2binnedrepr(target_signal);

% my_normalize = @(x) normalize(x, 'zscore', 'std');
% This normalization scheme normalizes the vectors to a length of 1
% since we cannot capture magnitude information in the reconstruction.
% Do we need to center the vectors afterwards?
% my_normalize = @(x) normalize(normalize(x, 'norm'), 'center');
my_normalize = @(x) normalize(x, 'norm');


% Generate a figure and axes
fig2 = new_figure();

counter = 0;
for ii = 1:2
    for qq = 1:2
        counter = counter + 1;
        ax(ii, qq) = subplot(2, 2, counter);
        hold on;
    end
end

%% Buzzing, binned representation
axes(ax(1, 1));
% Plot the binned buzzing in black
binned_buzzing = this_binned_target_signal(:, strcmp(data_names, 'buzzing'));
plot(ax(1, 1), my_normalize(binned_buzzing), 'k');
% Plot the binned reconstructions in colors
for ii = 1:n_traces
    this_reconstruction = T3_buzzing.reconstructions_lr_1{ii};
    p = plot(ax(1, 1), my_normalize(this_reconstruction), 'Color', cmap(ii, :));
    p.Color(4) = 0.8;
end
xlabel(ax(1, 1), 'bins');
ylabel(ax(1, 1), 'amplitude (a.u.)');
title(ax(1, 1), 'buzzing, binned')
legend(ax(1, 1), {'ground truth', 'subject #1', 'subject #2', 'subject #3'})

%% Roaring, binned representation
axes(ax(1, 2));
% Plot the binned roaring in black
binned_roaring = this_binned_target_signal(:, strcmp(data_names, 'roaring'));
plot(ax(1, 2), my_normalize(binned_roaring), 'k');
% Plot the binned reconstructions in colors
for ii = 1:n_traces
    this_reconstruction = T3_roaring.reconstructions_lr_1{ii};
    p = plot(ax(1, 2), my_normalize(this_reconstruction), 'Color', cmap(ii, :));
    p.Color(4) = 0.8;
end
xlabel(ax(1, 2), 'bins');
title('roaring, binned')
legend(ax(1, 2), {'ground truth', 'subject #1', 'subject #2', 'subject #3'})

%% Buzzing, full spectra
% "unbinned" means it was binned and then unbinned.
% "non-binned" means it was never binned.

axes(ax(2, 1));
buzzing = target_signal(:, strcmp(data_names, 'buzzing'));
unbinned_buzzing = stimgen.binnedrepr2spect(binned_buzzing);
indices_to_plot = f(:, 1) <= stimgen.max_freq;
% Plot the true, non-binned spectrum in grayscale
p = plot(ax(2, 1), 1e-3 * f(indices_to_plot, 1), my_normalize(buzzing(indices_to_plot)), 'k');
p.Color(4) = 0.3;
% Plot the unbinned spectrum in black
plot(ax(2, 1), 1e-3 * f(indices_to_plot, 1), my_normalize(unbinned_buzzing(indices_to_plot)), '-k', 'LineWidth', 3);
% Plot the unbinned reconstructions in colors
for ii = 1:n_traces
    this_reconstruction = T3_buzzing.reconstructions_lr_1{ii};
    unbinned_this_reconstruction = stimgen.binnedrepr2spect(this_reconstruction);
    p = plot(ax(2, 1), 1e-3 * f(indices_to_plot, 1), my_normalize(unbinned_this_reconstruction(indices_to_plot)), 'Color', cmap(ii, :));
    p.Color(4) = 0.8;
end
xlabel(ax(2, 1), 'frequency (kHz)')
ylabel(ax(2, 1), 'amplitude (a.u.)');
title(ax(2, 1), 'buzzing, spectra')
legend(ax(2, 1), {'ground truth', 'bin-transformed g.t.' 'subject #1', 'subject #2', 'subject #3'})


%% Roaring, full spectra

axes(ax(2, 2));
roaring = target_signal(:, strcmp(data_names, 'roaring'));
unbinned_roaring = stimgen.binnedrepr2spect(binned_roaring);
indices_to_plot = f(:, 1) <= stimgen.max_freq;
% Plot the true, non-binned spectrum in grayscale
p = plot(ax(2, 2), 1e-3 * f(indices_to_plot, 1), my_normalize(roaring(indices_to_plot)), 'k');
p.Color(4) = 0.3;
% Plot the unbinned spectrum in black
plot(ax(2, 2), 1e-3 * f(indices_to_plot, 1), my_normalize(unbinned_roaring(indices_to_plot)), '-k', 'LineWidth', 3);
% Plot the unbinned reconstructions in colors
for ii = 1:n_traces
    this_reconstruction = T3_roaring.reconstructions_lr_1{ii};
    unbinned_this_reconstruction = stimgen.binnedrepr2spect(this_reconstruction);
    p = plot(ax(2, 2), 1e-3 * f(indices_to_plot, 1), my_normalize(unbinned_this_reconstruction(indices_to_plot)), 'Color', cmap(ii, :));
    p.Color(4) = 0.8;
end
xlabel(ax(2, 2), 'frequency (kHz)')
ylabel(ax(2, 2), 'amplitude (a.u.)');
title(ax(2, 2), 'roaring, spectra')
legend(ax(2, 2), {'ground truth', 'bin-transformed g.t.' 'subject #1', 'subject #2', 'subject #3'})


figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
axlib.equalize(ax(1, 1:2), 'x', 'y');
% axlib.equalize(ax(2, 1:2), 'x', 'y');
figlib.label('XOffset', -0.01, 'YOffset', 0.03, 'FontSize', 36);


% ylabel(ax(1, 2), 'amplitude (a.u.)');

% for ii = 2:-1:1
%     ax(ii) = subplot(2, 1, ii);
%     hold on;
% end

% T3 = sortrows(T2, "r_lr_bins_1", 'descend');
% n_traces = 3;

% % buzzing
% plot(ax(1), 1e-3 * f(:, 1), normalize(target_signal(:, strcmp(data_names, 'buzzing'))), 'k')
% data_to_plot = [T3(strcmp(T3.target_signal_name, 'buzzing'), :).reconstructions_lr_1{:}]';
% cmap = colormaps.linspecer(n_traces);
% for ii = 1:n_traces
%     plt = plot(ax(1), 1e-3 * f(:, 1), normalize(stimgen.binnedrepr2spect(data_to_plot(:, ii))), 'Color', cmap(ii, :));
%     plt.Color(4) = 0.8;
% end

% % roaring
% plot(ax(2), 1e-3 * f(:, 1), normalize(target_signal(:, strcmp(data_names, 'roaring'))), 'k')

% data_to_plot = [T3(strcmp(T3.target_signal_name, 'roaring'), :).reconstructions_lr_1{:}]';
% cmap = colormaps.linspecer(n_traces);
% for ii = 1:n_traces
%     plt = plot(ax(2), 1e-3 * f(:, 1), normalize(stimgen.binnedrepr2spect(data_to_plot(:, ii))), 'Color', cmap(ii, :));
%     plt.Color(4) = 0.8;
% end

% xlabel(ax(2), 'frequency (kHz)')
% ylabel(ax(1), 'amplitude (a.u.)')
% ylabel(ax(2), 'amplitude (a.u.)')

% figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
% axlib.equalize(ax(:), 'x', 'y');
% % figlib.tight();
% figlib.label('XOffset', -0.01, 'YOffset', 0., 'FontSize', 36);


% fig2 = new_figure();
% T2 = sortrows(T2, ["subject_ID", "r_bootstrap_lr_mean_1"]);
% errs = [table2array(T2(strcmp(T2.target_signal_name, 'buzzing'), "r_bootstrap_lr_std_1")), ...
%         table2array(T2(strcmp(T2.target_signal_name, 'roaring'), "r_bootstrap_lr_std_1"))];
% vals = [table2array(T2(strcmp(T2.target_signal_name, 'buzzing'), "r_bootstrap_lr_mean_1")), ...
%         table2array(T2(strcmp(T2.target_signal_name, 'roaring'), "r_bootstrap_lr_mean_1"))];
% plotlib.barwitherr(errs, vals);
% xlabel('subject #')
% ylabel('Pearson''s r')
% legend({'buzzing', 'roaring'})
% figlib.pretty('FontSize', 36, 'PlotBuffer', 0.1, 'AxisBox', 'off', 'YMinorTicks', 'on');