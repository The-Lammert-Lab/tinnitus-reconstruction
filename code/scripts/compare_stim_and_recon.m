% ### compare_stim_and_recon
% Runs the simulated observer on two UniformPrior options 
% (1 bin filled and multiple bins filled) and uses several
% different reconstruction methods (ten scale, ridge regression, linear)
% and visualizes the results
% End of documentation

%% Script
n_trials = 2000;
min_freq = 100;
max_freq = 13000;

bins = [8, 16, 32, 64, 100];
% bins = 8;
min_max_bins = [2,7; 4,10; 6,16; 12,32; 30,40];

ssp_settings = {'sign', true;
            'ten_scale', false};

stimgen = UniformPriorStimulusGeneration;
stimgen.min_freq = min_freq;
stimgen.max_freq = max_freq;
stimgen.n_trials = n_trials;

targets = {'ATA_Tinnitus_Buzzing_Tone_1sec.wav', ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav', ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav', ...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav'};

for ii = 1:length(targets)
    figure
    t = tiledlayout(length(bins),2);

    [target_signal, ~] = wav2spect(fullfile('~/repos/tinnitus-reconstruction/code/experiment/ATA',targets{ii}));

    for jj = 1:length(bins)
        stimgen.n_bins = bins(jj);
        stimgen.min_bins = 1;
        stimgen.max_bins = 1;
        
        [freqs, indices_to_plot, recon_spects, binned_target_spect, c] = compare(stimgen, target_signal);

        leg_txt = cell(size(recon_spects,1),1);

        nexttile
        plot(freqs(indices_to_plot,1), normalize(target_signal(indices_to_plot), 'zscore', 'std'), 'Color', [.7 .7 .7]);
        hold on
        plot(freqs(indices_to_plot,1), normalize(binned_target_spect(indices_to_plot), 'zscore', 'std'), 'k', 'LineWidth', 1.5);
        for kk = 1:size(recon_spects,1)
            recon = recon_spects{kk,1};
            plot(freqs(indices_to_plot,1), normalize(recon(indices_to_plot), 'zscore', 'std'), 'LineWidth', 1.5);
            leg_txt(kk) = {[recon_spects{kk,2}, ', corr: ', num2str(c(kk),4)]};
        end
        legend([{'target, corr: N/A'}, {'target_binned, corr: N/A'}, leg_txt(:)'], ...
            'Interpreter','none', 'Location','northeastoutside')
        title(['Uniform Prior. ', num2str(bins(jj)), ' bins. 1 bin filled.'], 'FontSize', 14)

        %%%%%%%%%%%
        stimgen.min_bins = min_max_bins(jj,1);
        stimgen.max_bins = min_max_bins(jj,2);

        [freqs, indices_to_plot, recon_spects, binned_target_spect, c] = compare(stimgen, target_signal);

        nexttile
        plot(freqs(indices_to_plot,1), normalize(target_signal(indices_to_plot), 'zscore', 'std'), 'Color', [.7 .7 .7]);
        hold on
        plot(freqs(indices_to_plot,1), normalize(binned_target_spect(indices_to_plot), 'zscore', 'std'), 'k', 'LineWidth', 1.5);
        for kk = 1:size(recon_spects,1)
            recon = recon_spects{kk,1};
            plot(freqs(indices_to_plot,1), normalize(recon(indices_to_plot), 'zscore', 'std'), 'LineWidth', 1.5);
            leg_txt(kk) = {[recon_spects{kk,2}, ', corr: ', num2str(c(kk),4)]};
        end
        legend([{'target, corr: N/A'}, {'target_binned, corr: N/A'}, leg_txt(:)'], ...
            'Interpreter','none','Location','northeastoutside')
        title(['Uniform Prior. ', num2str(bins(jj)), ' bins. min: ' ...
            num2str(stimgen.min_bins), ', max: ', num2str(stimgen.max_bins)], 'FontSize', 14)
    end
    title(t, targets(ii), 'FontSize', 16, 'Interpreter','none')
end

%% Local functions
function [freqs, indices_to_plot, recon_spects, binned_target_spect, c] = compare(stimgen, target_signal)
    binned_target_signal = stimgen.spect2binnedrepr(target_signal);
    binned_target_spect = stimgen.binnedrepr2spect(binned_target_signal);

    [~, ~, ~, binned_repr] = stimgen.generate_stimuli_matrix();

    y_sign = subject_selection_process(binned_target_signal, binned_repr', ...
        'method', 'sign', 'mean_zero', true);
    y_ten = subject_selection_process(binned_target_signal, binned_repr', ...
        'method', 'ten_scale', 'mean_zero', false);

    recon_sign = gs(y_sign,binned_repr','ridge',true);
    recon_ten = gs(y_ten,binned_repr','ridge',true);
    recon_wa = norena_recon(y_ten,binned_repr);

    recons = {recon_sign, recon_ten, recon_wa};
    recon_labels = {'sign_ridge','ten_ridge','ten_wa'};

    c = zeros(length(recons),1);
    recon_spects = cell(length(recons),2);
    for ii = 1:length(recons)
        c(ii) = corr(binned_target_signal, recons{ii});
        recon_spects{ii,1} = stimgen.binnedrepr2spect(recons{ii});
        recon_spects{ii,2} = recon_labels{ii};
    end

    
    freqs = linspace(1, floor(stimgen.Fs/2), length(recon_spects{1}))';
    indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;
    
end

function recon = norena_recon(y,X)
    % X = n_bins by n_trials
    weighted_stimuli = X*y;
    recon = weighted_stimuli / sum(y);
end

