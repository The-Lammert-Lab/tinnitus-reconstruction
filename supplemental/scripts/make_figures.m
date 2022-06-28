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

config = parse_config("../code/experiment/configs/config_template.yaml");
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