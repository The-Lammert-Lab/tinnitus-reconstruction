% Find ideal mult and binrange intervals for n bins


mean_zero = true;

stimgen = UniformPriorStimulusGeneration;
stimgen.min_freq = 100;
stimgen.max_freq = 16e3;

bin_params = {[2,6,8], [6,12,16], [6,16,32], [12,20,64], [45,80,128]};

targets = {'ATA_Tinnitus_Buzzing_Tone_1sec.wav', ...
    'ATA_Tinnitus_Roaring_Tone_1sec.wav', ...
    'ATA_Tinnitus_Tea_Kettle_Tone_1sec.wav', ...
    'ATA_Tinnitus_Screeching_Tone_1sec.wav'};

[target_signal, ~] = wav2spect(fullfile('~/repos/tinnitus-reconstruction/code/experiment/ATA',targets{ii}));

corr_vals = zeros(length(bin_params), length(targets)+1);
for ii = 1:length(bin_params)
    curr_settings = bin_params{1};
    stimgen.n_bins = curr_settings(end);
    stimgen.min_bins = curr_settings(1);
    stimgen.max_bins = curr_settings(2);

    for jj = 1:length(targets)
        
        [target_signal, ~] = wav2spect(fullfile('~/repos/tinnitus-reconstruction/code/experiment/ATA',targets{jj}));
        binned_target_signal = stimgen.spect2binnedrepr(target_signal);
        binned_target_spect = stimgen.binnedrepr2spect(binned_target_signal);

        [~, ~, ~, binned_repr] = stimgen.generate_stimuli_matrix();
        y = subject_selection_process(binned_target_signal, binned_repr', ...
            'method', 'percentile', 'mean_zero', mean_zero);
        repr = gs(y, binned_repr');

        

    end

end
