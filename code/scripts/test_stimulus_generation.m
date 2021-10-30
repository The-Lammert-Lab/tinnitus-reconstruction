%% Test Stimulus Generation
% Test three types of stimulus generation: Brimijoin, our custom one, and white noise.
% Do this by generating stimuli, running a synthetic subject through the experiment,
% and then attempting to reconstruct a test signal using vanilla reverse correlation
% and compressed sensing.

n_trials = [100, 1000];%, 3000, 10000, 20000];

% Generate stimuli

options = struct;
options.min_freq = 100;
options.max_freq = 22e3;
options.n_bins = 100;
options.bin_duration = 0.4;
options.n_trials = max(n_trials);
options.n_bins_filled_mean = 10;
options.n_bins_filled_var = 3;
options.amplitude_values = linspace(-20, 0, 6);

Fs = 2 * options.max_freq;
nfft = Fs * options.bin_duration;

[stimuli_custom, ~, spect_custom, binned_repr_custom] = stimuli.custom.generate_stimuli_matrix(...
    'min_freq', options.min_freq, ...
    'max_freq', options.max_freq, ...
    'n_bins', options.n_bins, ...
    'bin_duration', options.bin_duration, ...
    'n_trials', options.n_trials, ...
    'n_bins_filled_mean', options.n_bins_filled_mean, ...
    'n_bins_filled_var', options.n_bins_filled_var);

[stimuli_brimijoin, ~, binned_repr_brimijoin] = stimuli.brimijoin.generate_stimuli_matrix(...
    'min_freq', options.min_freq, ...
    'max_freq', options.max_freq, ...
    'n_bins', options.n_bins, ...
    'bin_duration', options.bin_duration, ...
    'n_trials', options.n_trials, ...
    'amplitude_values', options.amplitude_values);

[stimuli_white, ~, binned_repr_white] = stimuli.white.generate_stimuli_matrix(...
    'min_freq', options.min_freq, ...
    'max_freq', options.max_freq, ...
    'n_bins', options.n_bins, ...
    'bin_duration', options.bin_duration, ...
    'n_trials', options.n_trials);

%% Get the gold-standard spectrum
% Use the stimuli generating process because it's easier.
% That way we don't have to worry about dimension mismatch
% or sampling frequency.

[signal, ~, spect, ~] = stimuli.custom.generate_stimuli(...
    'min_freq', options.min_freq, ...
    'max_freq', options.max_freq, ...
    'n_bins', options.n_bins, ...
    'bin_duration', options.bin_duration, ...
    'n_bins_filled_mean', options.n_bins_filled_mean, ...
    'n_bins_filled_var', options.n_bins_filled_var);

% A = imread('Screeching.png');
% A = rgb2gray(A);
% A = imresize(A,1024/size(A,1)); % 0.3
% A = imresize(A,[min(size(A)) min(size(A))]); % 0.3
% A = double(A)./256;

% % Convert image to spectrum
% A = mean(A,2);
% A = 20.*log10(mean(A,2));
% A = flipud(A);
% A(1:5) = -4;

%% Get subject responses

% y_custom = subject_selection_process(spect, )

%% Reconstructions using the spectrum

%% Reconstructions using the binned representation

