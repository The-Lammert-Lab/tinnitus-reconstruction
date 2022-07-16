PROJECT_DIR = pathlib.strip(mfilename('fullpath'), 3);

%% Mel 2 Hz

hz = 100:100:13e3;
fig1 = new_figure();

plot(hz * 1e-3, hz2mels(hz));
xlabel('frequency (kHz)')
ylabel('mels')

axis square

figlib.pretty('FontSize', 36);
figlib.tight();

%% Example Stimulus

config = parse_config(pathlib.join(PROJECT_DIR, 'code', 'experiment', 'configs', 'config_template.yaml'));
stimgen = UniformPriorStimulusGeneration();
stimgen = stimgen.from_config(config);
[stim, Fs, spect, binned_repr, frequency_vector] = stimgen.generate_stimulus();

fig2 = new_figure();

for ii = 3:-1:1
    ax(ii) = subplot(3, 1, ii);
end

plot(ax(1), (1:length(stim)) / Fs, convert2db(stim));
xlabel(ax(1), 'time (s)')
ylabel('amplitude (dB)')
xlim(ax(1), [0, 0.5])

plot(ax(2), 1e-3 * frequency_vector, spect)
xlabel(ax(2), 'frequency (kHz)')
ylabel(ax(2), 'amplitude (dB)')
xlim(ax(2), 'manual')

stem(ax(3), 1:100, binned_repr)
xlabel(ax(3), 'bin number')
ylabel(ax(3), 'amplitude (dB)')
ylim(ax(3), [-25, 5])

figlib.pretty('FontSize', 36, 'PlotBuffer', 0.2)
figlib.label('FontSize', 36)

%% ATA Tinnitus Spectra and Bin Representations

% Target signals
sound_dir = pathlib.join(PROJECT_DIR, 'code', 'experiment', 'ATA');
data_files = {
    'ATA_Tinnitus_Buzzing_Tone_1sec.wav', ...
    'ATA_Tinnitus_Electric_Tone_1sec.wav', ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav', ...
    'ATA_Tinnitus_Static_Tone_1sec.wav', ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav', ...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav' ...
};
data_names = {
    'Buzzing', ...
    'Electric', ...
    'Roaring', ...
    'Static', ...
    'Teakettle', ...
    'Screeching' ...
};
s = cell(5, 1);
f = cell(5, 1);
for ii = 1:length(data_files)
    [s{ii}, f{ii}] = wav2spect(pathlib.join(sound_dir, data_files{ii}));
end
target_signal = [s{:}];
% convert to dB
target_signal = 10 * log10(target_signal);
f = [f{:}];

% Get the binned representation for the target signals
stimgen.duration = 2*(size(target_signal, 1) / stimgen.get_fs);
binned_target_signal = stimgen.spect2binnedrepr(target_signal);
unbinned_target_signal = stimgen.binnedrepr2spect(binned_target_signal);

fig3 = new_figure();
plot_data_names = {'Buzzing', 'Roaring'};

for ii = length(plot_data_names):-1:1
    ax(ii) = subplot(length(plot_data_names), 1, ii);
    hold on

    ind1 = f(:, 1) < 13e3;
    ind2 = strcmp(data_names, plot_data_names{ii});

    plot(ax(ii), 1e-3 * f(ind1, 1), target_signal(ind1, ind2), '-k');
    plot(ax(ii), 1e-3 * f(ind1, 1), unbinned_target_signal(ind1, ind2), '-r');

    ylabel(ax(ii), 'amplitude (dB)')
end

xlabel(ax(2), 'frequency (kHz)')
figlib.pretty('FontSize', 36, 'PlotBuffer', 0.02)
figlib.label('FontSize', 36)