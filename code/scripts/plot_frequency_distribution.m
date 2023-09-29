%% Plot the frequency distribution
% of a sample of stimuli.


%% Uniform Prior

stimgen = UniformPriorStimulusGeneration();
stimgen.n_trials = 10000;
stimgen.min_bins = 30;
stimgen.max_bins = 30;
stimgen.max_freq = 13e3;

% Compute the spectra
[~, ~, spect_matrix, ~] = stimgen.generate_stimuli_matrix();

% Count the filled bins
filled_freqs = spect_matrix == 0;
freq_counts = mean(filled_freqs, 2);

freq_vec = linspace(stimgen.min_freq, 22e3, stimgen.nfft() / 2);

fig1 = new_figure();

ax(1) = subplot(2, 1, 1);
stem(ax(1), 1e-3 * freq_vec, freq_counts);
xlabel(ax(1), 'frequency (kHz)')
ylabel(ax(1), 'fill probability')
ylim(ax(1), [-0.05, 1.05])
title('Uniform Prior Uniform Sampling')

%% Uniform Prior Weighted Samping

stimgen = UniformPriorWeightedSamplingStimulusGeneration();
stimgen.n_trials = 10000;
stimgen.min_bins = 30;
stimgen.max_bins = 30;
stimgen.max_freq = 13e3;

[~, ~, spect_matrix, ~] = stimgen.generate_stimuli_matrix();

filled_freqs = spect_matrix == 0;
freq_counts = mean(filled_freqs, 2);

freq_vec = linspace(stimgen.min_freq, 22e3, stimgen.nfft() / 2);

ax(2) = subplot(2, 1, 2);
stem(ax(2), 1e-3 * freq_vec, freq_counts);
xlabel(ax(2), 'frequency (kHz)')
ylabel(ax(2), 'fill probability')
ylim(ax(2), [-0.05, 1.05])
title('Uniform Prior Weighted Sampling')

figlib.pretty();