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
data_dir = '/home/alec/data/stimulus-hyperparameter-sweep';
mkdir(data_dir)

% Target signals
sound_dir = '/home/alec/data/sounds/';
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
    [s{ii}, f{ii}] = wav2spect([sound_dir, data_files{ii}]);
end
target_signal = [s{:}];
f = [f{:}];

% Stimulus generation methods
stimulus_generation_methods = {
    'custom', ...
    'brimijoin', ...
    'white', ...
    'white-no-bins'
};

% Reconstruction methods
reconstruction_methods = {
    'cs', ...
    'cs-nb', ...
    'linreg'
}; 

%% Precompute all stimuli

% Stimulus generation options
options = struct;
options.min_freq            = 100;
options.max_freq            = 22e3;
options.bin_duration        = size(target_signal, 1) / options.max_freq;
options.n_trials            = 2e3;
options.n_bins_filled_mean  = 1;
options.n_bins_filled_var   = 1;
options.n_bins              = 100;
options.amplitude_values    = 1;

% Custom
stimuli = Stimuli(options);

% Numerical parameters
n_bins_filled_mean      = [1, 3, 10, 20, 30];
n_bins_filled_var       = [0.01, 1, 3, 10];

% Collect all combinations of numerical parameters
num_param_sets = allcomb(n_bins_filled_mean, n_bins_filled_var);

% Remove combinations of parameters where the s.e.m. is > 1
num_param_sets((num_param_sets(:, 1) ./ num_param_sets(:, 2)) <= 1.5, :) = [];

% % Remove combinations of parameters where the mean is too close to the maximum
% num_param_sets(num_param_sets(:, 1) ./ stimuli.n_bins >= 2/3, :) = [];

% Create the filename, which includes all the parameter values
% for the Stimulus object used to generate the stimuli
% Then generate the stimuli and save to the file.
for ii = 1:size(num_param_sets, 1)
    stimuli.n_bins_filled_mean = num_param_sets(ii, 1);
    stimuli.n_bins_filled_var = num_param_sets(ii, 2);
    this_filename = ['stimuli--', 'method=custom&&', prop2str(stimuli), '.csv'];
    this_filename = pathlib.join(data_dir, this_filename);
    this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');

    if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename)
        [stimuli_matrix, ~, spect_matrix] = stimuli.custom_generate_stimuli_matrix();
    end

    if ~OVERWRITE && isfile(this_filename)
        corelib.verb(VERBOSE, 'INFO', [this_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_filename])
        csvwrite(this_filename, stimuli_matrix);
    end

    if ~OVERWRITE && isfile(this_spect_filename)
        corelib.verb(VERBOSE, 'INFO', [this_spect_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_spect_filename])
        csvwrite(this_spect_filename, spect_matrix);
    end
end

% Brimijoin
stimuli = Stimuli(options);
stimuli.amplitude_values = linspace(-20, 0, 6);

% Create the files
this_filename = ['stimuli--', 'method=brimijoin&&', prop2str(stimuli), '.csv'];
this_filename = pathlib.join(data_dir, this_filename);
this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');

if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename)
    [stimuli_matrix, ~, spect_matrix] = stimuli.brimijoin_generate_stimuli_matrix();
end

if ~OVERWRITE && isfile(this_filename)
    corelib.verb(VERBOSE, 'INFO', [this_filename, ' exists, not recreating'])
else
    corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_filename])
    csvwrite(this_filename, stimuli_matrix);
end

if ~OVERWRITE && isfile(this_spect_filename)
    corelib.verb(VERBOSE, 'INFO', [this_spect_filename, ' exists, not recreating'])
else
    corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_spect_filename])
    csvwrite(this_spect_filename, spect_matrix);
end

% Bernoulli
stimuli = Stimuli(options);

% Numerical parameters
bin_prob = [0.1, 0.3, 0.5, 0.8];

% Create the files
for ii = 1:length(bin_prob)
    stimuli.bin_prob = bin_prob(ii);
    this_filename = ['stimuli--', 'method=bernoulli&&', prop2str(stimuli), '.csv'];
    this_filename = pathlib.join(data_dir, this_filename);
    this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');

    if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename)
        [stimuli_matrix, ~, spect_matrix] = stimuli.bernoulli_generate_stimuli_matrix();
    end

    if ~OVERWRITE && isfile(this_filename)
        corelib.verb(VERBOSE, 'INFO', [this_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_filename])
        csvwrite(this_filename, stimuli_matrix);
    end
    
    if ~OVERWRITE && isfile(this_spect_filename)
        corelib.verb(VERBOSE, 'INFO', [this_spect_filename, ' exists, not recreating'])
    else
        corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_spect_filename])
        csvwrite(this_spect_filename, spect_matrix);
    end
end


% White
stimuli = Stimuli(options);

% Create the files
this_filename = ['stimuli--', 'method=white&&', prop2str(stimuli), '.csv'];
this_filename = pathlib.join(data_dir, this_filename);
this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');

if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename)
    [stimuli_matrix, ~, spect_matrix] = stimuli.white_generate_stimuli_matrix();
end

if ~OVERWRITE && isfile(this_filename)
    corelib.verb(VERBOSE, 'INFO', [this_filename, ' exists, not recreating'])
else
    corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_filename])
    csvwrite(this_filename, stimuli_matrix);
end

if ~OVERWRITE && isfile(this_spect_filename)
    corelib.verb(VERBOSE, 'INFO', [this_spect_filename, ' exists, not recreating'])
else
    corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_spect_filename])
    csvwrite(this_spect_filename, spect_matrix);
end

% White No Bins
stimuli = Stimuli(options);

% Create the files
this_filename = ['stimuli--', 'method=white_no_bins&&', prop2str(stimuli), '.csv'];
this_filename = pathlib.join(data_dir, this_filename);
this_spect_filename = strrep(this_filename, 'stimuli--', 'stimuli-spect--');

if OVERWRITE || ~isfile(this_filename) || ~isfile(this_spect_filename)
    [stimuli_matrix, ~, spect_matrix] = stimuli.white_no_bins_generate_stimuli_matrix();
end

if ~OVERWRITE && isfile(this_filename)
    corelib.verb(VERBOSE, 'INFO', [this_filename, ' exists, not recreating'])
else
    corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_filename])
    csvwrite(this_filename, stimuli_matrix);
end

if ~OVERWRITE && isfile(this_spect_filename)
    corelib.verb(VERBOSE, 'INFO', [this_spect_filename, ' exists, not recreating'])
else
    corelib.verb(VERBOSE, 'INFO', ['Creating file: ', this_spect_filename])
    csvwrite(this_spect_filename, spect_matrix);
end


%% Collect all stimuli files
% Read the stimuli filenames.
% Collect the parameters in a data table
% and the stimuli filepaths in a struct.

% Collect all the file information
stimuli_files = dir(pathlib.join(data_dir, 'stimuli-spect--*.csv'));

% Strip the file ending, e.g., '.csv'
stimuli_filenames = cellfun(@(x) x(1:end-4), {stimuli_files.name}, 'UniformOutput', false);

% % Collect the parameters in a data table
% T = collect_parameters(stimuli_filenames);

% % Duplicate the rows of the data table
% % by the number of target signals to evaluate against
% T = T(repelem(1:height(T), length(data_names)), :);

% % Add in the target signals
% target_signal_table = table(data_names', 'VariableNames', {'target_signal'});
% inds = repmat(1:height(target_signal_table), height(T)/height(target_signal_table), 1);
% target_signal_table = target_signal_table(corelib.vectorise(inds'), :);
% T = [T, target_signal_table];

%% Compute the responses

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
            this_reconstruction = [cs(y, this_stimulus'), cs_no_basis(y, this_stimulus'), gs(y, this_stimulus')];
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
T.min_freq = str2double(T.min_freq);
T.max_freq = str2double(T.max_freq);
T.n_bins = str2double(T.n_bins);
T.bin_duration = str2double(T.bin_duration);
T.n_trials = str2double(T.n_trials);
T.n_bins_filled_mean = str2double(T.n_bins_filled_mean);
T.n_bins_filled_var = str2double(T.n_bins_filled_var);
T.bin_prob = str2double(T.bin_prob);

% Compute mean and standard deviation
% over target signals
r2_column_names = {'r2_cs', 'r2_cs_nb', 'r2_linear'};
T2 = groupsummary(T, ...
    {'method', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'amplitude_values'}, ...
    {'mean', 'std'}, ...
    r2_column_names);

% Compute standard error of the mean
for ii = 1:length(r2_column_names)
    T2.(['sem_', r2_column_names{ii}]) = T2.(['std_', r2_column_names{ii}]) ./ T2.(['mean_' r2_column_names{ii}]);
end

T2 = sortrows(T2, 'mean_r2_cs', 'descend');
T2_skinny = T2(:, {'method', 'n_bins_filled_mean', 'n_bins_filled_var', 'bin_prob', 'mean_r2_cs', 'sem_r2_cs'});

T3 = T(strcmp(T.method, 'custom') & T.n_bins_filled_mean == 20 & T.n_bins_filled_var == 3, :);

T4 = T(strcmp(T.method, 'white_no_bins'), :);

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
% % TODO:
% %   * Convert numerical columns to numerical data
% %   * Iterate through the saved stimuli and run the reconstructions
% %   * Collect the data in a big data table
% %   * Analyze results

% return
% % % Plot the parameter sets of n_bins_filled_mean vs n_bins_filled_var
% % fig = new_figure();
% % axis square
% % scatter(param_sets(:, 1), param_sets(:, 2))
% % xlabel('n bins filled mean')
% % ylabel('n bins filled var')
% % figlib.pretty()

% %% Run experiment

% params_to_do = [];

% % Check if any parameter sets have been evaluated before.
% % If so, skip them.
% for ii = 1:size(param_sets, 1)
%     file_ID =   ['n_bins_filled_mean=', num2str(param_sets(ii, 1)), '-', ...
%                 'n_bins_filled_var=', num2str(param_sets(ii, 2)), '-', ...
%                 'n_bins=', num2str(param_sets(ii, 3)), '-', ...
%                 'target_signal=', data_names{param_sets(ii, 4)}, ...
%                 '.csv'];
%     param_string = file_ID(1:end-4);
    
%     stimulus_filepath       = pathlib.join(data_dir, ['stimulus-', file_ID]);
%     response_filepath       = pathlib.join(data_dir, ['response-', file_ID]);
%     reconstruction_filepath = pathlib.join(data_dir, ['reconstruction-', file_ID]);

%     if OVERWRITE || ~(isfile(stimulus_filepath) && isfile(response_filepath) && isfile(reconstruction_filepath))
%         corelib.verb(VERBOSE, 'INFO', ['Output files containing parameter set #', num2str(ii), ': "', param_string, '"', ...
%                                        'unable to be acquired. Will reacquire.'])
%         params_to_do(end+1, :) = param_sets(ii, :);
%     else
%         corelib.verb(VERBOSE, 'INFO', ['Output files associated with parameter set #', num2str(ii), ': "', param_string, '" acquired.'])
%     end
% end

% corelib.verb(VERBOSE, 'INFO', [num2str(size(params_to_do, 1)), ' parameter sets to evaluate.'])

% % Run all parameter sets identified in `params_to_do`
% % progress_bar = ProgressBar(size(params_to_do, 1), 'IsParallel', true, 'Title', 'hyperparameter sweep');

% if RUN
%     % progress_bar.setup([], [], []);
%     for ii = progress(1:size(params_to_do, 1))
%     % parfor ii = 1:size(params_to_do, 1)
%         try
%             % Stimulus generation options
%             options = struct;
%             options.min_freq            = 100;
%             options.max_freq            = 22e3;
%             options.bin_duration        = size(target_signal, 1) / options.max_freq;
%             options.n_trials            = 2e3;
%             options.n_bins_filled_mean  = params_to_do(ii, 1);
%             options.n_bins_filled_var   = params_to_do(ii, 2);
%             options.n_bins              = params_to_do(ii, 3);
%             options.amplitude_values    = linspace(-20, 0, 6);

%             % Create stimulus generation object
%             stimuli = Stimuli(options);

%             % Generate the stimuli and response data
%             % using a model of subject decision process
%             [y, X] = stimuli.subject_selection_process(target_signal(:, params_to_do(ii, 4)), 'custom');

%             % Get the reconstruction using compressed sensing (with basis)
%             reconstruction = cs(y, X');
%             % Get the reconstruction using compressed sensing (no basis)
%             reconstruction_nb = cs_no_basis(y, X');

%             % Save to directory
%             file_ID =   ['n_bins_filled_mean=', num2str(param_sets(ii, 1)), '-', ...
%                         'n_bins_filled_var=', num2str(param_sets(ii, 2)), '-', ...
%                         'n_bins=', num2str(param_sets(ii, 3)), '-', ...
%                         'target_signal=', data_names{param_sets(ii, 4)}, ...
%                         '.csv'];
%             csvwrite(pathlib.join(data_dir, ['stimulus-', file_ID]), X);
%             csvwrite(pathlib.join(data_dir, ['response-', file_ID]), y);
%             csvwrite(pathlib.join(data_dir, ['reconstruction-', file_ID]), reconstruction);
%             csvwrite(pathlib.join(data_dir, ['reconstruction_nb-', file_ID]), reconstruction_nb);
%         catch
%             corelib.verb(VERBOSE, 'WARN', ['Failed to compute for parameter set: "', param_string, '".'])
%         end

%         % updateParallel([], pwd);
%     end 
%     % progress_bar.release();
% end

% % TODO

% %% Evaluation

% % Get reconstruction files
% file_glob = pathlib.join(data_dir, 'reconstruction*n_bins_filled_mean=*-n_bins_filled_var=*-n_bins=*-target_signal=*');
% file_glob_nb = pathlib.join(data_dir, 'reconstruction_nb*n_bins_filled_mean=*-n_bins_filled_var=*-n_bins=*-target_signal=*');
% [reconstructions, reconstruction_files] = collect_reconstructions(file_glob);
% [reconstructions_nb, reconstruction_files_nb] = collect_reconstructions(file_glob_nb);

% % Get the parameter values from the files
% pattern = 'n_bins_filled_mean=[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)-n_bins_filled_var=[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)-n_bins=[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)-target_signal=(\w*)';

% params = collect_parameters(reconstruction_files, pattern, 4);
% params_nb = collect_parameters(reconstruction_files_nb, pattern, 4);

% % Combine parameters using different bases
% basis = [true(size(params, 1), 1); false(size(params_nb, 1), 1)];

% % Convert to a data table
% T = cell2table([params; params_nb], 'VariableNames', {'n_bins_filled_mean', 'n_bins_filled_var', 'n_bins', 'target_signal'});
% T.n_bins_filled_mean = str2double(T.n_bins_filled_mean);
% T.n_bins_filled_var = str2double(T.n_bins_filled_var);
% T.n_bins = str2double(T.n_bins);

% % Add basis as new column
% T.basis = basis;

% % Add sum of reconstructions
% % T.sum_recon = [sum(reconstructions, 1)'; sum(reconstructions_nb, 1)'];

% % Compute reconstruction quality (r^2)

% % with basis
% r2 = zeros(size(params, 1), 1);
% for ii = 1:size(params, 1)
%     r2(ii) = corr(target_signal(:, strcmp(data_names, T.target_signal{ii})), reconstructions(:, ii));
% end

% % no basis
% r2_nb = zeros(size(params_nb, 1), 1);
% for ii = 1:size(params_nb, 1)
%     r2_nb(ii) = corr(target_signal(:, strcmp(data_names, T.target_signal{ii + size(params, 1)})), reconstructions_nb(:, ii));
% end

% T.r2 = [r2; r2_nb] .^2;

% % Remove rows with NaN r^2
% T(isnan(T.r2), :) = [];

% % All data
% T = T(strcmp(T.target_signal, 'buzzing') | strcmp(T.target_signal, 'roaring'), :);
% T = sortrows(T, 'r2', 'descend');

% % Grouping by n_bins_* and basis
% T2 = varfun(@mean, T, 'InputVariables', 'r2', 'GroupingVariables', {'n_bins_filled_mean', 'n_bins_filled_var', 'basis'});
% T2 = sortrows(T2, 'mean_r2', 'descend');

% % Grouping by target signal
% T3 = varfun(@mean, T, 'InputVariables', 'r2', 'GroupingVariables', {'target_signal', 'n_bins'});
% T3 = sortrows(T3, 'mean_r2', 'descend');

% % Grouping by target signal and basis
% T4 = varfun(@mean, T, 'InputVariables', 'r2', 'GroupingVariables', {'target_signal', 'basis'});
% T4 = sortrows(T4, 'mean_r2', 'descend');

% %% Visualization
% % return

% fig2 = new_figure();
% heatmap(T, 'n_bins_filled_mean', 'n_bins_filled_var', 'ColorVariable', 'r2', 'FontSize', 36)
% title('r^2 as a fcn of stimulus parameters')
% figlib.pretty('FontSize', 36)

% fig3 = new_figure();
% boxchart(categorical(T.basis), T.r2)
% xlabel('basis?')
% ylabel('r^2')
% title('basis vs. r^2')
% figlib.pretty('FontSize', 36);

% fig3a = new_figure();
% boxchart(categorical(T2.basis), T2.mean_r2)
% xlabel('basis?')
% ylabel('r^2')
% title('basis vs. mean r^2')
% figlib.pretty('FontSize', 36);

% % fig4 = new_figure();
% % scatter(T2.n_bins, T2.mean_r2)
% % xlabel('n bins')
% % ylabel('r^2')
% % title('number of bins vs. mean r^2')
% % figlib.pretty('FontSize', 36);

% % fig5 = new_figure();
% % heatmap(T4, 'n_bins_filled_mean', 'n_bins_filled_var', 'ColorVariable', 'r2', 'FontSize', 36)
% % title('r^2 as a fcn of stimulus parameters (n bins = 300)')
% % figlib.pretty('FontSize', 36)