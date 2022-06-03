% Compute reconstructions for the pilot data experiment.
% This code assumes that each each experiment uses the same
% number of bins and that the reconstructions
% should be done over the bin representation.

DATA_DIR = '/home/alec/code/tinnitus-project/code/experiment/Data/data_pilot';
PROJECT_DIR = pathlib.strip(mfilename('fullpath'), 3);

%% Compute the bin representations of the target signals

% Create output directory

% Target signals
sound_dir = pathlib.join(PROJECT_DIR, 'data', 'sounds');
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
% convert to dB
target_signal = 10 * log10(target_signal);
f = [f{:}];

% Directory containing the data
this_dir = dir(pathlib.join(DATA_DIR, '*.yaml'));

% Get array of structs of config files
config_filenames = {this_dir.name};

% Container for config IDs
config_ids = cell(length(this_dir), 1);

% Get the binned representation for the target signals
config = parse_config(pathlib.join(this_dir(1).folder, this_dir(1).name));
stimgen = eval([config.stimuli_type, 'StimulusGeneration()']);
stimgen = stimgen.from_config(config);
stimgen.duration = size(target_signal, 1) / stimgen.max_freq;
binned_target_signal = stimgen.spect2binnedrepr(target_signal);

%% Convert subject IDs into a data table

for ii = 1:length(this_dir)
    config_file = this_dir(ii);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    config_ids{ii} = config.subjectID;
end

T = collect_parameters(config_ids);
T.config_filename = config_filenames';

%% Compute the reconstructions

trial_fractions = [0.3, 0.5, 1.0];

% Container for r^2 values
r2_cs_bins = zeros(length(config_ids), length(trial_fractions));
r2_lr_bins = zeros(length(config_ids), length(trial_fractions));

% Container for reconstructions
reconstructions_lr = cell(length(config_ids), length(trial_fractions));
reconstructions_cs = cell(length(config_ids), length(trial_fractions));

% Compute the reconstructions
for ii = 1:height(T)%progress(1:height(T), 'Title', 'Computing reconstructions', 'UpdateRate', 1)
    config_file = this_dir(ii);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    corelib.verb(true, 'INFO: pilot_reconstructions', ['processing config file: [', config_file.name, ']'])

    for qq = 1:length(trial_fractions)
        corelib.verb(true, 'INFO: pilot_reconstructions', ['trial fractions: ', num2str(trial_fractions(qq))])
        % Compute the reconstructions
        if strcmp(T.subject{ii}, 'AL')
            preprocessing = {'bins', 'bit flip'};
        else
            preprocessing = {'bins'};
        end
        corelib.verb(true, 'INFO: pilot_reconstructions', 'computing CS reconstruction')
        reconstructions_cs{ii, qq} = get_reconstruction('config', config, ...
                                    'preprocessing', preprocessing, ...
                                    'method', 'cs', ...
                                    'fraction', trial_fractions(qq), ...
                                    'verbose', true);
        corelib.verb(true, 'INFO: pilot_reconstructions', 'computing linear reconstruction')
        reconstructions_lr{ii, qq} = get_reconstruction('config', config, ...
                                    'preprocessing', preprocessing, ...
                                    'method', 'linear', ...
                                    'fraction', trial_fractions(qq), ...
                                    'verbose', true);
        
        % Compute the r^2 values
        r2_cs_bins(ii, qq) = corr(reconstructions_cs{ii, qq}, binned_target_signal(:, strcmp(data_names, T.target_audio{ii})));
        r2_lr_bins(ii, qq) = corr(reconstructions_lr{ii, qq}, binned_target_signal(:, strcmp(data_names, T.target_audio{ii})));
    end
end

r2_lr_bins = r2_lr_bins .^ 2;
r2_cs_bins = r2_cs_bins .^ 2;

% Build the data table
for ii = 1:length(trial_fractions)
    T.(['r2_lr_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r2_lr_bins(:, ii);
    T.(['r2_cs_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r2_cs_bins(:, ii);
end

% Clean up table
numeric_columns = {
    'min_freq', 'max_freq', 'n_bins', 'duration', 'n_trials', 'n_bins_filled_mean', ...
    'n_bins_filled_var', 'bin_prob', 'amplitude_mean', 'amplitude_var', 'bin_rep', 'gamma'};
for ii = 1:length(numeric_columns)
    if any(strcmp(T.Properties.VariableNames, numeric_columns{ii}))
        T.(numeric_columns{ii}) = str2double(T.(numeric_columns{ii}));
    end
end

%% Visualization

T.reconstructions_cs_1 = reconstructions_cs(:, 3);

% Plotting the bin-representation of the target signal vs. the reconstructions

fig1 = new_figure();
cmap = colormaps.linspecer(length(unique(T.subject)));

subplot_labels = {'buzzing', 'roaring'};

for ii = 2:-1:1
    ax(ii) = subplot(2, 1, ii, 'Parent', fig1);
    hold on
end

for qq = 1:length(subplot_labels)

    % True signal
    plot(ax(qq), normalize(binned_target_signal(:, strcmp(data_names, subplot_labels{qq}))), '-ok');
    ylabel(ax(qq), 'norm. bin ampl. (a.u.)')
    
    % Reconstructions
    T2 = T(strcmp(T.target_audio, subplot_labels{qq}), :);
    for ii = 1:height(T2)
        plot(ax(qq), normalize(T2.reconstructions_cs_1{ii}), '-o', 'Color', cmap(:, ii))
    end
    
    title(ax(qq), ['bin reconstructions, ', subplot_labels{qq}])
end

legend(ax(1), [{'g.c.'}; T2.subject])
xlabel(ax(2), 'bins')
figlib.pretty()