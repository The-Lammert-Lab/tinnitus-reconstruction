% Compute reconstructions for the pilot data experiment.
% This code assumes that each each experiment uses the same
% number of bins and that the reconstructions
% should be done over the bin representation.

DATA_DIR = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper';
PROJECT_DIR = pathlib.strip(mfilename('fullpath'), 3);

%% Compute the bin representations of the target signals

% Create output directory

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
stimgen.duration = 2*(size(target_signal, 1) / stimgen.get_fs);
binned_target_signal = stimgen.spect2binnedrepr(target_signal);

% Define correlation type
correlation = @(X,Y) corr(X,Y,'Type','Pearson');

%% Convert subject IDs into a data table

for ii = 1:length(this_dir)
    config_file = this_dir(ii);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
end

T = config2table(this_dir);
T.config_filename = config_filenames(:); 


%% Compute the reconstructions

trial_fractions = 1.0; % [0.3, 0.5, 1.0];

% Container for r^2 values
r2_cs_bins = zeros(height(T), length(trial_fractions));
r2_lr_bins = zeros(height(T), length(trial_fractions));
r2_rand = zeros(height(T), 1);
r2_synth = zeros(height(T), 1);

% Container for reconstructions
reconstructions_lr = cell(height(T), length(trial_fractions));
reconstructions_cs = cell(height(T), length(trial_fractions));
reconstructions_rand = cell(height(T), 1);
reconstructions_synth = cell(height(T), 1);

% Container for counting yesses
yesses = zeros(height(T), 1);

% Compute the reconstructions
for ii = 1:height(T)%progress(1:height(T), 'Title', 'Computing reconstructions', 'UpdateRate', 1)
    config_file = this_dir(ii);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    corelib.verb(true, 'INFO: pilot_reconstructions', ['processing config file: [', config_file.name, ']'])
    this_target_signal = binned_target_signal(:, strcmp(data_names, T.target_audio{ii}));

    for qq = 1:length(trial_fractions)
        corelib.verb(true, 'INFO: pilot_reconstructions', ['trial fractions: ', num2str(trial_fractions(qq))])
        % Compute the reconstructions
        corelib.verb(true, 'INFO: pilot_reconstructions', 'computing CS reconstruction')
        [reconstructions_cs{ii, qq}, responses, stimuli_matrix] = get_reconstruction('config', config, ...
                                    'method', 'cs', ...
                                    'fraction', trial_fractions(qq), ...
                                    'verbose', true, ...
                                    'data_dir', DATA_DIR);
        corelib.verb(true, 'INFO: pilot_reconstructions', 'computing linear reconstruction')
        reconstructions_lr{ii, qq} = get_reconstruction('config', config, ...
                                    'method', 'linear', ...
                                    'fraction', trial_fractions(qq), ...
                                    'verbose', true, ...
                                    'data_dir', DATA_DIR);
        
                                    
        % Compute the r^2 values
        r2_cs_bins(ii, qq) = correlation(reconstructions_cs{ii, qq}, this_target_signal);
        r2_lr_bins(ii, qq) = correlation(reconstructions_lr{ii, qq}, this_target_signal);
    end

    % Outside the inner loop,
    % `responses` and `stimuli_matrix` are full-size.

    % Compute reconstructions using random responses
    corelib.verb(true, 'INFO: pilot_reconstructions', 'Computing reconstructions using random responses')
    responses_rand = sign(0.5 - rand(size(stimuli_matrix, 2), 1));
    reconstructions_rand{ii} = gs(responses_rand, stimuli_matrix');
    r2_rand(ii) = correlation(reconstructions_rand{ii}, this_target_signal);
    
    % Compute reconstructions from the in-silico process
    corelib.verb(true, 'INFO: pilot_reconstructions', 'Computing reconstructions using synthetic responses')
    responses_synth = subject_selection_process(this_target_signal, stimuli_matrix');
    reconstructions_synth{ii} = cs(responses_synth, stimuli_matrix');
    r2_synth(ii) = correlation(reconstructions_synth{ii}, this_target_signal);

    % Count number of 'yes' results and normalize
    yesses(ii) = sum(responses > 0) / length(responses);
end

r2_lr_bins = r2_lr_bins .^ 2;
r2_cs_bins = r2_cs_bins .^ 2;
r2_rand = r2_rand .^ 2;
r2_synth = r2_synth .^ 2;

% Build the data table
for ii = 1:length(trial_fractions)
    T.(['r2_lr_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r2_lr_bins(:, ii);
    T.(['r2_cs_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r2_cs_bins(:, ii);
end
T.r2_rand = r2_rand;
T.r2_synth = r2_synth;
T.yesses = yesses;

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

T.reconstructions_cs_1 = reconstructions_cs(:, end);
T.reconstructions_rand = reconstructions_rand;
T.reconstructions_synth = reconstructions_synth;

% Plotting the bin-representation of the target signal vs. the reconstructions

fig1 = new_figure();
cmap = colormaps.linspecer(length(unique(T.subject_ID)) + 2);

subplot_labels = T.target_audio';

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
        plot(ax(qq), normalize(T2.reconstructions_cs_1{ii}), '-o', 'Color', cmap(ii, :))
    end

    % Random (baseline) reconstruction (using linear regression)
    plot(ax(qq), normalize(T2.reconstructions_rand{1}), '-o', 'Color', cmap(ii + 1, :))

    % Synthetic reconstruction (using compressed sensing)
    plot(ax(qq), normalize(T2.reconstructions_synth{1}), '-o', 'Color', cmap(ii + 2, :))
    
    title(ax(qq), ['bin reconstructions, ', subplot_labels{qq}])
end

legend(ax(1), [{'g.c.'}; T2.subject_ID; {'baseline'}; {'synthetic'}])
xlabel(ax(2), 'bins')
figlib.pretty()