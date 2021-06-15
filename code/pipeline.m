%% End-to-end proof-of-concept for the data analysis in the proposal
% using fake data.
% This script assumes that we know the cognitive representations
% of tinnitus for a number of patients,
% and that those representations
% are noised versions of the examples from the ATA website.

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

plot_alpha = 0.03;

%% Compute gold-standard spectra

s = cell(5, 1);
f = cell(5, 1);
for ii = 1:length(data_files)
    [s{ii}, f{ii}] = wav2spect([data_dir, data_files{ii}]);
end
s = [s{:}];
f = [f{:}];

% % plot the spectra
% figure
% plot(f(:, 1)/1e3, s)
% xlabel('frequency (kHz)')
% ylabel('magnitude')
% title('canonical spectra')

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

% % plot the spectra
% figure
% plot(f(:, 1)/1e3, y)
% xlabel('frequency (kHz)')
% ylabel('magnitude')
% title('noisy spectra')

%% Compute low-dimensional representation

U = UMAP();
y_new = U.fit_transform(y');
y_new_pca = pca(y, 'NumComponents', 2);

c = colormaps.linspecer(length(data_files));

%% No Color, with Alpha, PCA
% plot some sample spectra
% and the reduced representation
fig1 = figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000]);

% plotting the sample spectra
ax(1) = subplot(1, 2, 1);
hold on
for ii = 1:length(data_files)
    y_index = 1 + (n_data_points_per_cluster - 1) * ii;
    % plot(ax(1), f(:, 1)/1e3, y(:, y_index), 'Color', c(ii, :));
    plt = plot(ax(1), f(:, 1)/1e3, y(:, y_index), 'k');
    plt.Color(4) = plot_alpha;
end
axis square
xlabel(ax(1), 'frequency (kHz')
ylabel(ax(1), 'power (dB)')
% set(ax(1), 'YScale', 'log')
axlib.label(ax(1), 'a', 'FontSize', 40)

% plotting the reduced representation
ax(2) = subplot(1, 2, 2);
title('PCA projection')
hold on
gscatter(ax(2), y_new_pca(:, 1), y_new_pca(:, 2), labels(:), c);
legend(data_names, 'Location', 'best')
axis square
xlabel('dimension 1')
ylabel('dimension 2')
axlib.equalize(ax(2),'x','y')
axlib.label(ax(2), 'b', 'FontSize', 40)

figlib.pretty()
figlib.tight()

axlib.separate(ax(2))

%% No Color, with Alpha, UMAP
% plot some sample spectra
% and the reduced representation
fig1 = figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000]);

% plotting the sample spectra
ax(1) = subplot(1, 2, 1);
hold on
for ii = 1:length(data_files)
    y_index = 1 + (n_data_points_per_cluster - 1) * ii;
    % plot(ax(1), f(:, 1)/1e3, y(:, y_index), 'Color', c(ii, :));
    plt = plot(ax(1), f(:, 1)/1e3, y(:, y_index), 'k');
    plt.Color(4) = plot_alpha;
end
axis square
xlabel(ax(1), 'frequency (kHz')
ylabel(ax(1), 'power (dB)')
% set(ax(1), 'YScale', 'log')
axlib.label(ax(1), 'a', 'FontSize', 40)

% plotting the reduced representation
ax(2) = subplot(1, 2, 2);
title('UMAP projection')
hold on
gscatter(ax(2), y_new(:, 1), y_new(:, 2), labels(:), c);
legend(data_names, 'Location', 'best')
axis square
xlabel('dimension 1')
ylabel('dimension 2')
axlib.equalize(ax(2),'x','y')
axlib.label(ax(2), 'b', 'FontSize', 40)

figlib.pretty()
figlib.tight()

axlib.separate(ax(2))