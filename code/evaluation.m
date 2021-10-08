% Evaluate the reconstructions for the pilot data

%% Preliminaries

CONFIG_REL_PATH = 'experiment/configs/config.yaml';
config = ReadYaml(CONFIG_REL_PATH);

% Collect the data from the data files
[responses, stimuli] = collect_data('config', CONFIG_REL_PATH);

% Get the true spectrum
[repr_true, frequencies_true] = wav2spect('/home/alec/data/sounds/ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav');

% Get the spectrum in dB
spect = signal2spect(stimuli);

% Get the frequencies for the x-axis of the reconstructions
frequencies_est = 1e-3 * (1:2:2*size(spect, 1));

%% Evaluate the quality of reconstructions
% using k dct coefficients

% Compute the discrete cosine transform
dct_coeffs = dct(repr_true);

% Sort the coefficients by absolute value
[sorted_coeffs, sorted_coeffs_indices] = sort(abs(dct_coeffs), 'descend');

% How many coefficients to keep?
k_coeffs_to_keep = round(logspace(0, log10(length(sorted_coeffs)/10), 11));

% Keep k coefficients, inverse transform back
% then look at r2
r2 = zeros(size(k_coeffs_to_keep));
for ii = 1:length(k_coeffs_to_keep)
    these_coeffs = zeros(size(dct_coeffs));
    these_coeffs(sorted_coeffs_indices(1:k_coeffs_to_keep(ii))) = dct_coeffs(sorted_coeffs_indices(1:k_coeffs_to_keep(ii)));
    nnz(these_coeffs)
    r2(ii) = corr(repr_true, idct(these_coeffs));
end

% Plot r2 as a function of number of kept coefficients
fig = figure;
scatter(k_coeffs_to_keep / length(dct_coeffs), r2)
xlabel('fraction of kept coefficients')
ylabel('r^2')
figlib.pretty()

% Reverse Correlation
x_revcorr = 1 / (size(spect, 1)) * spect * responses;

% Compressed Sensing, with basis
x_cs = cs(responses, spect', 100);

% Compressed Sensing, no basis
x_cs_nb = cs_no_basis(responses, spect', 100);

% Plotting
fig1 = figure;
n_plots = 4;
for ii = n_plots:-1:1
    ax(ii) = subplot(n_plots, 1, ii);
end

% true spectrum
plot(ax(1), 1e-3 * frequencies_true, 10*log10(repr_true));
xlabel('frequency (kHz)')
ylabel('power (dB)')

% reverse correlation
plot(ax(2), frequencies_est, x_revcorr);

% compressed sensing, with basis
plot(ax(3), frequencies_est, x_cs);

% compressed sensing, no basis
plot(ax(4), frequencies_est, x_cs_nb);
xlabel('frequency (kHz)')

figlib.pretty()

% Binary representation

spect_binarized = spect2bin(spect, ...
    'min_freq', config.min_freq, ...
    'max_freq', config.max_freq, ...
    'n_bins', config.n_bins, ...
    'bin_duration', config.bin_duration, ...
    'n_bins_filled_mean', config.n_bins_filled_mean, ...
    'n_bins_filled_var', config.n_bins_filled_var);

% Reverse Correlation
spect_revcorr_binarized = 1 / (size(spect, 1)) * spect_binarized * responses;
x_revcorr_binarized = bin2spect(...
    spect_revcorr_binarized, ...
    'min_freq', config.min_freq, ...
    'max_freq', config.max_freq, ...
    'n_bins', config.n_bins, ...
    'bin_duration', config.bin_duration, ...
    'n_bins_filled_mean', config.n_bins_filled_mean, ...
    'n_bins_filled_var', config.n_bins_filled_var);
s_revcorr_binarized = signal2spect(x_revcorr_binarized);

% Compressed Sensing, with basis
spect_cs_binarized = cs(responses, spect_binarized', 100);
x_cs_binarized = bin2spect(...
    spect_cs_binarized, ...
    'min_freq', config.min_freq, ...
    'max_freq', config.max_freq, ...
    'n_bins', config.n_bins, ...
    'bin_duration', config.bin_duration, ...
    'n_bins_filled_mean', config.n_bins_filled_mean, ...
    'n_bins_filled_var', config.n_bins_filled_var);
s_cs_binarized = signal2spect(x_cs_binarized);

% Compressed Sensing, no basis
spect_cs_nb_binarized = cs_no_basis(responses, spect_binarized', 100);
x_cs_nb_binarized = bin2spect(...
    spect_cs_nb_binarized, ...
    'min_freq', config.min_freq, ...
    'max_freq', config.max_freq, ...
    'n_bins', config.n_bins, ...
    'bin_duration', config.bin_duration, ...
    'n_bins_filled_mean', config.n_bins_filled_mean, ...
    'n_bins_filled_var', config.n_bins_filled_var);
s_cs_nb_binarized = signal2spect(x_cs_nb_binarized);

% Plotting
fig2 = figure;
n_plots = 4;
for ii = n_plots:-1:1
    ax(ii) = subplot(n_plots, 1, ii);
end

% true spectrum
plot(ax(1), 1e-3 * frequencies_true, 10*log10(repr_true));
xlabel('frequency (kHz)')
ylabel('power (dB)')

% reverse correlation
plot(ax(2), frequencies_est, s_revcorr_binarized);

% compressed sensing, with basis
plot(ax(3), frequencies_est, s_cs_binarized);

% compressed sensing, no basis
plot(ax(4), frequencies_est, s_cs_nb_binarized);
xlabel('frequency (kHz)')

figlib.pretty()

return
% Gamma hyperparameter

gammas = [1, 32, 64, 128, 256, 512];

s_matrix = zeros(size(spect, 1), length(gammas));

for ii = 1:length(gammas)
    [~, s_matrix(:, ii)] = cs_no_basis(responses, spect', gammas(ii));
end

fig3 = figure;
plot(frequencies_est, s_matrix);

leg = cell(length(gammas), 1);
for ii = 1:length(leg)
    leg{ii} = ['Gamma = ', num2str(gammas(ii))];
end

legend(leg)