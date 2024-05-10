% ## target_signal_sparsity
% Quantify the sparsity of the target signals (ATA tinnitus examples)
% in the DCT basis.
% End of documentation

%% Preamble

font_size = 36;

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

% Get bin-space representation

config = parse_config(pathlib.join(project_dir, 'code', 'experiment', 'configs', 'config_template.yaml'));
stimgen = UniformPriorStimulusGeneration();
stimgen = stimgen.from_config(config);
target_signal_binrep = stimgen.spect2binnedrepr(target_signal);

% Convert signals to decibels

target_signal_db = convert_to_db(target_signal);
target_signal_binrep_db = convert_to_db(target_signal_binrep);

%% Transform signals to DCT basis

ts_dct = dct(target_signal_db);
ts_br_dct = dct(target_signal_binrep_db);

% Get indices corresponding to top 40 magnitudes.

[B, I] = sort(abs(ts_dct), 1, 'descend');
[B_br, I_br] = sort(abs(ts_br_dct), 1, 'descend');

% Get a compressed representation

ts_dct_compressed = ts_dct;
for ii = 1:size(ts_dct_compressed, 2)
    ts_dct_compressed(I(33:end, ii), ii) = 0;
end

ts_br_dct_compressed = ts_br_dct;
for ii = 1:size(ts_br_dct_compressed, 2)
    ts_br_dct_compressed(I_br(11:end, ii), ii) = 0;
end

% Compare compressed representation to full representation

fig1 = new_figure();

for ii = 1:length(data_names)
    ax = subplot(length(data_names), 2, ii);
    plot(ax, 1e-3 * f, idct(ts_dct(:, ii)));
    hold on
    plot(ax, 1e-3 * f, idct(ts_dct_compressed(:, ii)));
    % title(data_names{ii})
    ylabel(ax, 'amplitude (dB)', 'FontSize', font_size)
    if ii >= (length(data_names) - 1)
        xlabel(ax, 'frequency (kHz)', 'FontSize', font_size)
    end
end

figlib.pretty('PlotLineWidth', 3, 'FontSize', font_size, 'EqualiseX', true, 'EqualiseY', true)
figlib.tight()
figlib.label('XOffset', 0, 'YOffset', -.03, 'FontSize', font_size)


fig2 = new_figure();


for ii = 1:length(data_names)
    ax = subplot(length(data_names), 2, ii);
    plot(ax, idct(ts_br_dct(:, ii)));
    hold on
    plot(ax, idct(ts_br_dct_compressed(:, ii)));
    ylabel('amplitude (dB)', 'FontSize', font_size)
    if ii >= (length(data_names) - 1)
        xlabel(ax, 'bins', 'FontSize', font_size)
    end
    % title(data_names{ii})
end
figlib.pretty('PlotLineWidth', 3, 'FontSize', font_size, 'EqualiseX', true, 'EqualiseY', true)
figlib.tight()
figlib.label('XOffset', 0, 'YOffset', -.03, 'FontSize', font_size)

r2 = zeros(size(ts_dct, 2), 1);
r2_br = zeros(size(ts_br_dct, 2), 1);
for ii = 1:length(r2)
    r2(ii) = corr(idct(ts_dct(:, ii)), idct(ts_dct_compressed(:, ii)));
    r2_br(ii) = corr(idct(ts_br_dct(:, ii)), idct(ts_br_dct_compressed(:, ii)));
end

T = table(r2, r2_br, data_names(:), 'VariableNames', {'r2', 'r2_br', 'target_signal'})


%% Plot the signals

fig3 = new_figure();

cmap = colormaps.linspecer(length(data_names));
colormap(cmap)
set(0, 'CurrentFigure', fig3);
for ii = 2:-1:1
    ax(ii) = subplot(2, 1, ii);
end

p1 = plot(ax(1), ts_dct .^2);
ylabel(ax(1), 'power', 'FontSize', font_size)
xlim(ax(1), [-15, 8193 + 15])
legend(ax(1), data_names)

p2 = plot(ax(2), sort(ts_dct .^2, 'descend'));
ylabel(ax(2), 'power', 'FontSize', font_size)
xlim(ax(2), buffer_x_axis([0, 40], 0.025))

figlib.pretty('PlotLineWidth', 3, 'FontSize', font_size, 'PlotBuffer', 0.1)
figlib.tight()
figlib.label('XOffset', 0, 'YOffset', -.03, 'FontSize', font_size)

% cmap = colormaps.linspecer(length(data_names));
% colormap(cmap)
% set(0, 'CurrentFigure', fig3);
% for ii = 4:-1:1
%     ax(ii) = subplot(4, 1, ii);
% end

% ax(1) = subplot(3, 3, 1:2);
% p1 = plot(ax(1), f(:, 1) * 1e-3, ts_dct .^2);
% ylabel(ax(1), 'power', 'FontSize', font_size)
% xlabel(ax(1), 'frequency (kHz)', 'FontSize', font_size)
% xlim(ax(1), buffer_x_axis(f(:,1) * 1e-3, 0.025))
% legend(ax(1), data_names)

% ax(2) = subplot(3, 3, 3);
% p2 = plot(ax(2), sort(ts_dct .^2, 'descend'));
% ylabel(ax(2), 'power', 'FontSize', font_size)
% xlim(ax(2), buffer_x_axis([0, 40], 0.025))

% ax(3) = subplot(3, 3, 4:5);
% p3 = plot(ax(3), db(ts_dct .^2));
% ylabel(ax(3), 'power (dB)', 'FontSize', font_size)
% xlim(ax(3), buffer_x_axis(1:length(ts_dct), 0.025))
% for ii = 1:length(p3)
%     p3(ii).Color(4) = 0.1;
% end

% ax(4) = subplot(3, 3, 6);
% p4 = plot(ax(4), sort(db(ts_dct .^2), 'descend'));
% ylabel(ax(4), 'power (dB)', 'FontSize', font_size)
% xlim(ax(4), buffer_x_axis(1:length(ts_dct), 0.025))
% xlim([0, 40])

% ax(5) = subplot(3, 3, 7:9);
% p5 = plot(ax(5), sort(db(ts_dct .^2), 'descend'));
% ylabel(ax(5), 'power (dB)', 'FontSize', font_size)
% xlim(ax(5), buffer_x_axis(1:length(ts_dct), 0.025))
% for ii = 1:length(p5)
%     p5(ii).Color(4) = 0.5;
% end

% figlib.pretty('PlotLineWidth', 3, 'FontSize', font_size, 'PlotBuffer', 0.1)
% figlib.tight()
% figlib.label('FontSize', font_size)