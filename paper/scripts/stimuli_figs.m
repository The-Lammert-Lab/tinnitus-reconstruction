
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data';
n = 3;
my_normalize = @(x) normalize(x, 'zscore', 'std');
linewidth = 6;
fontweight = 'bold';
light_color = [1, 1, 1];
dark_color = [0.898, 0.898, 0.898];

config = parse_config(pathlib.join(data_dir, '5_config_JM.yaml'));
[responses, stimuli_matrix] = collect_data('config', config, 'verbose', false, 'data_dir', data_dir);
stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
stimgen = stimgen.from_config(config);

stim_mat_yes = stimuli_matrix(:, responses == 1);
stim_mat_no = stimuli_matrix(:, responses == -1);

plot_yes = stim_mat_yes(:, randi([1, length(stim_mat_yes)], n, 1));
plot_no = stim_mat_no(:, randi([1, length(stim_mat_no)], n, 1));

fig_yes = figure('Name', 'Yes');
fig_no = figure('Name', 'No');
t_yes = tiledlayout(fig_yes,n,2);
t_no = tiledlayout(fig_no,n,2);

for i = 1:n
    spectrum = stimgen.binnedrepr2spect(plot_yes(:,i));
    freqs = linspace(1, floor(stimgen.Fs/2), length(spectrum))';
    indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;
    unbinned = stimgen.binnedrepr2spect(plot_yes(:,i));
    
    nexttile(t_yes);
    plot(freqs(indices_to_plot,1), unbinned(indices_to_plot), 'LineWidth', linewidth)
    color = get(gca,'Color');
    set(gca, 'XTickLabels', [], ...
        'YTickLabels', [], 'TickLength', [0,0], ...
        'XLim', [stimgen.min_freq, stimgen.max_freq], ...
        'XColor', light_color, 'YColor', light_color)

    nexttile(t_yes);
    plot(plot_yes(:,i), 'LineWidth', linewidth);
    set(gca, 'XTickLabels', [], 'YTickLabels', [], ...
        'TickLength', [0,0], 'XLim', [1, stimgen.n_bins], ...
        'color', dark_color, 'XColor', dark_color, 'YColor', dark_color)

    spectrum = stimgen.binnedrepr2spect(plot_no(:,i));
    freqs = linspace(1, floor(stimgen.Fs/2), length(spectrum))';
    indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;
    unbinned = stimgen.binnedrepr2spect(plot_no(:,i));

    nexttile(t_no);
    plot(freqs(indices_to_plot,1), unbinned(indices_to_plot), 'LineWidth', linewidth)
    set(gca, 'XTickLabels', [], ...
        'YTickLabels', [], 'TickLength', [0,0], ...
        'XLim', [stimgen.min_freq, stimgen.max_freq], ...
        'XColor', light_color, 'YColor', light_color)

    nexttile(t_no);
    plot(plot_no(:,i), 'LineWidth', linewidth);
    set(gca, 'XTickLabels', [], 'YTickLabels', [], ...
        'TickLength', [0,0], 'XLim', [1, stimgen.n_bins], ...
        'color', dark_color, 'XColor', dark_color, 'YColor', dark_color)
end
