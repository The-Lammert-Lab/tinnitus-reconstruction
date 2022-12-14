%% Make figures for the main paper

DATA_DIR = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper';

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

%% Bar with error for bootstrapped r-values

config = parse_config(pathlib.join(DATA_DIR, T2.config_filename{1}));
stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
stimgen = stimgen.from_config(config);

fig2 = new_figure();

for ii = 2:-1:1
    ax(ii) = subplot(2, 1, ii);
    hold on;
end

T3 = sortrows(T2, "r_lr_bins_1", 'descend');
n_traces = 3;

% buzzing
plot(ax(1), 1e-3 * f(:, 1), normalize(target_signal(:, strcmp(data_names, 'buzzing'))), 'k')
data_to_plot = [T3(strcmp(T3.target_signal_name, 'buzzing'), :).reconstructions_lr_1{:}]';
cmap = colormaps.linspecer(n_traces);
for ii = 1:n_traces
    plt = plot(ax(1), 1e-3 * f(:, 1), normalize(stimgen.binnedrepr2spect(data_to_plot(:, ii))), 'Color', cmap(ii, :));
    plt.Color(4) = 0.8;
end

% roaring
plot(ax(2), 1e-3 * f(:, 1), normalize(target_signal(:, strcmp(data_names, 'roaring'))), 'k')

data_to_plot = [T3(strcmp(T3.target_signal_name, 'roaring'), :).reconstructions_lr_1{:}]';
cmap = colormaps.linspecer(n_traces);
for ii = 1:n_traces
    plt = plot(ax(2), 1e-3 * f(:, 1), normalize(stimgen.binnedrepr2spect(data_to_plot(:, ii))), 'Color', cmap(ii, :));
    plt.Color(4) = 0.8;
end

xlabel(ax(2), 'frequency (kHz)')
ylabel(ax(1), 'amplitude (a.u.)')
ylabel(ax(2), 'amplitude (a.u.)')

figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
axlib.equalize(ax(:), 'x', 'y');
% figlib.tight();
figlib.label('XOffset', -0.01, 'YOffset', 0., 'FontSize', 36);


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