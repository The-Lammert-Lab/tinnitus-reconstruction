DATA_DIR = '/home/alec/code/tinnitus-project/code/experiment/Data/data_pilot';


% Directory containing the data
this_dir = dir(pathlib.join(DATA_DIR, '*.yaml'));

% Get array of structs of config files
config_filenames = {this_dir.name};

% Container for config IDs
config_ids = cell(length(this_dir), 1);

%% Convert subject IDs into a data table

for i = 1:length(this_dir)
    config_file = this_dir(i);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    config_ids{i} = config.subjectID;
end

T = collect_parameters(config_ids);
T.config_filename = config_filenames';

%% Compute the reconstructions

trial_fractions = [0.3, 0.5, 1.0];

% Container for r^2 values
r2 = zeros(length(config_ids), length(trial_fractions));

% Container for reconstructions
reconstructions = cell(length(config_ids), 1);

% Compute the reconstructions
for i = 1:height(T)
    config_file = this_dir(i);
    config = parse_config(pathlib.join(config_file.folder, config_file.name));
    if strcmp(T.subject{i}, 'AL')
        reconstructions{i} = get_reconstruction('config', config, ...
                                        'preprocessing', {'bins', 'bit flip'}, ...
                                        'method', 'cs', ...
                                        'verbose', true);
    else
        reconstructions{i} = get_reconstruction('config', config, ...
                                            'preprocessing', {}, ...
                                            'method', 'cs', ...
                                            'verbose', true);
    end
end
