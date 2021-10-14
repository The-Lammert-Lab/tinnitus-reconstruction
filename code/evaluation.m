% What is the best gamma value for reconstruction
% based on reconstruction using DCT?

% Get the true spectrum
[repr_true, frequencies_true] = wav2spect('/home/alec/data/sounds/ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav');

% sorted coefficients of the discrete cosine transform
% of the true representation (the tinnitus waveform)
coefficients = dct(repr_true);
[~, coefficient_indices] = sort(abs(coefficients), 'descend');

% how many coefficients to keep
n_coeffs = round(logspace(0, log10(length(coefficient_indices)/10), 50));

% container for correlation coefficients
correlations = zeros(length(n_coeffs), 1);

% compute reconstructions using only n coefficients from the dct
for ii = 1:length(correlations)
    coeffs_ = coefficients;
    % set all coefficients except for the first n to zero
    coeffs_(coefficient_indices(n_coeffs(ii)+1:end)) = 0;
    % compute the correlation between the true representation (all coefficients)
    % and the sparse representation in the time domain (using only n coefficients)
    correlations(ii) = corr(repr_true, idct(coeffs_));
end

fig = figure;
plot(n_coeffs, correlations)
xlabel('n coefficients kept')
ylabel('r^2')
title('correlation as a function of dct coefficients')
figlib.pretty()



return

% Evaluate the reconstructions for the pilot data

CONFIG_REL_PATH = 'experiment/configs/config.yaml';
config = ReadYaml(CONFIG_REL_PATH);

% Collect the data from the data files
[responses, stimuli] = collect_data('config', CONFIG_REL_PATH);

% Get the spectrum in dB
spect = signal2spect(stimuli);

% Get the frequencies for the x-axis of the reconstructions
frequencies_est = 1e-3 * linspace(config.min_freq, config.max_freq, length(spect));

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