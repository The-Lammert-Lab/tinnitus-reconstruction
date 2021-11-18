%% Test Stimulus Generation
% Test three types of stimulus generation: Brimijoin, our custom one, and white noise.
% Do this by generating stimuli, running a synthetic subject through the experiment,
% and then attempting to reconstruct a test signal using vanilla reverse correlation
% and compressed sensing.

%% Parameters

n_trials = [100, 1000, 3000, 10000, 20000];

%% Generate stimuli

options                     = struct;
options.min_freq            = 100;
options.max_freq            = 22e3;
options.n_bins              = 100;
options.bin_duration        = 0.4;
options.n_trials            = max(n_trials);
options.n_bins_filled_mean  = 10;
options.n_bins_filled_var   = 3;
options.amplitude_values    = linspace(-20, 0, 6);

% instantiate object
stimuli = Stimuli(options);

% useful variables
[B, Fs, nfft] = stimuli.get_freq_bins();

%% Get the gold-standard spectrum
% Use the stimuli generating process because it's easier.
% That way we don't have to worry about dimension mismatch
% or sampling frequency.

[~, ~, spect, ~] = stimuli.custom_generate_stimuli();
t = linspace(-1, 1, length(spect));
spect = half_cosine(t, 10);

%% Get subject responses

[y_default, X_default]                              = stimuli.subject_selection_process(spect, 'default');
[y_brimijoin, X_brimijoin, binned_repr_brimijoin]   = stimuli.subject_selection_process(spect, 'brimijoin');
[y_custom, X_custom, binned_repr_custom]            = stimuli.subject_selection_process(spect, 'custom');
[y_white, X_white, binned_repr_white]               = stimuli.subject_selection_process(spect, 'white');
[y_white_no_bins, X_white_no_bins]                  = stimuli.subject_selection_process(spect, 'white_no_bins');

%% Vanilla reverse correlation reconstructions using the spectrum

recon_gs_default           = zeros(size(X_default, 1), length(n_trials));
recon_gs_brimijoin         = zeros(size(X_brimijoin, 1), length(n_trials));
recon_gs_custom            = zeros(size(X_custom, 1), length(n_trials));
recon_gs_white             = zeros(size(X_white, 1), length(n_trials));
recon_gs_white_no_bins     = zeros(size(X_white_no_bins, 1), length(n_trials));

for ii = 1:length(n_trials)
    % default
    this_y_default = y_default(1:n_trials(ii));
    this_X_default = X_default(:, 1:n_trials(ii));
    recon_gs_default(:, ii) = gs(this_y_default, this_X_default');
    
    % brimijoin
    this_y_brimijoin = y_brimijoin(1:n_trials(ii));
    this_X_brimijoin = X_brimijoin(:, 1:n_trials(ii));
    recon_gs_brimijoin(:, ii) = gs(this_y_brimijoin, this_X_brimijoin');
    
    % custom
    this_y_custom = y_custom(1:n_trials(ii));
    this_X_custom = X_custom(:, 1:n_trials(ii));
    recon_gs_custom(:, ii) = gs(this_y_custom, this_X_custom');
    
    % white
    this_y_white = y_white(1:n_trials(ii));
    this_X_white = X_white(:, 1:n_trials(ii));
    recon_gs_white(:, ii) = gs(this_y_white, this_X_white');

    % white no bins
    this_y_white_no_bins = y_white_no_bins(1:n_trials(ii));
    this_X_white_no_bins = X_white_no_bins(:, 1:n_trials(ii));
    recon_gs_white_no_bins(:, ii) = gs(this_y_white_no_bins, this_X_white_no_bins');
end

%% CS reconstructions using the spectrum

recon_cs_default           = zeros(size(X_default, 1), length(n_trials));
recon_cs_brimijoin         = zeros(size(X_brimijoin, 1), length(n_trials));
recon_cs_custom            = zeros(size(X_custom, 1), length(n_trials));
recon_cs_white             = zeros(size(X_white, 1), length(n_trials));
recon_cs_white_no_bins     = zeros(size(X_white_no_bins, 1), length(n_trials));

for ii = 1:length(n_trials)
    % default
    this_y_default = y_default(1:n_trials(ii));
    this_X_default = X_default(:, 1:n_trials(ii));
    recon_cs_default(:, ii) = cs(this_y_default, this_X_default');
    
    % brimijoin
    this_y_brimijoin = y_brimijoin(1:n_trials(ii));
    this_X_brimijoin = X_brimijoin(:, 1:n_trials(ii));
    recon_cs_brimijoin(:, ii) = cs(this_y_brimijoin, this_X_brimijoin');
    
    % custom
    this_y_custom = y_custom(1:n_trials(ii));
    this_X_custom = X_custom(:, 1:n_trials(ii));
    recon_cs_custom(:, ii) = cs(this_y_custom, this_X_custom');
    
    % white
    this_y_white = y_white(1:n_trials(ii));
    this_X_white = X_white(:, 1:n_trials(ii));
    recon_cs_white(:, ii) = cs(this_y_white, this_X_white');

    % white no bins
    this_y_white_no_bins = y_white_no_bins(1:n_trials(ii));
    this_X_white_no_bins = X_white_no_bins(:, 1:n_trials(ii));
    recon_cs_white_no_bins(:, ii) = cs(this_y_white_no_bins, this_X_white_no_bins');
end

%% CS reconstructions using the binned representation

recon_cs_binned_brimijoin  = zeros(stimuli.n_bins, length(n_trials));
recon_cs_binned_custom     = zeros(stimuli.n_bins, length(n_trials));
recon_cs_binned_white      = zeros(stimuli.n_bins, length(n_trials));

for ii = 1:length(n_trials)
    % brimijoin
    this_y_brimijoin = y_brimijoin(1:n_trials(ii));
    this_binned_repr_brimijoin = binned_repr_brimijoin(:, 1:n_trials(ii));
    recon_cs_binned_brimijoin(:, ii) = cs(this_y_brimijoin, this_binned_repr_brimijoin');
    
    % custom
    this_y_custom = y_custom(1:n_trials(ii));
    this_binned_repr_custom = binned_repr_custom(:, 1:n_trials(ii));
    recon_cs_binned_custom(:, ii) = cs(this_y_custom, this_binned_repr_custom');
    
    % white
    this_y_white = y_white(1:n_trials(ii));
    this_binned_repr_white = binned_repr_white(:, 1:n_trials(ii));
    recon_cs_binned_white(:, ii) = cs(this_y_white, this_binned_repr_white');
end

% Transform back to spectrum representation
recon_cs_binned_spect_brimijoin    = binnedrepr2spect(recon_cs_binned_brimijoin', B)';
recon_cs_binned_spect_custom       = binnedrepr2spect(recon_cs_binned_custom', B)';
recon_cs_binned_spect_white        = binnedrepr2spect(recon_cs_binned_white', B)';

%% Visualization

% The gold standard is a 8800x1 vector stored in `spect`.
% The reconstructions are 8800 x n_trials matrices stored
% in variables beginning with `recon_`, e.g.,
% `recon_cs_white`.
%
% We generate one figure for each combination
% of number of samples (n_trials)
% and stimulus generation method.

recons_gs = {...
    recon_gs_default, ...
    recon_gs_brimijoin, ...
    recon_gs_custom, ...
    recon_gs_white, ...
    recon_gs_white_no_bins
};

recons_cs = {...
    recon_cs_default, ...
    recon_cs_brimijoin, ...
    recon_cs_custom, ...
    recon_cs_white, ...
    recon_cs_white_no_bins
};

stimuli_types = {...
    'default', ...
    'brimijoin', ...
    'custom', ...
    'white', ...
    'white-no-bins'
};

reconstruction_type = {...
    'vanilla', ...
    'cs'
};

for ii = 1:length(stimuli_types)
    for qq = 1:length(n_trials)
        fig = new_figure();
        fig.Name = ['reconstruction_half-cosine_', 'n_trials=' num2str(n_trials(qq)), ...
                    '_', 'stimuli-type=', stimuli_types{ii}];
        n_subplots = 3;

        for ww = n_subplots:-1:1
            ax(ww) = subplot(n_subplots, 1, ww);
        end

        % plot the gold-standard spectrum (normalized)
        plot(ax(1), 1e-3 * frequencies, normalize(spect));

        % plot the reverse correlation reconstruction (normalized)
        plot(ax(2), 1e-3 * frequencies, normalize(recons_gs{ii}(:, qq)))

        % plot the compressed sensing reconstruction (normalized)
        plot(ax(3), 1e-3 * frequencies, normalize(recons_cs{ii}(:, qq)))

        xlabel('frequency (kHz)')
        title(['reconstruction half-cosine ', 'n-trials=', num2str(n_trials(qq)), ...
              ' stimuli-type=', stimuli_types{ii}]);
        axlib.equalize('xy')
        figlib.pretty()
        figlib.label()

    end % qq
end % ii

figlib.saveall('Location', '~/data/figures')

return

% Visualization of spectrum-based reconstruction
% with one plot per number of trials
% and subplots for each stimulus generation method.
for qq = 1:length(n_trials)

    fig = new_figure();
    fig.Name = ['spect, ', 'n_trials=', num2str(n_trials(qq))];
    n_subplots = 6;
    frequencies = 1:2:(2*length(spect));

    for ii = n_subplots:-1:1
        ax(ii) = subplot(n_subplots, 1, ii);
    end

    % plot the gold standard spectrum (normalized axes)
    plot(ax(1), 1e-3 * frequencies, normalize(spect))

    % plot the representation using the default stimulus generation method
    plot(ax(2), 1e-3 * frequencies, normalize(recon_default(:, qq)))

    % plot the representation using the custom stimulus generation method
    plot(ax(3), 1e-3 * frequencies, normalize(recon_custom(:, qq)))

    % plot the representation using the brimijoin stimulus generation method
    plot(ax(4), 1e-3 * frequencies, normalize(recon_brimijoin(:, qq)))

    % plot the representation using the white noise stimulus generation method
    plot(ax(5), 1e-3 * frequencies, normalize(recon_white(:, qq)))

    % plot the representation using the binless white noise stimulus generation method
    plot(ax(6), 1e-3 * frequencies, normalize(recon_white_no_bins(:, qq)))

    xlabel('frequency (kHz)')
    axlib.equalize('xy')
    figlib.pretty()
    figlib.label()

end % qq

% Visualization of bin-based reconstruction
% with one ploit per number of trials
% and subplots for each stimulus generation method.
for qq = 1:length(n_trials)

    fig = new_figure();
    fig.Name = ['binned, ', 'n_trials=', num2str(n_trials(qq))];
    n_subplots = 4;
    frequencies = 1:2:(2*length(spect));

    for ii = n_subplots:-1:1
        ax(ii) = subplot(n_subplots, 1, ii);
    end

    % plot the gold standard spectrum (normalized axes)
    plot(ax(1), 1e-3 * frequencies, normalize(spect))

    % plot the representation using the custom stimulus generation method
    plot(ax(2), 1e-3 * frequencies, normalize(recon_binned_spect_custom(:, qq)))

    % plot the representation using the brimijoin stimulus generation method
    plot(ax(3), 1e-3 * frequencies, normalize(recon_binned_spect_brimijoin(:, qq)))

    % plot the representation using the white noise stimulus generation method
    plot(ax(4), 1e-3 * frequencies, normalize(recon_binned_spect_white(:, qq)))

    xlabel('frequency (kHz)')
    axlib.equalize('xy')
    figlib.pretty()
    figlib.label()

end % qq