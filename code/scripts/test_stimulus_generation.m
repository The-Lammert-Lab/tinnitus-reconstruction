%% Test Stimulus Generation
% Test three types of stimulus generation: Brimijoin, our custom one, and white noise.
% Do this by generating stimuli, running a synthetic subject through the experiment,
% and then attempting to reconstruct a test signal using vanilla reverse correlation
% and compressed sensing.

n_trials = [100, 1000];%, 3000, 10000, 20000];

% Generate stimuli

options                     = struct;
options.min_freq            = 100;
options.max_freq            = 22e3;
options.n_bins              = 100;
options.bin_duration        = 0.4;
options.n_trials            = max(n_trials);
options.n_bins_filled_mean  = 10;
options.n_bins_filled_var   = 3;
options.amplitude_values    = linspace(-20, 0, 6);

Fs = 2 * options.max_freq;
nfft = Fs * options.bin_duration;

% instantiate object
stimuli = Stimuli(options);

%% Get the gold-standard spectrum
% Use the stimuli generating process because it's easier.
% That way we don't have to worry about dimension mismatch
% or sampling frequency.

[~, ~, spect, ~] = stimuli.custom_generate_stimuli();

%% Get subject responses

[y_default, X_default]      = stimuli.subject_selection_process(spect, 'default');
[y_brimijoin, X_brimijoin]  = stimuli.subject_selection_process(spect, 'brimijoin');
[y_custom, X_custom]        = stimuli.subject_selection_process(spect, 'custom');
[y_white, X_white]          = stimuli.subject_selection_process(spect, 'white');

%% Reconstructions using the spectrum

recon_default               = cs(y_default, X_default');
recon_brimijoin             = cs(y_brimijoin, X_brimijoin');
recon_custom                = cs(y_custom, X_custom');
recon_white                 = cs(y_white, X_white');

%% Reconstructions using the binned representation

