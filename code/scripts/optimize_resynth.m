% Optimize resynthesis using grid search for mult and binrange params

% Change these as appropriate
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/resynth_test_data/';

% Setup variables
d = dir(pathlib.join(data_dir, '*.yaml'));
project_dir = pathlib.strip(mfilename('fullpath'), 3);
n_trials = 200;
metric = 'corr';
skip_subject_data = true;
n_bins_target = 32;

mult = linspace(0.001,1,100);
binrange = linspace(1,100,100);
hparams = allcomb(mult, binrange);

[buzzing_spect, ~] = wav2spect(fullfile(project_dir,'code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav'));
[roaring_spect, ~] = wav2spect(fullfile(project_dir,'code/experiment/ATA/ATA_Tinnitus_Roaring_Tone_1sec.wav'));
buzzing_spect = 10*log10(buzzing_spect);
roaring_spect = 10*log10(roaring_spect);

target_spects = {buzzing_spect, 'buzzing'; roaring_spect, 'roaring'};

c = zeros(length(hparams),1);
best_wavs = cell(length(d)+length(target_spects),2);

figure
tiledlayout('flow')
for ii = 1:length(d)+length(target_spects)
    % Get config path and load config to determine target sound
    if ii <= length(d)
        config_path = pathlib.join(d(ii).folder, d(ii).name);
        config = parse_config(config_path);
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);

        if skip_subject_data
            continue
        end
        % Read in target sound b/c configs have paths from different machines
        target_ind = find(contains(target_spects(:,2),config.target_signal_name));
        reconstruction = get_reconstruction('config', config, 'method', 'linear', ...
            'use_n_trials', n_trials, 'data_dir', data_dir);
        best_wavs{ii,2} = get_hash(config);
    else
        if n_bins_target > 0
            stimgen.n_bins = n_bins_target;
        end
        target_ind = ii-length(d);
        reconstruction = stimgen.spect2binnedrepr(target_spects{target_ind, 1});
        best_wavs{ii,2} = target_spects{target_ind,2};
    end

    target_spect = target_spects{target_ind,1};

    for jj = 1:length(hparams)
        [~, recon_spect] = stimgen.binnedrepr2wav(reconstruction, hparams(jj,1), hparams(jj,2));
        switch metric
            case 'corr'
                c(jj) = corr(target_spect, recon_spect);
            case 'rmse'
                c(jj) = rmse(target_spect, recon_spect);
            otherwise
                error('Unknown metric')
        end
    end

    if strcmp(metric,'corr')
        [val, ind] = max(c);
    else
        [val, ind] = min(c);
    end
    
    [best_wav, best_spect] = stimgen.binnedrepr2wav(reconstruction, hparams(ind,1), hparams(ind,2));
    best_wavs{ii,1} = best_wav;

    basic_spect = stimgen.binnedrepr2spect(rescale(reconstruction, -20, 0));

    freqs = linspace(1, floor(stimgen.Fs/2), length(best_spect))';
    indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;

    nexttile
    plot(freqs(indices_to_plot,1), normalize(target_spect(indices_to_plot), 'zscore', 'std'), 'Color', [.7 .7 .7]);
    hold on
    plot(freqs(indices_to_plot,1), normalize(basic_spect(indices_to_plot), 'zscore', 'std'), 'Color', 'b', 'LineWidth', 1.5);
    plot(freqs(indices_to_plot,1), normalize(best_spect(indices_to_plot), 'zscore', 'std'), 'Color', 'k', 'LineWidth', 1.5);
    if ii > length(d)
        title(['name: ', target_spects{target_ind,2}, ' binned TS. ', ...
            metric, ': ', num2str(val), '. mult: ', num2str(hparams(ind,1)), '. binrange: ', num2str(hparams(ind,2))])
    else
        title(['name: ', target_spects{target_ind,2}, '. hash: ', get_hash(config), ...
            '.', metric, ': ', num2str(val), '. mult: ', num2str(hparams(ind,1)), '. binrange: ', num2str(hparams(ind,2))])
    end
    legend('target','binned target','optimized resynth')
end
