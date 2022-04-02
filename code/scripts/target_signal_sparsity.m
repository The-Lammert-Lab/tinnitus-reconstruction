%% Quantify the sparisty of the target signals (ATA tinnitus examples)
%% in the DCT basis.

%% Preamble

% Project Directory (i.e., tinnitus-project/)
project_dir = pathlib.strip(mfilename('fullpath'), 3);

% Target signals
sound_dir = pathlib.join(project_dir, 'data', 'sounds');
data_files = {
    'ATA_Tinnitus_Buzzing_Tone_1sec.wav', ...
    'ATA_Tinnitus_Electric_Tone_1sec.wav', ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav', ...
    'ATA_Tinnitus_Static_Tone_1sec.wav', ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav', ...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav' ...
};
data_names = {
    'buzzing', ...
    'electric', ...
    'roaring', ...
    'static', ...
    'teakettle', ...
    'screeching' ...
};
s = cell(5, 1);
f = cell(5, 1);
for ii = 1:length(data_files)
    [s{ii}, f{ii}] = wav2spect(pathlib.join(sound_dir, data_files{ii}));
end
target_signal = [s{:}];
f = [f{:}];

return

%% Transform signals to DCT basis

ts_dct = dct(target_signal);

% Get indices corresponding to top 40 magnitudes.

[B, I] = sort(abs(ts_dct), 1, 'descend');

% Get a compressed representation
ts_dct_compressed = ts_dct;
ts_dct_compressed(I(41:end, :)) = 0;
return

% Compare compressed representation to full representation
for ii = 1:length(data_names)
    ax = subplot(length(data_names), 1, ii);
    plot(ax, db(idct(ts_dct(:, ii))))
    hold on
    plot(ax, db(idct(ts_dct_compressed(:, ii))))
end

return

%% Plot the signals

fig = new_figure();
cmap = colormaps.linspecer(length(data_names));
colormap(cmap)
set(0, 'CurrentFigure', fig);
for ii = 4:-1:1
    ax(ii) = subplot(4, 1, ii);
end

ax(1) = subplot(3, 3, 1:2);
p1 = plot(ax(1), ts_dct .^2);
ylabel(ax(1), 'power')
legend(ax(1), data_names)

ax(2) = subplot(3, 3, 3);
p2 = plot(ax(2), sort(ts_dct .^2, 'descend'));
xlim(ax(2), [0 40])

ax(3) = subplot(3, 3, 4:5);
p3 = plot(ax(3), db(ts_dct .^2));
ylabel(ax(3), 'power (dB)')
for ii = 1:length(p3)
    p3(ii).Color(4) = 0.1;
end

ax(4) = subplot(3, 3, 6);
p4 = plot(ax(4), sort(db(ts_dct .^2), 'descend'));
xlim([0, 40])

ax(5) = subplot(3, 3, 7:9);
p5 = plot(ax(5), sort(db(ts_dct .^2), 'descend'));
ylabel(ax(5), 'power (dB)')
for ii = 1:length(p5)
    p5(ii).Color(4) = 0.5;
end

figlib.pretty('PlotLineWidth', 3, 'FontSize', 22)
figlib.label('XOffset', 0, 'YOffset', 0, 'FontSize', 22)

