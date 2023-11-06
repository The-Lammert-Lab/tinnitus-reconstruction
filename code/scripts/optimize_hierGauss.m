

target_filename = 'ATA_Tinnitus_Buzzing_Tone_1sec.wav';
n_trials = 1000;
n_broad = 1:3;
n_med = 0:8;
n_narrow = 0:2:20;

target_spect = wav2spect(fullfile('~/repos/tinnitus-reconstruction/code/experiment/ATA/',target_filename));

stimgen = HierarchicalGaussianStimulusGeneration;
stimgen.n_trials = n_trials;

params = allcomb(n_broad,n_med,n_narrow);

% Remove all zeros row
params = params(2:end,:);

C = zeros(length(params),1);
for ii = 1:length(params)
    stimgen.n_broad = params(ii,1);
    stimgen.n_med = params(ii,2);
    stimgen.n_narrow = params(ii,3);

    [~, ~, spect_matrix, ~, W] = stimgen.generate_stimuli_matrix();
    responses = subject_selection_process(target_spect, spect_matrix', 'method','sign','mean_zero',true);
    rc_weights = gs(responses,W');
    B = stimgen.get_basis();
    recon = B*rc_weights;
    C(ii) = corr(target_spect,recon);
end

[~,best_ind] = max(C);
stimgen.n_broad = params(best_ind,1);
stimgen.n_med = params(best_ind,2);
stimgen.n_narrow = params(best_ind,3);

[~, ~, spect_matrix, ~, W] = stimgen.generate_stimuli_matrix();
responses = subject_selection_process(target_spect, spect_matrix', 'method','sign','mean_zero',true);
rc_weights = gs(responses,W');
B = stimgen.get_basis();
recon = B*rc_weights;

figure;
plot(recon);
hold on;
plot(target_spect);
title(['Correlation: ', num2str(C(best_ind))],'FontSize',16)

