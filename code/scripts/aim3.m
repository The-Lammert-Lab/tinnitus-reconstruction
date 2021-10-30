%% Aim #3 Proof-of-Concept
% The goal here is to get a new reconstruction
% clustered into existing clusters
% using the minimum number of trials.
% So we have two questions...
% (1) how to use the minimum number of trials, and 
% (2) how to know when to stop.
% In this script, we will ignore the second question
% and instead focus on seeing how classification accuracy
% changes as a function of number of trials.



data_dir = '/home/alec/data/sounds/';
data_files = {
    'ATA_Tinnitus_Buzzing_Tone_1sec.wav',
    'ATA_Tinnitus_Electric_Tone_1sec.wav',
    'ATA_Tinnitus_Roaring_Tone_1sec.wav',
    'ATA_Tinnitus_Static_Tone_1sec.wav',
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav'
};
data_names = {
    'buzzing',
    'electric',
    'roaring',
    'static',
    'tea kettle'
};

%% Compute gold-standard spectra
% s is a matrix of frequency spectra
% with frequencies f in Hz

s = cell(5, 1);
f = cell(5, 1);
for ii = 1:length(data_files)
    [s{ii}, f{ii}] = wav2spect([data_dir, data_files{ii}]);
end
s = [s{:}];
f = [f{:}];

% downsampling factor is set to unity,
% so don't downsample
s = downsample(s, 1);
f = downsample(f, 1);

%% Generate fake data

n_data_points_per_cluster = 20;
n_data_points = n_data_points_per_cluster * length(data_files);
noise_magnitude = 20;

% replicate the canonical representations
% x = repmat(f, 1, n_data_points);
labels = repmat(1:length(data_files), n_data_points_per_cluster, 1)';
y = repmat(s, 1, n_data_points_per_cluster);

% convert to dB
y = 10 * log10(y);

% add Gaussian noise
y = y + noise_magnitude * randn(size(y));

%% Compute low-dimensional representation

U = UMAP();
y_new = U.fit_transform(y');
y_new_pca = pca(y, 'NumComponents', 2);

%% Signal reconstruction as a function of number of samples
% Signal is the non-decibel true frequency spectrum.
% Subject selection process involves generating
% a binary random matrix, X,
% that picks out frequencies from the true spectrum.
% This isn't a true representation of how the experiment is being run,
% since we are using the random matrix as our measurement matrix
% for reverse correlation.
% NOTE: talk to Adam about this

% n_samples = [100, 1e3, 1e4, 1e5];
% n_samples = round(logspace(1, 4, 11));
n_samples = [1e3, 10e3, 20e3];

% select the tea kettle sound
signal = s(:, 5);

% outputs
reconstructions = zeros(length(signal), length(n_samples));

% perform reconstruction fitting
for ii = 1:length(n_samples)
    [y2, X2] = subject_selection_process(signal, n_samples(ii));
    reconstructions(:, ii) = cs(y2, X2, 200);
end

%% Plot reconstructions

fig1 = figure;

ax(1) = subplot(length(n_samples) + 1, 1, 1);
plot(f(:, 1)/1e3, 10*log10(signal))
title('original')
ylabel('power (dB)')

for ii = 1:length(n_samples)
    ax(ii+1) = subplot(length(n_samples) + 1, 1, 1 + ii);
    plot(f(:, 1)/1e3, 10*log10(reconstructions(:, ii)))
    title(['reconstruction n=' num2str(n_samples(ii))]);
    ylabel('power (dB)')
end

xlabel('frequency (kHz)')
axlib.equalize(ax, 'x', 'y')
figlib.pretty()

%% Plot correlation as a function of number of samples

r = corr(signal, reconstructions) .^2;

fig2 = figure;
scatter(n_samples, r, 32)

xlabel('# of samples')
ylabel('r^2')
ylim([0, 1])
set(gca, 'XScale', 'log')
figlib.pretty()

%% Fit reconstructions into clusters

% fit data into UMAP space
reconstructions_umap = U.transform(reconstructions');

%% Plot clusters and UMAP'd reconstructions

fig3 = figure;
scatter(y_new(:, 1), y_new(:, 2), 60, 'filled', 'MarkerFaceAlpha', 0.75,'MarkerEdgeAlpha', 0.75)
hold on
scatter(reconstructions_umap(:, 1), reconstructions_umap(:, 2), 60, 'filled')

xlabel('dimension 1')
ylabel('dimension 2')
legend({'original data', 'new data points'})

axis square
figlib.pretty()

% create a classification object
classifier = fitcknn(y_new, labels(:));



