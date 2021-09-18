% Evaluate the reconstructions for the pilot data

CONFIG_REL_PATH = 'experiment/configs/config.yaml';
config = ReadYaml(CONFIG_REL_PATH);

% Collect the data from the data files
[responses, stimuli] = collect_data('config', CONFIG_REL_PATH);


% Get the true spectrum
[repr_true, frequencies_true] = wav2spect('/home/alec/data/sounds/ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav');

% Get the spectrum in dB
spect = 10*log10(abs(fft(stimuli)));
spect = spect(1:floor(end/2), :);

% Get the frequencies for the x-axis of the reconstructions
frequencies_est = 1e-3 * linspace(config.min_freq, config.max_freq, length(spect));

% Reverse Correlation
s_revcorr = 1 / (size(spect, 1)) * spect * responses;

% Compressed Sensing, with basis
[x_cs, s_cs] = cs(responses, spect');

% Compressed Sensing, no basis
[x_cs_nb, s_cs_nb] = cs_no_basis(responses, spect');

% Plotting
figure;
n_plots = 4;
for ii = n_plots:-1:1
    ax(ii) = subplot(n_plots, 1, ii);
end

% true spectrum
plot(ax(1), 1e-3 * frequencies_true, 10*log10(repr_true));
xlabel('frequency (kHz)')
ylabel('power (dB)')

% reverse correlation
plot(ax(2), frequencies_est, s_revcorr);

% compressed sensing, with basis
plot(ax(3), frequencies_est, s_cs);

% compressed sensing, no basis
plot(ax(4), frequencies_est, s_cs_nb);
xlabel('frequency (kHz)')

figlib.pretty()

% Gamma hyperparameter

gammas = [1, 32, 64, 128, 256, 512];

s_matrix = zeros(size(spect, 1), length(gammas));

for ii = 1:length(gammas)
    [~, s_matrix(:, ii)] = cs_no_basis(responses, spect', gammas(ii));
end

figure;
plot(frequencies_est, s_matrix);

leg = cell(length(gammas), 1);
for ii = 1:length(leg)
    leg{ii} = ['Gamma = ', num2str(gammas(ii))];
end

legend(leg)