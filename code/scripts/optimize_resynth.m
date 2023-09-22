% Optimize resynthesis using grid search for mult and binrange params

%% Setup

% Change these as appropriate
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/resynth_test_data/';

d = dir(pathlib.join(data_dir, '*.yaml'));
project_dir = pathlib.strip(mfilename('fullpath'), 3);
% project_dir = '~/repos/tinnitus-reconstruction';
ATA_path = 'code/experiment/ATA';
n_trials = 200;
metric = 'dtw';
skip_subject_data = false;
n_bins_target = 32;
target_signal_files = {'ATA_Tinnitus_Buzzing_Tone_1sec.wav'; ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav'; ...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav'; ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav'};

mult = linspace(0.001,0.5,100);
binrange = linspace(1,80,80);

stimgen = UniformPriorStimulusGeneration;
stimgen.max_freq = 13000;
stimgen.min_freq = 100;
stimgen.n_bins = n_bins_target;

% Collect target spectra in a cell array
target_spects2 = cell(length(target_signal_files),2);
for ii = 1:length(target_signal_files)
    curr_spect = wav2spect(fullfile(project_dir,ATA_path,target_signal_files{ii}));
    if ii == 1
        freqs = linspace(1, floor(stimgen.Fs/2), length(curr_spect))';
        indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;
    end
    curr_spect = 10*log10(curr_spect);
    target_spects2{ii,1} = curr_spect - min(curr_spect(indices_to_plot));
    target_spects2{ii,2} = lower(extractBetween(target_signal_files{ii}, 'Tinnitus_', '_Tone'));
end

% Collect hyperparameters
hparams = allcomb(mult, binrange);

% Containers
c = zeros(length(hparams),1);
best_wavs = cell(length(d)+length(target_spects),2);

%% Analysis
figure
tiledlayout('flow')
for ii = 1:length(d)+length(target_spects)
    % Get config path and load config to determine target sound
    if ii <= length(d)
        if skip_subject_data
            continue
        end
        
        config_path = pathlib.join(d(ii).folder, d(ii).name);
        config = parse_config(config_path);
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);

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
                c(jj) = corr(target_spect(indices_to_plot), recon_spect(indices_to_plot));
            case 'rmse'
                c(jj) = rmse(target_spect(indices_to_plot), recon_spect(indices_to_plot));
            case 'dtw'
                c(jj) = dtw(target_spect(indices_to_plot), recon_spect(indices_to_plot));
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

    nexttile
    plot(freqs(indices_to_plot,1), target_spect(indices_to_plot), 'Color', [.7 .7 .7]);
    hold on
    plot(freqs(indices_to_plot,1), basic_spect(indices_to_plot), 'Color', 'b', 'LineWidth', 1.5);
    plot(freqs(indices_to_plot,1), best_spect(indices_to_plot), 'Color', 'k', 'LineWidth', 1.5);
    if ii > length(d)
        title(['name: ', target_spects{target_ind,2}, ' binned TS. ', ...
            metric, ': ', num2str(val), '. mult: ', ...
            num2str(hparams(ind,1)), '. binrange: ', num2str(hparams(ind,2))], ...
            'Interpreter','none');
    else
        title(['name: ', target_spects{target_ind,2}, '. hash: ', get_hash(config), ...
            '.', metric, ': ', num2str(val), '. mult: ', num2str(hparams(ind,1)), ...
            '. binrange: ', num2str(hparams(ind,2))], 'Interpreter','none')
    end
end
leg = legend('target','binned target','optimized resynth','Orientation','horizontal');
leg.Layout.Tile = 'north';

