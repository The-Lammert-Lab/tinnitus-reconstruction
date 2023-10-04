
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/patient-data/';
config_path = fullfile(data_dir,'4_config_ER.yaml');
project_dir = pathlib.strip(mfilename('fullpath'), 3);

[mult, binrange] = adjust_resynth('config_file', config_path, ...
    'data_dir', data_dir, 'save', true, 'mult_range', [0, 0.1])

% Pass parameters to follow_up and answer the questions.
follow_up('config_file', config_path, 'data_dir', data_dir, ...
    'mult', mult, 'binrange', binrange, 'survey', false, 'version', 2);