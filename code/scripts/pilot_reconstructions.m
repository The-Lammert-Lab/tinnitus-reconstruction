% Compute reconstructions for the pilot data experiment.
% This code assumes that each each experiment uses the same number of bins and that the reconstructions should be done over the bin representation.
% 
% **OUTPUTS:**
%  - T: a data table that contains information about the experiments and their reconstructions

%% Preamble
% Change the DATA_DIR and PUBLISH flags as you need to.

DATA_DIR = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper';
PROJECT_DIR = pathlib.strip(mfilename('fullpath'), 3);
BOOTSTRAP = 0; % Set to 0 or false if not using.
PUBLISH = false;

%% Get the target signals

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

% Remove resynth or 2afc (for now)
% TODO: remove!!
% ii = 0;
% while ii < (length(this_dir) + 1)
%     ii = ii + 1;
%     if contains(this_dir(ii).name, '2afc')
%         this_dir(ii) = [];
%     end
% end

%% Get the experiments, by configuration files

% Get array of structs of config files
config_filenames = {this_dir.name};

% Container for config IDs
config_ids = cell(length(this_dir), 1);

% Define correlation type
correlation = @(X,Y) corr(X,Y,'Type','Pearson');

%% Create a data table by reading the config files

config_hash = cell(length(this_dir),1);
binned_target_signal = cell(length(this_dir), 1);

for ii = 1:length(this_dir)
    % Read the config file
    config_file = this_dir(ii);
    this_path = pathlib.join(config_file.folder, config_file.name);
    corelib.verb(true, 'INFO: pilot_reconstructions', ['reading config file: ', this_path])
    config = parse_config(this_path);
    config_hash{ii} = get_hash(config);
    % Compute the binned target signals
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);
    binned_target_signal{ii} = stimgen.spect2binnedrepr(target_signal);
end

T = config2table(this_dir);
T.config_filename = config_filenames(:); 

% Overwrite config total trials with actual totals from data
for i = 1:length(config_hash)
    total_trials_done = 0;
    d = dir(pathlib.join(DATA_DIR, ['responses_', config_hash{i}, '*.csv']));
    for ii = 1:length(d)
        responses = readmatrix(pathlib.join(d(ii).folder, d(ii).name));
        total_trials_done = total_trials_done + length(responses);
    end
    row = ismember(T.config_hash, config_hash{i}, 'rows');
    T.total_data(row) = total_trials_done;
end

%% Compute the reconstructions

n_trials = inf; % set to inf if using all available data
trial_fractions = 1; %0.1:0.1:1;

if ~isinf(n_trials)
    T.total_trials_used = repmat(n_trials, height(T), 1);
    fix_rows = T.total_data < T.total_trials_used;
    T.total_trials_used(fix_rows) = T.total_data(fix_rows);
else
    T.total_trials_used = T.total_data;
end

% Container for r values
r_cs_bins = zeros(height(T), length(trial_fractions));
r_lr_bins = zeros(height(T), length(trial_fractions));
r_rand = zeros(height(T), 1);
r_synth = zeros(height(T), length(trial_fractions));
p_cs_bins = zeros(height(T), length(trial_fractions));
p_lr_bins = zeros(height(T), length(trial_fractions));
p_rand = zeros(height(T), 1);
p_synth = zeros(height(T), length(trial_fractions));

if BOOTSTRAP
    r_bootstrap_cs_mean = zeros(height(T), length(trial_fractions));
    r_bootstrap_lr_mean = zeros(height(T), length(trial_fractions));
    r_bootstrap_cs_std = zeros(height(T), length(trial_fractions));
    r_bootstrap_lr_std = zeros(height(T), length(trial_fractions));
end

% Container for reconstructions
reconstructions_lr = cell(height(T), length(trial_fractions));
reconstructions_cs = cell(height(T), length(trial_fractions));
reconstructions_rand = cell(height(T), 1);
reconstructions_synth = cell(height(T), length(trial_fractions));

% Container for counting yesses
yesses = zeros(height(T), 1);

% Compute the reconstructions
for ii = 1:height(T)
    config_file = this_dir(ii);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));

    % Compute the gamma parameter
    this_gamma = get_gamma_from_config(config);

    corelib.verb(true, 'INFO: pilot_reconstructions', ['processing config file: [', config_file.name, ']'])
    this_target_signal = binned_target_signal{ii}(:, strcmp(data_names, T.target_signal_name{ii}));

    preprocessing = {};
    if strcmp(config.subject_ID, 'AB')
        preprocessing = {'bit_flip'};
    end

    for qq = 1:length(trial_fractions)
        corelib.verb(true, 'INFO: pilot_reconstructions', ['trial fractions: ', num2str(trial_fractions(qq))])
        % Compute the reconstructions
        corelib.verb(true, 'INFO: pilot_reconstructions', 'computing CS reconstruction')

        [reconstructions_cs{ii, qq}, r_bootstrap_cs, responses, stimuli_matrix] = get_reconstruction('config', config, ...
                                    'method', 'cs', ...
                                    'fraction', trial_fractions(qq), ...
                                    'use_n_trials', n_trials, ...
                                    'bootstrap', BOOTSTRAP, ... 
                                    'verbose', true, ...
                                    'target', this_target_signal, ...
                                    'preprocessing', preprocessing, ...
                                    'data_dir', DATA_DIR);
        corelib.verb(true, 'INFO: pilot_reconstructions', 'computing linear reconstruction')
        [reconstructions_lr{ii, qq}, r_bootstrap_lr, ~, ~] = get_reconstruction('config', config, ...
                                    'method', 'linear', ...
                                    'fraction', trial_fractions(qq), ...
                                    'use_n_trials', n_trials, ...
                                    'bootstrap', BOOTSTRAP, ... 
                                    'verbose', true, ...
                                    'target', this_target_signal, ...
                                    'preprocessing', preprocessing, ...
                                    'data_dir', DATA_DIR);
        
        % Compute reconstructions from the in-silico process
        corelib.verb(true, 'INFO: pilot_reconstructions', 'Computing reconstructions using synthetic responses')
        responses_synth = subject_selection_process(this_target_signal, stimuli_matrix');
        reconstructions_synth{ii, qq} = gs(responses_synth, stimuli_matrix');
        
        % Compute the r values
        [r_cs_bins(ii, qq), p_cs_bins(ii, qq)] = correlation(reconstructions_cs{ii, qq}, this_target_signal);
        [r_lr_bins(ii, qq), p_lr_bins(ii, qq)] = correlation(reconstructions_lr{ii, qq}, this_target_signal);
        [r_synth(ii, qq), p_synth(ii, qq)] = correlation(reconstructions_synth{ii, qq}, this_target_signal);

        if BOOTSTRAP
            r_bootstrap_cs_mean(ii, qq) = mean(r_bootstrap_cs);
            r_bootstrap_lr_mean(ii, qq) = mean(r_bootstrap_lr);
            r_bootstrap_cs_std(ii, qq) = std(r_bootstrap_cs);
            r_bootstrap_lr_std(ii, qq) = std(r_bootstrap_lr);
        end
    end

    % Outside the inner loop,
    % `responses` and `stimuli_matrix` are full-size.

    % Compute reconstructions using random responses
    corelib.verb(true, 'INFO: pilot_reconstructions', 'Computing reconstructions using random responses')
    responses_rand = sign(0.5 - rand(size(stimuli_matrix, 2), 1));
    reconstructions_rand{ii} = gs(responses_rand, stimuli_matrix');
    [r_rand(ii), p_rand(ii)] = correlation(reconstructions_rand{ii}, this_target_signal);
    
    % Count number of 'yes' results and normalize
    yesses(ii) = sum(responses > 0) / length(responses);
end

%% Add reconstructions to data table

T.reconstructions_cs_1 = reconstructions_cs(:, end);
T.reconstructions_lr_1 = reconstructions_lr(:, end);
T.reconstructions_rand = reconstructions_rand;
T.reconstructions_synth = reconstructions_synth;

%% Fix correlations for resynth experiments
ix = find(contains(T.experiment_name, 'resynth'));
T2 = T(ix, :);

% Get binned resynth target signal
% They are the reconstructions from the original signal
experiment_names = cellfun(@(x) strrep(x, '-resynth', ''), T2.experiment_name, 'UniformOutput', false);
T_filtered = T(contains(T.experiment_name, experiment_names), :);
binned_resynth_target_signal = [T_filtered.reconstructions_cs_1{:}];

for ii = 1:height(T2)
    iii = ix(ii);
    for qq = 1:length(trial_fractions)
        [r_cs_bins(iii, qq), p_cs_bins(iii, qq)] = correlation(reconstructions_cs{iii, qq}, binned_resynth_target_signal(:, ii));
        [r_lr_bins(iii, qq), p_lr_bins(iii, qq)] = correlation(reconstructions_lr{iii, qq}, binned_resynth_target_signal(:, ii));
        [r_synth(iii, qq), p_synth(iii, qq)] = correlation(reconstructions_synth{iii, qq}, binned_resynth_target_signal(:, ii));
    end
    [r_rand(iii), p_cs_bins(iii)] = correlation(reconstructions_rand{iii}, binned_resynth_target_signal(:, ii));
end

% Build the data table
for ii = 1:length(trial_fractions)
    T.(['r_lr_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r_lr_bins(:, ii);
    T.(['r_cs_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r_cs_bins(:, ii);
    T.(['p_lr_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = p_lr_bins(:, ii);
    T.(['p_cs_bins_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = p_cs_bins(:, ii);

    if BOOTSTRAP
        T.(['r_bootstrap_lr_mean_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r_bootstrap_lr_mean(:, ii);
        T.(['r_bootstrap_cs_mean_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r_bootstrap_cs_mean(:, ii);
        T.(['r_bootstrap_lr_std_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r_bootstrap_lr_std(:, ii);
        T.(['r_bootstrap_cs_std_', strrep(num2str(trial_fractions(ii)), '.', '_')]) = r_bootstrap_cs_std(:, ii);
    end
end
T.r_rand = r_rand;
T.r_synth = r_synth;
T.p_rand = p_rand;
T.p_synth = p_synth;
T.yesses = yesses;

%% Clean up table
% numeric_columns = {
%     'min_freq', 'max_freq', 'n_bins', 'duration', 'n_trials', 'n_bins_filled_mean', ...
%     'n_bins_filled_var', 'bin_prob', 'amplitude_mean', 'amplitude_var', 'bin_rep', 'gamma'};
% for ii = 1:length(numeric_columns)
%     if any(strcmp(T.Properties.VariableNames, numeric_columns{ii}))
%         T.(numeric_columns{ii}) = str2double(T.(numeric_columns{ii}));
%     end
% end

%% Visualize results 

% View table in a figure
view_table(sortrows(T, 'r_lr_bins_1', 'descend'))

% if comparing trial fractions
if length(trial_fractions) > 1
    r_viz(T)
end

%% Saving Results

% Save the reconstruction waveforms
if PUBLISH
    for ii = 1:height(T)
        this_filepath = pathlib.join(DATA_DIR, [T.experiment_name{ii}, '.wav']);
        this_binrep = rescale(T.reconstructions_cs_1{ii}, -20, 0);
        this_spectrum = stimgen.binnedrepr2spect(this_binrep);
        this_spectrum(f(1:length(this_spectrum),1) > 13e3) = -20;
        this_waveform = stimgen.synthesize_audio(this_spectrum, stimgen.get_nfft());
        audiowrite(this_filepath, this_waveform, stimgen.Fs);
    end
end
