% ### analyze_consistency 
% This script compares the consistency in reconstructions from 
% data collected several days in a row by NB with all settings the same

%% Setup
DATA_DIR = '~/Desktop/Lammert_Lab/Tinnitus/NB_consistency_experiments';
recon_method = 'linear';
verbose = false;

%% Load data

d = dir(fullfile(DATA_DIR, '*.yaml'));
p_yesses = zeros(length(d),1);
subjRecons = cell(length(d),1);
idealRecons_sign = cell(length(d),1);
idealRecons_percent = cell(length(d),1);
for ii = 1:length(d)
    % Read in config
    config = parse_config(fullfile(DATA_DIR, d(ii).name));

    % Get binned target signal. Only needs to be done once
    if ii == 1
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
        [target_signal, ~] = wav2spect(config.target_signal_filepath);
        binned_target_signal = stimgen.spect2binnedrepr(target_signal);
    end

    % Load stimuli and responses
    [responses, stimuli] = collect_data('config', config, 'verbose', verbose, 'data_dir', DATA_DIR);
    % Get percent yes
    p_yesses(ii) = 100*sum(responses == 1) / length(responses);
    % Get data-driven reconstruction
    subjRecons{ii} = get_reconstruction('config', config, 'method', recon_method, ...
                                        'data_dir', DATA_DIR, 'verbose', verbose);
    % Get ideal observer reconstruction for same stimuli using no "cheating"
    y_sign = subject_selection_process(binned_target_signal,stimuli', ...
                                        'mean_zero',true,'method','sign','verbose',verbose);
    idealRecons_sign{ii} = gs(y_sign,stimuli');
    % Get ideal observer reconstruction for same stimuli at data informed % yes
    y_perc = subject_selection_process(binned_target_signal, stimuli', [], ...
                                        responses, 'method','percentile', ...
                                        'from_responses',true,'verbose',verbose);
    idealRecons_percent{ii} = gs(y_perc,stimuli');
end

%% Compare reconstructions

corr_combs = nchoosek(1:length(subjRecons),2);

innerCorr_subjRecons = ones(length(subjRecons));
innerCorr_idealRecons_sign = ones(length(idealRecons_sign));
innerCorr_idealRecons_percent = ones(length(idealRecons_percent));

tsCorr_subj = zeros(length(subjRecons),1);
tsCorr_idealSign = zeros(length(subjRecons),1);
tsCorr_idealPerc = zeros(length(subjRecons),1);

for ii = 1:length(corr_combs)
    this_comb = corr_combs(ii,:);
    innerCorr_subjRecons(this_comb(2),this_comb(1)) = corr(subjRecons{this_comb(1)}, subjRecons{this_comb(2)});
    innerCorr_idealRecons_sign(this_comb(2),this_comb(1)) = corr(idealRecons_sign{this_comb(1)}, idealRecons_sign{this_comb(2)});
    innerCorr_idealRecons_percent(this_comb(2),this_comb(1)) = corr(idealRecons_percent{this_comb(1)}, idealRecons_percent{this_comb(2)});

    tsCorr_subj(ii) = corr(binned_target_signal, subjRecons{ii});
    tsCorr_idealSign(ii) = corr(binned_target_signal, idealRecons_sign{ii});
    tsCorr_idealPerc(ii) = corr(binned_target_signal, idealRecons_percent{ii});
end


%% Fill out matrices
innerCorr_subjRecons = fillmatrix(innerCorr_subjRecons);
innerCorr_idealRecons_sign = fillmatrix(innerCorr_idealRecons_sign);
innerCorr_idealRecons_percent = fillmatrix(innerCorr_idealRecons_percent);

%% Create table
T = table(tsCorr_subj,tsCorr_idealSign,tsCorr_idealPerc,p_yesses,...
    'VariableNames',{'response_corr','ideal_sign_corr','ideal_percent_corr','percent_yesses'})

%% Viz results
figure;
t = tiledlayout('flow');

nexttile
h = heatmap(innerCorr_subjRecons,'Colormap',jet(512),'FontSize',12);
h.Title = '\fontsize{16} Data driven reconstruction correlations';
h.YLabel = '\fontsize{14} Experiment number';
h.XLabel = '\fontsize{14} Experiment number';

nexttile
h = heatmap(innerCorr_idealRecons_sign,'Colormap',jet(512),'FontSize',12);
h.Title = '\fontsize{16} Ideal reconstruction correlations with sign()';
h.YLabel = '\fontsize{14} Experiment number';
h.XLabel = '\fontsize{14} Experiment number';

nexttile
h = heatmap(innerCorr_idealRecons_percent,'Colormap',jet(512),'FontSize',12);
h.Title = '\fontsize{16} Ideal reconstruction correlations with matching percent';
h.YLabel = '\fontsize{14} Experiment number';
h.XLabel = '\fontsize{14} Experiment number';


freqs = linspace(1, floor(stimgen.Fs/2), length(target_signal))';
indices_to_plot = freqs(:,1) <= stimgen.max_freq & freqs(:,1) >= stimgen.min_freq;

spect_target_signal = stimgen.binnedrepr2spect(binned_target_signal);

% figure;
% % plot(freqs(indices_to_plot,1), normalize(spect_target_signal(indices_to_plot), 'zscore', 'std'), 'k', 'LineWidth', 1.5);
% hold on
% 
% for jj = 1:length(subjRecons)
%     binned_recon = subjRecons{jj};
%     spect_recon = stimgen.binnedrepr2spect(binned_recon);
%     plot(freqs(indices_to_plot,1), normalize(spect_recon(indices_to_plot), 'zscore', 'std'), 'LineWidth', 1.5);
% end

%% Local funcs
function M = fillmatrix(M)
    M = triu(M',1) + tril(M);
end
