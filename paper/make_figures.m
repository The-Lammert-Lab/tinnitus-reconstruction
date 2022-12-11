%% Make figures for the main paper

% Set rng seed
rng(112358, 'twister');

%% Collect and analyze the data

% Run the collection and analysis script (run the following line)
% pilot_reconstructions

% Table with only data to show in the paper

T2 = T(T.n_bins == 8, :);
summary(T2);

%% Violin plots with buzzing and roaring 

[ax, data_container] = plot_violin(T2, 'N', 1000, 'parallel', false);

figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
axlib.equalize(ax(:), 'x', 'y');
% figlib.tight();
figlib.label('XOffset', -0.01, 'YOffset', 0.03, 'FontSize', 36);

%% Bar with error for bootstrapped r-values

fig2 = new_figure();
T2 = sortrows(T2, ["subject_ID", "r_bootstrap_lr_mean_1"]);
errs = [table2array(T2(strcmp(T2.target_signal_name, 'buzzing'), "r_bootstrap_lr_std_1")), ...
        table2array(T2(strcmp(T2.target_signal_name, 'roaring'), "r_bootstrap_lr_std_1"))];
vals = [table2array(T2(strcmp(T2.target_signal_name, 'buzzing'), "r_bootstrap_lr_mean_1")), ...
        table2array(T2(strcmp(T2.target_signal_name, 'roaring'), "r_bootstrap_lr_mean_1"))];
plotlib.barwitherr(errs, vals);
xlabel('subject #')
ylabel('Pearson''s r')
legend({'buzzing', 'roaring'})
figlib.pretty('FontSize', 36, 'PlotBuffer', 0.1, 'AxisBox', 'off', 'YMinorTicks', 'on');