[stimulus, Fs, X] = generate_stimuli();

fig = figure;

ax(1) = subplot(2, 1, 1);
plot(ax(1), (1/Fs) * (1:length(stimulus)), stimulus);
xlabel(ax(1), 'time (s)')
ylabel(ax(1), 'amplitude')

ax(2) = subplot(2, 1, 2);
plot(ax(2), 1/1e3 * linspace(100, 22e3, length(X)), X)
xlabel(ax(2), 'frequency (kHz)')
ylabel(ax(2), 'magnitude (dB)')
ylim([-25, 5])

figlib.pretty()


