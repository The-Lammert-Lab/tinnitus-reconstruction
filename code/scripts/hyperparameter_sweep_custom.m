%% Hyperparameter Sweep Custom Stimulus
% Evaluate hyperparameters of stimulus generation
% using the 'custom' stimulus paradigm.
% Evaluate hyperparameters over different
% target signals.

%% Preamble

% Script-level parameters
RUN         = true;
OVERWRITE   = false;
VERBOSE     = true;

% Set random number seed
rng(1234);

% Create output directory
project_dir = pathlib.strip(mfilename('fullpath'), 3);
data_dir = pathlib.join(project_dir, 'data', 'stimulus-hyperparameter-sweep');
% data_dir = '/home/alec/data/stimulus-hyperparameter-sweep';
mkdir(data_dir)

% Target signals
sound_dir = pathlib.join(project_dir, 'data', 'sounds');
data_files = {
    'ATA_Tinnitus_Buzzing_Tone_1sec.wav', ...
    'ATA_Tinnitus_Electric_Tone_1sec.wav', ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav', ...
    'ATA_Tinnitus_Static_Tone_1sec.wav', ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav'
};
data_names = {
    'buzzing', ...
    'electric', ...
    'roaring', ...
    'static', ...
    'teakettle'
};
s = cell(5, 1);
f = cell(5, 1);
for ii = 1:length(data_files)
    [s{ii}, f{ii}] = wav2spect(pathlib.join(sound_dir, data_files{ii}));
end
target_signal = [s{:}];
f = [f{:}];

% Stimulus generation methods
stimulus_generation_methods = {
    BernoulliStimulusGeneration(), ...
    BrimijoinStimulusGeneration(), ...
    GaussianNoiseNoBinsStimulusGeneration(), ...
    GaussianNoiseStimulusGeneration(), ...
    GaussianPriorStimulusGeneration(), ...
    UniformNoiseNoBinsStimulusGeneration(), ...
    UniformNoiseStimulusGeneration(), ...
    UniformPriorStimulusGeneration(), ...
    PowerDistributionStimulusGeneration() ...
};
stimulus_generation_names = cellfun(@(x) strrep(class(x), 'StimulusGeneration', ''), stimulus_generation_methods, 'UniformOutput', false);

% Reconstruction methods
reconstruction_methods = {
    'cs', ...
    'cs-nb', ...
    'linreg'
}; 

%% Precompute all stimuli

% Stimulus generation options (default)
options = struct;
options.min_freq            = 100;
options.max_freq            = 22e3;
options.duration            = size(target_signal, 1) / options.max_freq;
options.n_trials            = 2e3;

% Hyperparameters
options.n_bins_filled_mean  = 1;
options.n_bins_filled_var   = 1;
options.n_bins              = 100;
options.amplitude_values    = 1;
options.amplitude_mean      = 1;
options.amplitude_var       = 1;
options.bin_prob            = 1;
options.distribution        = [];

for ii = 1:length(stimulus_generation_methods)
    stimulus_generation_methods{ii} = stimulus_generation_methods{ii}.from_config(options);
end

% Check to make sure all hparams are accounted for
a = properties(stimulus_generation_methods{1});
for ii = 2:length(stimulus_generation_methods)
    a = [a; properties(stimulus_generation_methods{ii})];
end
all_properties = unique(a);

for ii = 1:length(all_properties)
    assert(any(strcmp(all_properties{ii}, fieldnames(options))), ['[ERROR] stimulus parameter ', all_properties{ii}, ' not found in `options`.'])
end

% Tunable hyperparameters specific to different stimulus generation methods
hparams = struct;

%% Bernoulli
stimuli = stimulus_generation_methods{1};

% Numerical parameters
n_bins = [30, 100, 200];
bin_prob = [0.1, 0.3, 0.5, 0.8];
hparams.n_bins = n_bins;
hparams.bin_prob = bin_prob;

% Collect all combinations of numerical parameters
num_param_sets = allcomb(n_bins, bin_prob);

% Create the files
for ii = 1:size(num_param_sets, 1)
    stimuli.n_bins = num_param_sets(ii, 1);
    stimuli.bin_prob = num_param_sets(ii, 2);
    write_stimuli(data_dir, stimulus_generation_names{1}, stimuli, OVERWRITE, VERBOSE);
end

%% Brimijoin
stimuli = stimulus_generation_methods{2};

% Numerical parameters
amplitude_values = linspace(-20, 0, 6);
hparams.amplitude_values = amplitude_values';

% Create the file and save the stimuli
for ii = 1:length(n_bins)
    stimuli.n_bins = n_bins(ii);
    stimuli.amplitude_values = amplitude_values;
    write_stimuli(data_dir, stimulus_generation_names{2}, stimuli, OVERWRITE, VERBOSE);
end

%% Gaussian Noise No Bins
stimuli = stimulus_generation_methods{3};

% Numerical parameters
amplitude_mean = [-10];
amplitude_var = [5, 10, 20];
hparams.amplitude_mean = amplitude_mean;
hparams.amplitude_var = amplitude_var;

% Collect all combinations of numerical parameters
num_param_sets = allcomb(amplitude_mean, amplitude_var);

% Create the files and stimuli
for ii = 1:size(num_param_sets, 1)
    stimuli.amplitude_mean = num_param_sets(ii, 1);
    stimuli.amplitude_var = num_param_sets(ii, 2);
    write_stimuli(data_dir, stimulus_generation_names{3}, stimuli, OVERWRITE, VERBOSE);
end

%% Gaussian Noise
stimuli = stimulus_generation_methods{4};

% Collect all combinations of numerical parameters
num_param_sets = allcomb(n_bins, amplitude_mean, amplitude_var);

% Create the files and stimuli
% All hyperparameters are the same as the method above
for ii = 1:size(num_param_sets, 1)  
    stimuli.n_bins = num_param_sets(ii, 1);
    stimuli.amplitude_mean = num_param_sets(ii, 2);
    stimuli.amplitude_var = num_param_sets(ii, 3);
    write_stimuli(data_dir, stimulus_generation_names{4}, stimuli, OVERWRITE, VERBOSE);
end

%% Gaussian Prior
stimuli = stimulus_generation_methods{5};

% Numerical parameters
n_bins_filled_mean      = [1, 3, 10, 20, 30];
n_bins_filled_var       = [0.01, 1, 3, 10];
hparams.n_bins_filled_mean = n_bins_filled_mean;
hparams.n_bins_filled_var = n_bins_filled_var;

% Collect all combinations of numerical parameters
num_param_sets = allcomb(n_bins, n_bins_filled_mean, n_bins_filled_var);

% Remove combinations of parameters where the s.e.m. is > 1
num_param_sets((num_param_sets(:, 2) ./ num_param_sets(:, 3)) <= 1.5, :) = [];

% Create files and stimuli
for ii = 1:size(num_param_sets, 1)
    stimuli.n_bins = num_param_sets(ii, 1);
    stimuli.n_bins_filled_mean = num_param_sets(ii, 2);
    stimuli.n_bins_filled_var = num_param_sets(ii, 3);
    write_stimuli(data_dir, stimulus_generation_names{5}, stimuli, OVERWRITE, VERBOSE);
end

%% Uniform Noise No Bins
stimuli = stimulus_generation_methods{6};
write_stimuli(data_dir, stimulus_generation_names{6}, stimuli, OVERWRITE, VERBOSE);

%% Uniform Noise
stimuli = stimulus_generation_methods{7};

for ii = 1:length(n_bins)
    stimuli.n_bins = n_bins(ii);
    write_stimuli(data_dir, stimulus_generation_names{7}, stimuli, OVERWRITE, VERBOSE);
end

%% Uniform Prior
stimuli = stimulus_generation_methods{8};

for ii = 1:length(n_bins)
    stimuli.n_bins = n_bins(ii);
    write_stimuli(data_dir, stimulus_generation_names{8}, stimuli, OVERWRITE, VERBOSE);
end

%% Power Distribution
stimuli = stimulus_generation_methods{9};
stimuli = stimuli.from_file();
hparams.distribution = [];

for ii = 1:length(n_bins)
    stimuli.n_bins = n_bins(ii);
    write_stimuli(data_dir, stimulus_generation_names{9}, stimuli, OVERWRITE, VERBOSE, {'distribution'});
end

%% Collect all stimuli files
% Read the stimuli filenames.
% Collect the parameters in a data table
% and the stimuli filepaths in a struct.

% Collect all the file information
stimuli_files = dir(pathlib.join(data_dir, 'stimuli-spect--*.csv'));

% Strip the file ending, e.g., '.csv'
stimuli_filenames = cellfun(@(x) x(1:end-4), {stimuli_files.name}, 'UniformOutput', false);

%% Compute the responses and reconstructions

for ii = 1:length(stimuli_files)
    % Read the stimuli file
    this_stimulus_filepath = pathlib.join(stimuli_files(ii).folder, stimuli_files(ii).name);
    this_stimulus = csvread(this_stimulus_filepath);

    % For each target signal, compute the responses
    for qq = 1:length(data_names)
        % Create the response file if it doesn't exist
        this_response_filepath = [this_stimulus_filepath(1:end-4), '&&target_signal=', data_names{qq}, '.csv'];
        this_response_filepath = strrep(this_response_filepath, 'stimuli-spect--', 'responses--');

        % Get the responses
        % Either load from file or generate and then save to file
        if OVERWRITE
            corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_response_filepath]);
            [y, ~] = subject_selection_process(target_signal(:, qq), this_stimulus');
            csvwrite(this_response_filepath, y);
        elseif isfile(this_response_filepath)
            corelib.verb(VERBOSE, 'INFO', [this_response_filepath, ' exists, loading...'])
            y = csvread(this_response_filepath);
        else
            corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_response_filepath]);
            [y, ~] = subject_selection_process(target_signal(:, qq), this_stimulus');
            csvwrite(this_response_filepath, y);
        end

        % Get the reconstructions
        % Either load from file or generate and then save to file
        this_reconstruction_filepath = strrep(this_response_filepath, 'responses--', 'reconstruction--');

        if OVERWRITE
            corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_reconstruction_filepath]);
            reconstruction_cs = cs(y, this_stimulus');
            reconstruction_cs_nb = cs_no_basis(y, this_stimulus');
            reconstruction_linear = gs(y, this_stimulus');
            this_reconstruction = [reconstruction_cs, reconstruction_cs_nb, reconstruction_linear];
            csvwrite(this_reconstruction_filepath, this_reconstruction);
        elseif isfile(this_reconstruction_filepath)
            corelib.verb(VERBOSE, 'INFO', [this_reconstruction_filepath, ' exists, loading...']);
            this_reconstruction = csvread(this_reconstruction_filepath);
        else
            corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_reconstruction_filepath]);
            reconstruction_cs = cs(y, this_stimulus');
            reconstruction_cs_nb = cs_no_basis(y, this_stimulus');
            reconstruction_linear = gs(y, this_stimulus');
            this_reconstruction = [reconstruction_cs, reconstruction_cs_nb, reconstruction_linear];
            csvwrite(this_reconstruction_filepath, this_reconstruction);
        end
        
    end % qq
end % ii

%% Collect results into a table

% Collect all the file information
reconstruction_files = dir(pathlib.join(data_dir, 'reconstruction--*.csv'));

% Strip the file ending, e.g., '.csv'
reconstruction_filenames = cellfun(@(x) x(1:end-4), {reconstruction_files.name}, 'UniformOutput', false);

% Gather the data into a data table
T = collect_parameters(reconstruction_filenames);
T = sortrows(T, 'ID');
% Calculate r2 values
r2 = NaN(length(reconstruction_files), 3);
for ii = 1:length(reconstruction_files)
    this_filename = pathlib.join(reconstruction_files(ii).folder, reconstruction_files(ii).name);
    this_reconstruction = csvread(this_filename);
    r2(ii, :) = corr(target_signal(:, strcmp(T.target_signal(ii), data_names)), this_reconstruction);
end
r2 = r2.^2;

% Add r2 values to table
T = addvars(T, r2(:, 1), r2(:, 2), r2(:, 3), 'NewVariableNames', {'r2_cs', 'r2_cs_nb', 'r2_linear'});

% Clean up table
numeric_columns = {
    'min_freq', 'max_freq', 'n_bins', 'duration', 'n_trials', 'n_bins_filled_mean', ...
    'n_bins_filled_var', 'bin_prob', 'amplitude_mean', 'amplitude_var'};
for ii = 1:length(numeric_columns)
    T.(numeric_columns{ii}) = str2double(T.(numeric_columns{ii}));
end

% Compute mean and standard deviation
% over target signals
r2_column_names = {'r2_cs', 'r2_cs_nb', 'r2_linear'};
T2 = groupsummary(T, ...
    {'method', 'n_bins_filled_mean', 'n_bins', 'n_bins_filled_var', 'bin_prob', 'amplitude_values', 'amplitude_mean', 'amplitude_var'}, ...
    {'mean', 'std'}, ...
    r2_column_names);

% Compute standard error of the mean
for ii = 1:length(r2_column_names)
    T2.(['sem_', r2_column_names{ii}]) = T2.(['std_', r2_column_names{ii}]) ./ T2.(['mean_' r2_column_names{ii}]);
end

T2 = sortrows(T2, 'mean_r2_cs', 'descend');
T2_skinny = T2(:, {'method', 'n_bins', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'amplitude_mean', 'amplitude_var', 'mean_r2_cs', 'sem_r2_cs', 'mean_r2_linear', 'sem_r2_linear'});

T3 = T(strcmp(T.method, 'GaussianNoiseNoBins') & T.amplitude_mean == -10 & T.amplitude_var == 10, :);
% T3 = T(strcmp(T.method, 'custom') & T.n_bins_filled_mean == 20 & T.n_bins_filled_var == 3, :);

% T4 = T(strcmp(T.method, 'white_no_bins'), :);

T5 = T;
T5(strcmp(T5.target_signal, 'teakettle'), :) = [];

T6 = groupsummary(T5, ...
    {'method', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'amplitude_values'}, ...
    {'mean', 'std'}, ...
    r2_column_names);
T6 = sortrows(T6, 'mean_r2_cs', 'descend');
for ii = 1:length(r2_column_names)
    T6.(['sem_', r2_column_names{ii}]) = T6.(['std_', r2_column_names{ii}]) ./ T6.(['mean_' r2_column_names{ii}]);
end
T6_skinny = T6(:, {'method', 'n_bins_filled_mean', 'n_bins_filled_var', 'mean_r2_cs', 'sem_r2_cs'});