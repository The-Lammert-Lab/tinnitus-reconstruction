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

ax = plot_violin(T2, 'N', 10, 'parallel', false);

figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2, 'AxisBox', 'off', 'YMinorTicks', 'on');
axlib.equalize(ax(:), 'x', 'y');
% figlib.tight();
figlib.label('XOffset', 0.01, 'YOffset', -0.03, 'FontSize', 36);

