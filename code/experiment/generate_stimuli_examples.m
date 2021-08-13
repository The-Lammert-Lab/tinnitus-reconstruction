%% Generate stimuli examples for different parameter values\
%  and save them to data/.

config = ReadYaml('configs/config.yaml');

n_bins = [10, 30, 100, 300, 1000];
bin_duration = [0.3, 0.5, 0.75, 1];
prob_f = [0.2, 0.4, 0.6, 0.8];

hparam_matrix = allcomb(n_bins, bin_duration, prob_f);

for ii = 1:size(hparam_matrix, 1)
    % Create the directory
    subdir_name = ['stimuli_examples__', ...
        'n_bins=', num2str(hparam_matrix(ii, 1)), '_', ...
        'bin_duration=', num2str(hparam_matrix(ii, 2)), '_', ...
        'prob_f=', num2str(hparam_matrix(ii, 3))];
    directory_path = pathlib.join('..', '..', 'data', subdir_name);
    mkdir(directory_path);

    % Generate the config file
    new_config = config;
    new_config.n_bins = hparam_matrix(ii, 1);
    new_config.bin_duration = hparam_matrix(ii, 2);
    new_config.prob_f = hparam_matrix(ii, 3);

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
                'prob_f', new_config.prob_f);
        % Save to the directory
        filename = ['stimuli_', num2str(qq), '.wav'];
        audiowrite(pathlib.join(directory_path, filename), stim, Fs);
    end
end