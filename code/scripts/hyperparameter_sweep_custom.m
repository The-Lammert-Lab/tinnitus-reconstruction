% ### hyperparameter_sweep_custom
% 
% Hyperparameter Sweep Custom Stimulus
% 
% Evaluate hyperparameters of stimulus generation using the 'custom' stimulus paradigm.
% Evaluate hyperparameters over different target signals.
% 
% End of documentation

%% Preamble

% Script-level parameters
RUN         = true;
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

% Numerical properties
numeric_columns = {
    'min_freq', 'max_freq', 'n_bins', 'duration', 'n_trials', 'n_bins_filled_mean', ...
    'n_bins_filled_var', 'bin_prob', 'amplitude_mean', 'amplitude_var', 'bin_rep', 'gamma', ...
    'min_bins', 'max_bins', 'Fs'};

%% Precompute all stimuli

% Stimulus generation options (default)
options = struct;
options.min_freq            = 100;
options.max_freq            = 13e3;
options.Fs                  = 44100;
options.duration            = 2 * size(target_signal, 1) / options.Fs;
options.n_trials            = 10;

% Hyperparameters
options.n_bins_filled_mean  = 1;
options.n_bins_filled_var   = 1;
options.n_bins              = 8;
options.amplitude_values    = 1;
options.amplitude_mean      = 1;
options.amplitude_var       = 1;
options.bin_prob            = 1;
options.max_bins            = 1;
options.min_bins            = 1;
options.distribution        = [];
options.distribution_filepath = pathlib.join(project_dir, 'code/stimulus_generation/@PowerDistributionStimulusGeneration/distribution.mat');

for ii = 1:length(stimulus_generation_methods)
    options.stimuli_type = stimulus_generation_names{ii};
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
n_bins = 8;
bin_prob = [0.1, 0.3, 0.5, 0.8];
hparams.n_bins = n_bins;
hparams.bin_prob = bin_prob;

% Collect all combinations of numerical parameters
num_param_sets = allcomb(n_bins, bin_prob);

% Create the files
for ii = 1:size(num_param_sets, 1)
    stimuli.n_bins = num_param_sets(ii, 1);
    stimuli.bin_prob = num_param_sets(ii, 2);
    write_stimuli(data_dir, stimulus_generation_names{1}, stimuli, false, VERBOSE, {}, {'bins'});
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
    write_stimuli(data_dir, stimulus_generation_names{2}, stimuli, false, VERBOSE, {}, {'bins'});
end

%% Gaussian Noise No Bins
stimuli = stimulus_generation_methods{3};

% Numerical parameters
amplitude_mean = -35;
amplitude_var = [5, 10, 20];
hparams.amplitude_mean = amplitude_mean;
hparams.amplitude_var = amplitude_var;

% Collect all combinations of numerical parameters
num_param_sets = allcomb(amplitude_mean, amplitude_var);

% Create the files and stimuli
for ii = 1:size(num_param_sets, 1)
    stimuli.amplitude_mean = num_param_sets(ii, 1);
    stimuli.amplitude_var = num_param_sets(ii, 2);
    write_stimuli(data_dir, stimulus_generation_names{3}, stimuli, false, VERBOSE, {}, {'bins'});
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
    write_stimuli(data_dir, stimulus_generation_names{4}, stimuli, false, VERBOSE, {}, {'bins'});
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

% Remove combinations of parameters where n_bins_filled_mean / n_bins >= 2/3
num_param_sets((num_param_sets(:, 2) ./ num_param_sets(:, 1)) >= 2/3, :) = [];

% Remove combinations of parameters where the s.e.m. is > 1
num_param_sets((num_param_sets(:, 2) ./ num_param_sets(:, 3)) <= 1.5, :) = [];

% Create files and stimuli
for ii = 1:size(num_param_sets, 1)
    stimuli.n_bins = num_param_sets(ii, 1);
    stimuli.n_bins_filled_mean = num_param_sets(ii, 2);
    stimuli.n_bins_filled_var = num_param_sets(ii, 3);
    write_stimuli(data_dir, stimulus_generation_names{5}, stimuli, false, VERBOSE, {}, {'bins'});
end

%% Uniform Noise No Bins
stimuli = stimulus_generation_methods{6};
write_stimuli(data_dir, stimulus_generation_names{6}, stimuli, false, VERBOSE, {}, {'bins'});

%% Uniform Noise
stimuli = stimulus_generation_methods{7};

for ii = 1:length(n_bins)
    stimuli.n_bins = n_bins(ii);
    write_stimuli(data_dir, stimulus_generation_names{7}, stimuli, false, VERBOSE, {}, {'bins'});
end

%% Uniform Prior
stimuli = stimulus_generation_methods{8};

% Numerical parameters
% min_bins = [1, 3, 10, 20, 30];
% max_bins = [10, 20, 30, 50];
min_bins = [1, 2, 4];
max_bins = [2, 4, 6, 8];
hparams.min_bins = min_bins;
hparams.max_bins = max_bins;

% Collect all combinations of numerical parameters
num_param_sets = allcomb(n_bins, min_bins, max_bins);

% Remove combinations of parameters where min_bins > max_bins
num_param_sets(num_param_sets(:, 2) > num_param_sets(:, 3), :) = [];

for ii = 1:size(num_param_sets, 1)
    stimuli.n_bins      = num_param_sets(ii, 1);
    stimuli.min_bins    = num_param_sets(ii, 2);
    stimuli.max_bins    = num_param_sets(ii, 3);
    write_stimuli(data_dir, stimulus_generation_names{8}, stimuli, false, VERBOSE, {}, {'bins'});
end

%% Power Distribution
stimuli = stimulus_generation_methods{9};
stimuli = stimuli.from_file();
hparams.distribution = [];

for ii = 1:length(n_bins)
    stimuli.n_bins = n_bins(ii);
    write_stimuli(data_dir, stimulus_generation_names{9}, stimuli, false, VERBOSE, {'distribution', 'distribution_filepath'}, {'bins'});
end

% return

if RUN

    %% Reconstruction across the Bin Representation
    %   Collect all stimuli files.
    %   Read the stimuli filenames.
    %   Collect the parameters into a data table,
    %   and the stimuli filepaths into a struct.

    % Collect all file information
    stimuli_files_binrep = dir(pathlib.join(data_dir, 'stimuli-binrep--*.csv'));

    % Remove all files with 0 bytes (empty CSVs)
    stimuli_files_binrep(~logical([stimuli_files_binrep.bytes])) = [];

    % Remove all files with 'NoBins' in the name
    stimuli_files_binrep(strcmp('NoBins', {stimuli_files_binrep.name})) = [];

    % Strip the file ending, e.g., '.csv'
    stimuli_filenames_binrep = cellfun(@(x) x(1:end-4), {stimuli_files_binrep.name}, 'UniformOutput', false);

    % Compute the responses and reconstructions

    for ii = 1:length(stimuli_files_binrep)
        % Read the stimuli file
        this_stimulus_binrep_filepath = pathlib.join(stimuli_files_binrep(ii).folder, stimuli_files_binrep(ii).name);
        this_stimulus_binrep = csvread2(this_stimulus_binrep_filepath);

        % Get the bins and stimuli object
        [stimuli, property_struct] = stimuli_data_from_filename(options, stimuli_filenames_binrep{ii}, stimulus_generation_methods, stimulus_generation_names, numeric_columns);
        stimuli.duration = size(target_signal, 1) * 2 / stimuli.get_fs();
        [B, ~, ~] = stimuli.get_freq_bins();

        %% For each target signal, compute the responses
        for qq = 1:length(data_names)
            % Extract properties from the stimulus binrep filepath
            property_struct = str2prop(stimuli_filenames_binrep{ii});
            if contains(fieldnames(property_struct), 'n_bins')
                g = get_gamma(property_struct.n_bins);
            else
                g = get_gamma(8);
            end

            % Create the response file if it doesn't exist
            this_response_binrep_filepath = [this_stimulus_binrep_filepath(1:end-4), '&&target_signal=', data_names{qq}, '&&bin_rep=', num2str(1), '&&gamma=', num2str(g), '.csv'];
            this_response_binrep_filepath = strrep(this_response_binrep_filepath, 'stimuli-binrep--', 'responses-binrep--');

            % Get the responses
            % Either load from file, or generate an then save to file
            if isfile(this_response_binrep_filepath)
                corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_response_binrep_filepath, ' exists, loading...']);
                y = csvread2(this_response_binrep_filepath);
            else
                [y, ~] = subject_selection_process(spect2binnedrepr(target_signal(:, qq)', B), this_stimulus_binrep');
                writematrix(y, this_response_binrep_filepath);
            end

            % Get the reconstructions
            % Either load from file or generate and then save to file
            this_reconstruction_binrep_filepath = strrep(this_response_binrep_filepath, 'responses-binrep--', 'reconstruction-binrep--');

            if isfile(this_reconstruction_binrep_filepath)
                corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_reconstruction_binrep_filepath, ' exists, loading...']);
                this_reconstruction = csvread2(this_reconstruction_binrep_filepath);
            else
                corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_reconstruction_binrep_filepath]);
                reconstruction_cs = cs(y, this_stimulus_binrep', g);
                reconstruction_cs_nb = cs_no_basis(y, this_stimulus_binrep', g);
                reconstruction_linear = gs(y, this_stimulus_binrep');
                this_reconstruction = [reconstruction_cs, reconstruction_cs_nb, reconstruction_linear];
                writematrix(this_reconstruction, this_reconstruction_binrep_filepath);
            end
        end
    end

    %% % %% Reconstruction across the Spectrum
    % %   Collect all stimuli files
    % %   Read the stimuli filenames.
    % %   Collect the parameters in a data table
    % %   and the stimuli filepaths in a struct.

    % % Collect all the file information
    % stimuli_files = dir(pathlib.join(data_dir, 'stimuli-spect--*.csv'));

    % % Strip the file ending, e.g., '.csv'
    % stimuli_filenames = cellfun(@(x) x(1:end-4), {stimuli_files.name}, 'UniformOutput', false);

    % % Compute the responses and reconstructions

    % for ii = 1:length(stimuli_files)
    %     % Read the stimuli file
    %     this_stimulus_filepath = pathlib.join(stimuli_files(ii).folder, stimuli_files(ii).name);
    %     this_stimulus = csvread2(this_stimulus_filepath);

    %     % For each target signal, compute the responses
    %     for qq = 1:length(data_names)
    %         % Extract properties from the stimulus binrep filepath
    %         property_struct = str2prop(this_stimulus_filepath);
    %         if contains(fieldnames(property_struct), 'n_bins')
    %             g = get_gamma(property_struct.n_bins);
    %         else
    %             g = get_gamma(100);
    %         end

    %         % Create the response file if it doesn't exist
    %         this_response_filepath = [this_stimulus_filepath(1:end-4), '&&target_signal=', data_names{qq}, '&&bin_rep=', num2str(0), '&&gamma=', num2str(g), '.csv'];
    %         this_response_filepath = strrep(this_response_filepath, 'stimuli-spect--', 'responses--');

    %         % Get the responses
    %         % Either load from file or generate and then save to file
    %         if isfile(this_response_filepath)
    %             corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_response_filepath, ' exists, loading...'])
    %             y = csvread2(this_response_filepath);
    %         else
    %             corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_response_filepath]);
    %             [y, ~] = subject_selection_process(target_signal(:, qq), this_stimulus');
    %             writematrix(y, this_response_filepath);
    %         end

    %         % Get the reconstructions
    %         % Either load from file or generate and then save to file
    %         this_reconstruction_filepath = strrep(this_response_filepath, 'responses--', 'reconstruction--');

    %         if isfile(this_reconstruction_filepath)
    %             corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], [this_reconstruction_filepath, ' exists, loading...']);
    %             this_reconstruction = csvread2(this_reconstruction_filepath);
    %         else
    %             corelib.verb(VERBOSE, ['INFO ', char(datetime('now'))], ['Creating file: ', this_reconstruction_filepath]);
    %             reconstruction_cs = cs(y, this_stimulus', g);
    %             reconstruction_cs_nb = cs_no_basis(y, this_stimulus', g);
    %             reconstruction_linear = gs(y, this_stimulus');
    %             this_reconstruction = [reconstruction_cs, reconstruction_cs_nb, reconstruction_linear];
    %             writematrix(this_reconstruction, this_reconstruction_filepath);
    %         end
        
    %         corelib.verb(VERBOSE, ['INFO ' char(datetime('now'))], ['finished ', num2str(length(data_names) * (ii-1) + qq), '/', num2str(length(stimuli_files) * length(data_names))])
    %     end % qq
    % end % ii
end % RUN

%% Collect results into a table

% Collect all the file information
% reconstruction_files = [dir(pathlib.join(data_dir, 'reconstruction--*.csv')); dir(pathlib.join(data_dir, 'reconstruction-binrep--*.csv'))];
reconstruction_files = [dir(pathlib.join(data_dir, 'reconstruction-binrep--*.csv'))];

% Strip the file ending, e.g., '.csv'
reconstruction_filenames = cellfun(@(x) x(1:end-4), {reconstruction_files.name}, 'UniformOutput', false);

% Gather the data into a data table
T = collect_parameters(reconstruction_filenames);
T = sortrows(T, 'ID');
% Calculate r2 values
r2 = NaN(length(reconstruction_files), 3);
for ii = 1:length(reconstruction_files)

    % Read the reconstruction file
    this_filename = pathlib.join(reconstruction_files(ii).folder, reconstruction_files(ii).name);
    this_reconstruction = csvread2(this_filename);

    % Get the stimuli object
    [stimuli, property_struct] = stimuli_data_from_filename(options, reconstruction_filenames{ii}, stimulus_generation_methods, stimulus_generation_names, numeric_columns);

    % Get the target signal
    this_target_signal = target_signal(:, strcmp(T.target_signal(ii), data_names));
    
    if property_struct.bin_rep
        stimuli.duration = size(target_signal, 1) * 2 / stimuli.get_fs();
        B = stimuli.get_freq_bins();
        ts = spect2binnedrepr(this_target_signal', B);
    else
        ts = this_target_signal;
    end

    % Compute the r value
    r2(ii, :) = corr(ts(:), this_reconstruction);
end

% Compute the r2 value
r2 = r2.^2;

% Add r2 values to table
r2_column_names = {'r2_cs', 'r2_cs_nb', 'r2_linear', 'r2_diff'};
T = addvars(T, r2(:, 1), r2(:, 2), r2(:, 3), r2(:, 1) - r2(:, 3), 'NewVariableNames', r2_column_names);

% Clean up table
for ii = 1:length(numeric_columns)
    T.(numeric_columns{ii}) = str2double(T.(numeric_columns{ii}));
end

% Compute mean and standard deviation
% over target signals
T2 = groupsummary(T, ...
    {'stimuli_type', 'n_bins_filled_mean', 'n_bins', 'n_bins_filled_var', 'bin_prob', 'amplitude_values', 'amplitude_mean', 'amplitude_var', 'bin_rep'}, ...
    {'mean', 'std'}, ...
    r2_column_names);

% Compute standard error of the mean
for ii = 1:length(r2_column_names)
    T2.(['sem_', r2_column_names{ii}]) = T2.(['std_', r2_column_names{ii}]) ./ T2.(['mean_' r2_column_names{ii}]);
end

T2 = sortrows(T2, 'mean_r2_cs', 'descend');
T2(isnan(T2.mean_r2_cs), :) = [];
T2_skinny = T2(:, {'stimuli_type', 'bin_rep', 'n_bins', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'amplitude_mean', 'amplitude_var', 'mean_r2_cs', 'sem_r2_cs', 'mean_r2_linear', 'sem_r2_linear'});

T3 = T(strcmp(T.stimuli_type, 'GaussianNoiseNoBins') & T.amplitude_mean == -10 & T.amplitude_var == 10, :);
% T3 = T(strcmp(T.stimuli_type, 'custom') & T.n_bins_filled_mean == 20 & T.n_bins_filled_var == 3, :);

% T4 = T(strcmp(T.stimuli_type, 'white_no_bins'), :);


% Remove teakettle
T5 = T;
T5(strcmp(T5.target_signal, 'teakettle'), :) = [];

T6 = groupsummary(T5, ...
    {'stimuli_type', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'min_bins', 'max_bins', 'amplitude_values'}, ...
    {'mean', 'std'}, ...
    r2_column_names);
T6 = sortrows(T6, 'mean_r2_cs', 'descend');
for ii = 1:length(r2_column_names)
    T6.(['sem_', r2_column_names{ii}]) = T6.(['std_', r2_column_names{ii}]) ./ T6.(['mean_' r2_column_names{ii}]);
end
T6_skinny = T6(:, {'stimuli_type', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'min_bins', 'max_bins', 'mean_r2_cs', 'mean_r2_diff', 'sem_r2_cs', 'mean_r2_linear', 'sem_r2_linear'});


function [stimuli, property_struct] = stimuli_data_from_filename(options, filename, stimulus_generation_methods, stimulus_generation_names, numeric_columns)
    property_struct = str2prop(filename);
    field_names = fieldnames(property_struct);
    for ii = 1:length(field_names)
        options.(field_names{ii}) = property_struct.(field_names{ii});
    end

    property_struct = set_numeric_columns_of_struct(options, numeric_columns);
    stimuli = stimulus_generation_methods{strcmp(property_struct.stimuli_type, stimulus_generation_names)};
    stimuli = stimuli.from_config(property_struct);
end % function

function property_struct = set_numeric_columns_of_struct(property_struct, numeric_columns)
    for ww = 1:length(numeric_columns)
        if any(strcmp(numeric_columns{ww}, fieldnames(property_struct)))
            property_struct.(numeric_columns{ww}) = str2double(property_struct.(numeric_columns{ww}));
        end
    end
end % function