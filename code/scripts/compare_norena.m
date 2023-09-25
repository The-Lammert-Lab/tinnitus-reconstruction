% Run simulated observer on Norena stimgen and UniformPrior and visualize
% the results

n_trials = 2000;
min_freq = 100;
max_freq = 13000;

bins = [8, 16, 32, 64, 100];
min_max_bins = [2,7; 4,10; 6,16; 12,32; 30,40];
method = 'sign';
mean_zero = true;

stimgenUniform = UniformPriorStimulusGeneration;
stimgenUniform.min_freq = min_freq;
stimgenUniform.max_freq = max_freq;
stimgenUniform.n_trials = n_trials;

stimgenNorena = NorenaBinnedStimulusGeneration;
stimgenNorena.min_freq = min_freq;
stimgenNorena.max_freq = max_freq;
stimgenNorena.n_trials = n_trials;

targets = {'ATA_Tinnitus_Buzzing_Tone_1sec.wav', ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav', ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav', ...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav'};

for ii = 1:length(targets)
    figure
    t = tiledlayout(length(bins),3);

    [target_signal, ~] = wav2spect(fullfile('~/repos/tinnitus-reconstruction/code/experiment/ATA',targets{ii}));
    target_signal = 10*log10(target_signal);

    for jj = 1:length(bins)
        stimgenUniform.n_bins = bins(jj);
        stimgenUniform.min_bins = 1;
        stimgenUniform.max_bins = 1;

        [freqs, indices_to_plot, recon_spect, binned_target_spect, c] = compare(stimgenUniform, target_signal, ...
                                                                            'method', method, 'mean_zero', mean_zero);

        nexttile
        plot(freqs(indices_to_plot,1), normalize(target_signal(indices_to_plot), 'zscore', 'std'), 'Color', [.7 .7 .7]);
        hold on
        plot(freqs(indices_to_plot,1), normalize(binned_target_spect(indices_to_plot), 'zscore', 'std'), 'k', 'LineWidth', 1.5);
        plot(freqs(indices_to_plot,1), normalize(recon_spect(indices_to_plot), 'zscore', 'std'), 'b', 'LineWidth', 1.5);
        title(['Uniform Prior. ', num2str(bins(jj)), ' bins. 1 bin filled. corr = ', num2str(c,4)], 'FontSize', 14)

        %%%%%%%%%%%
        stimgenUniform.min_bins = min_max_bins(jj,1);
        stimgenUniform.max_bins = min_max_bins(jj,2);

        [freqs, indices_to_plot, recon_spect, binned_target_spect, c] = compare(stimgenUniform, target_signal, ...
                                                                            'method', method, 'mean_zero', mean_zero);

        nexttile
        plot(freqs(indices_to_plot,1), normalize(target_signal(indices_to_plot), 'zscore', 'std'), 'Color', [.7 .7 .7]);
        hold on
        plot(freqs(indices_to_plot,1), normalize(binned_target_spect(indices_to_plot), 'zscore', 'std'), 'k', 'LineWidth', 1.5);
        plot(freqs(indices_to_plot,1), normalize(recon_spect(indices_to_plot), 'zscore', 'std'), 'b', 'LineWidth', 1.5);
        title(['Uniform Prior. ', num2str(bins(jj)), ' bins. min: ' ...
            num2str(stimgenUniform.min_bins), ', max: ', num2str(stimgenUniform.max_bins), ...
            '. corr = ', num2str(c,4)], 'FontSize', 14)
        
        %%%%%%%%%%%
        stimgenNorena.n_bins = bins(jj);
        [freqs, indices_to_plot, recon_spect, binned_target_spect, c] = compare(stimgenNorena, target_signal, ...
                                                                            'method', method, 'mean_zero', mean_zero);
        
        nexttile
        plot(freqs(indices_to_plot,1), normalize(target_signal(indices_to_plot), 'zscore', 'std'), 'Color', [.7 .7 .7]);
        hold on
        plot(freqs(indices_to_plot,1), normalize(binned_target_spect(indices_to_plot), 'zscore', 'std'), 'k', 'LineWidth', 1.5);
        plot(freqs(indices_to_plot,1), normalize(recon_spect(indices_to_plot), 'zscore', 'std'), 'b', 'LineWidth', 1.5);
        title(['Norena. ', num2str(bins(jj)), ' bins. corr = ', num2str(c,4)], 'FontSize', 14)
    end
    leg = legend({'Target Signal','Binned Target Signal','Reconstruction'},'Orientation','horizontal','Fontsize',14);
    leg.Layout.Tile = 'north';

    title(t, [targets(ii), [' method: ', method]], 'FontSize', 16, 'Interpreter','none')
end

function [freqs, indices_to_plot, recon_spect, binned_target_spect, c] = compare(stimgen, target_signal, options)
    arguments
        stimgen
        target_signal
        options.method
        options.mean_zero (1,1) logical
    end
    binned_target_signal = stimgen.spect2binnedrepr(target_signal);
    binned_target_spect = stimgen.binnedrepr2spect(binned_target_signal);

    [~, ~, ~, binned_repr] = stimgen.generate_stimuli_matrix();
    y = subject_selection_process(binned_target_signal, binned_repr', ...
        'method', options.method, 'mean_zero', options.mean_zero);

    if strcmp(options.method,'ten_scale')
        recon = norena_recon(y, binned_repr);
    else
        recon = gs(y, binned_repr');
    end
    
    recon_spect = stimgen.binnedrepr2spect(recon);
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spect))';
    indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;
    
    c = corr(binned_target_signal, recon);
end

% Slower version
% function recon = norena_recon(y, X)
%     for ii = 1:size(X,2)
%         % Get the max bin amplitude (it's zero, but just in case)
%         max_amp = max(X(:,ii));
%     
%         % Replace all filled bins with score and unfilled with 0
%         X(X(:,ii) == max_amp, ii) = y(ii);
%         X(X(:,ii) < max_amp, ii) = 0;
%     end
%     recon = mean(X,2);
% end

function recon = norena_recon(y,X)
    % X = n_bins by n_trials
    weighted_stimuli = X*y;
    recon = weighted_stimuli / sum(y);
end
