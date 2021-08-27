%% Generate stimuli examples for different parameter values\
%  and save them to data/.

config = ReadYaml('configs/config.yaml');

n_bins = [1000];
bin_duration = [1];
% prob_f = [0.20,0.25,0.30,0.35,0.40];
n_bins_filled_mean = [10, 30, 100, 300];
n_bins_filled_var = [1, 3, 10, 30];

hparam_matrix = allcomb(n_bins_filled_mean, n_bins_filled_var);

for ii = 1:size(hparam_matrix, 1)
    % Create the directory
    subdir_name = ['stimuli_examples__', ...
        'mean=', num2str(hparam_matrix(ii, 1)), '_', ...
        'var=', num2str(hparam_matrix(ii, 2))];
    directory_path = pathlib.join('..', '..', 'data', subdir_name);
    mkdir(directory_path);

    % Generate the config file
    new_config = config;
    new_config.n_bins = 1000;
    new_config.n_bins_filled_mean = hparam_matrix(ii, 1);
    new_config.n_bins_filled_var = hparam_matrix(ii, 2);

    % Save the config file to the directory
    yaml.WriteYaml(pathlib.join(directory_path, 'config.yaml'), new_config);

    % Generate stimuli and save to the directory
    for qq = 1:5
        % Generate new stimuli
        [stim, Fs, nfft] = generate_stimuli(...
                'min_freq', new_config.min_freq, ...
                'max_freq', new_config.max_freq, ...
                'n_bins', new_config.n_bins, ...
                'bin_duration', new_config.bin_duration, ...
                'n_bins_filled_mean', new_config.n_bins_filled_mean, ...
                'n_bins_filled_var', new_config.n_bins_filled_var);
        % Save to the directory
        filename = ['stimuli_', num2str(qq), '.wav'];
        audiowrite(pathlib.join(directory_path, filename), stim, Fs);
    end
end