%% Using NB's reconstructions

data_dir = '~/Desktop/Lammert_Lab/Tinnitus/NB_consistency_experiments';
config_files = dir(fullfile(data_dir, '*.yaml'));
phase = 2;
no_percent = 80;
n_trials = 800;

pert_bounds = [0.5 1.5];
mult_bounds = [0.001, 0.1];
binrange_bounds = [10, 30];
lowcutoff_bounds = [0, 3000];
highcutoff_bounds = [10000, 13000];
% 
% mult_bounds = [];
% binrange_bounds = [];
% lowcutoff_bounds = [];
% highcutoff_bounds = [];

C_spect = zeros(length(config_files),1);
C_bin = zeros(length(config_files),1);
C_orig = zeros(length(config_files),1);
C_spect_p1 = zeros(length(config_files),1);
for ii = 1:length(config_files)
    config = parse_config(fullfile(data_dir,config_files(ii).name));
    stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
    stimgen = stimgen.from_config(config);

    target_spect = wav2spect(config.target_signal_filepath);
    binned_target_signal = stimgen.spect2binnedrepr(target_spect);
    [binned_repr_matrix, spect_matrix, ~] = local_create_files_and_stimuli_phaseN(config, phase, pert_bounds, data_dir, [], n_trials, ...
                                                                                'mult_range',mult_bounds,'binrange_range',binrange_bounds, ...
                                                                                'lowcut_range',lowcutoff_bounds,'highcut_range',highcutoff_bounds);

    stimgen.n_trials = n_trials;
    [~, ~, spect_matrix_p1, binned_repr_matrix_p1] = stimgen.generate_stimuli_matrix();
    responses_spect_p1 = subject_selection_process(target_spect,spect_matrix_p1', 'method','percentile','threshold',no_percent);
    recon_spect_p1 = gs(responses_spect_p1, spect_matrix_p1');
    C_spect_p1(ii) = corr(recon_spect_p1, target_spect);

    responses_spect = subject_selection_process(target_spect,spect_matrix', 'method','percentile','threshold',no_percent);
    recon_spect = gs(responses_spect, spect_matrix');
    C_spect(ii) = corr(recon_spect, target_spect);

    responses_bin = subject_selection_process(binned_target_signal,binned_repr_matrix','method','percentile','threshold',no_percent);
    recon_bin = gs(responses_bin, binned_repr_matrix');
    C_bin(ii) = corr(recon_bin, binned_target_signal);

    recon_orig = get_reconstruction('config', config, 'method', 'linear', 'data_dir', data_dir);
    C_orig(ii) = corr(recon_orig, binned_target_signal);
end

C_orig
C_bin
C_spect
C_spect_p1


%% Collect and plot average correlations from multi-phase trials

%%%%% Varying parameters
n_phases = 4;
% n_trials = 1000:1000:3000;
n_trials = 800;
ridge = [true, false];
extra_phases = [true, false];
use_phase_1 = [true, false];
% pert_bounds = [0, 2; 0.2, 1.8; 0.5, 1.5; 0.8, 1.2];
pert_bounds = [0.5, 1.5; 0.8, 1.2];

%%%%% Non-varying parameters

no_percent = [95, 90, 80, 75];
% no_percent = [95, 93, 90, 85, 80, 75];
n_validate = 20;
phase1_thresh = mean(no_percent);

stimgen = UniformPriorStimulusGeneration;
stimgen.n_trials = n_trials;
stimgen.n_bins = 32;
stimgen.min_bins = 6;
stimgen.max_bins = 16;

%%%%% Collect hyperparameters
hparams = allcomb(n_phases, n_trials, ridge, extra_phases, use_phase_1);

% Add in pert_bounds (doesn't work directly with allcomb)
% Replicate each row of hparams size(pert_bounds,1) times, concat
hparams = repelem(hparams,size(pert_bounds,1),1);
hparams(:,size(hparams,2)+1:size(hparams,2)+size(pert_bounds,2)) = repmat(pert_bounds,size(hparams,1)/size(pert_bounds,1),1);

%%%%% Run multiple phases
C = zeros(length(hparams),n_phases);
for ii = 1:length(hparams)
    C(ii,:) = run_multiple_phases(hparams(ii,1),hparams(ii,2),hparams(ii,end-size(pert_bounds,2)+1:end),no_percent, ...
                            'ridge',hparams(ii,3),'use_all_extra_phases',hparams(ii,4), ...
                            'use_phase_1',hparams(ii,5),'stimgen',stimgen);
end

%%%%% Validate result
C_trend = diff(C,1,2);
incr_inds = find(all(C_trend>0,2));

if isempty(incr_inds)
    fprintf('No parameters increase monotonically across phases \n')
else
    [~, max_c_ind] = max(diff(C(incr_inds,[1,end]),1,2));
%     [~, max_c_ind_last] = max(C(incr_inds,end));
    [~, max_c_ind_p2] = max(C(:,2));

    best_hparams_last = hparams(incr_inds(max_c_ind_last),:);
    best_hparams_p2 = hparams(max_c_ind_p2,:);
    
    % Collect correlations to validate params
    c_best_last = zeros(n_validate,n_phases);
    c_best_p2 = zeros(n_validate,n_phases);
    c_phase1 = zeros(n_validate,1);

    stimgen_p2 = stimgen;
    stimgen_p2.n_trials = (n_phases/2)*stimgen.n_trials;
    for ii = 1:n_validate
         c_best_last(ii,:) = run_multiple_phases(best_hparams_last(1),best_hparams_last(2),best_hparams_last(end-size(pert_bounds,2)+1:end),no_percent, ...
                                'ridge',best_hparams_last(3),'use_all_extra_phases',best_hparams_last(4), ...
                                'use_phase_1',best_hparams_last(5),'stimgen',stimgen);
         c_best_p2(ii,:) = run_multiple_phases(best_hparams_p2(1),best_hparams_p2(2),best_hparams_p2(end-size(pert_bounds,2)+1:end),no_percent, ...
                                'ridge',best_hparams_p2(3),'use_all_extra_phases',best_hparams_p2(4), ...
                                'use_phase_1',best_hparams_p2(5),'stimgen',stimgen_p2);
         c_phase1(ii) = run_phase_1(stimgen,phase1_thresh);
    end
    
    % Verify
    validated_last = all(diff(c_best_last,1,2)>0)
    validated_p2 = all(diff(c_best_p2(:,[1 2]),1,2)>0)
end

fprintf(['Mean correlation after ', num2str(n_phases), ' phases w/best params and ', ...
    num2str(n_trials/n_phases), ' trials each: ', num2str(mean(c_best_last(:,end))), ...
    '.\nMean correlation after 2 phases w/best params and '...
    num2str(n_trials/2), ' trials each: ', num2str(mean(c_best_p2(:,2))) ...
    '. \nMean correlation after 1 phase w/best params and ', num2str(n_trials), ' trials: ', ...
     num2str(mean(c_phase1)), '\n'])

%% Run multiple phases in bin space
function C = run_multiple_phases(n_phases, n_trials, pert_bounds, no_percents, options)
    arguments
        n_phases (1,1) {mustBeInteger}
        n_trials (1,1) {mustBeInteger}
        pert_bounds (1,2) {mustBeReal}
        no_percents (1,:) {mustBePositive}
        options.stimgen (1,1) AbstractStimulusGenerationMethod = []
        options.ridge = false
        options.use_all_extra_phases = false
        options.use_phase_1 = false
        options.mult_bounds = []
        options.binrange_bounds = []
        options.lowcutoff_bounds = []
        options.highcutoff_bounds = []
    end

    % Setup
%     n_phases = 4;
%     no_percents = [95, 90, 80, 75];
    % no_percents = [95, 50, 50, 50];
%     n_trials = 2000;
%     options.ridge = false;
%     options.use_all_extra_phases = true;
%     options.use_phase_1 = false;
%     
%     pert_bounds = [0.5 1.5];
    % pert_bounds = [0.8 1.2];
    % pert_bounds = [0.1 1.9];
    
%     options.mult_bounds = [0.001, 0.1];
%     options.binrange_bounds = [10, 80];
%     options.lowcutoff_bounds = [0, 3000];
%     options.highcutoff_bounds = [10000, 13000];
     
%     options.mult_bounds = [];
%     options.binrange_bounds = [];
%     options.lowcutoff_bounds = [];
%     options.highcutoff_bounds = [];
    
    % Stuff that likely won't change
    phase = 2;
    data_dir = '~/Desktop/Lammert_Lab/Tinnitus/NB_consistency_experiments';

    if isempty(options.stimgen)
        warning('Using default stimgen')
        stimgen = UniformPriorStimulusGeneration;
        stimgen.n_trials = round(n_trials / n_phases);
        stimgen.n_bins = 32;
        stimgen.min_bins = 6;
        stimgen.max_bins = 16;
    else
        stimgen = options.stimgen;
    end
     
    stimgen.n_trials = round(n_trials / n_phases);

    % Prepare target signal
    target_filename = '~/repos/tinnitus-reconstruction/code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav';
    target_spect = wav2spect(target_filename);
    binned_target_signal = stimgen.spect2binnedrepr(target_spect);
    
    % Preallocate arrays
    C = zeros(n_phases,1);
    recons = zeros(stimgen.n_bins, n_phases);
    
    % Run analysis
    [~, ~, ~, binned_repr_matrix_p1] = stimgen.generate_stimuli_matrix();
    responses_p1 = subject_selection_process(binned_target_signal,binned_repr_matrix_p1', 'method','percentile','threshold',no_percents(1));
    recon = gs(responses_p1, binned_repr_matrix_p1');
    
    C(1) = corr(recon,binned_target_signal);
    recons(:,1) = recon;
    
    if options.use_all_extra_phases && options.use_phase_1
        all_stimuli = binned_repr_matrix_p1;
        all_responses = responses_p1;
    else
        all_stimuli = [];
        all_responses = [];
    end
    
    for ii = 2:n_phases
        [binned_repr_matrix, ~, ~] = local_create_files_and_stimuli_phaseN(struct, phase, ...
            pert_bounds, data_dir, recons(:,ii-1), stimgen.n_trials, stimgen, ...
            'mult_range',options.mult_bounds,'binrange_range',options.binrange_bounds, ...
            'lowcut_range',options.lowcutoff_bounds,'highcut_range',options.highcutoff_bounds);
        
        if options.use_all_extra_phases
            all_stimuli = [all_stimuli, binned_repr_matrix];
            responses = subject_selection_process(binned_target_signal,binned_repr_matrix', 'method','percentile','threshold',no_percents(ii));     
            
            all_responses = [all_responses; responses];
            recon = gs(all_responses, all_stimuli', 'ridge', options.ridge);
        else
            responses = subject_selection_process(binned_target_signal,binned_repr_matrix', 'method','percentile','threshold',no_percents(ii));
            recon = gs(responses, binned_repr_matrix', 'ridge', options.ridge);
        end
    
        C(ii) = corr(recon,binned_target_signal);    
        recons(:,ii) = recon;
    end
end

%%
function C = run_phase_1(stimgen, thresh, target_filename)
    arguments
        stimgen (1,1) AbstractStimulusGenerationMethod
        thresh (1,1) {mustBePositive, mustBeLessThan(thresh,100)}
        target_filename (1,:) char = '~/repos/tinnitus-reconstruction/code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav'
    end

    % Prepare target signal
    target_spect = wav2spect(target_filename);
    binned_target_signal = stimgen.spect2binnedrepr(target_spect);
    
    [~, ~, ~, binned_repr_matrix_p1] = stimgen.generate_stimuli_matrix();
    responses_p1 = subject_selection_process(binned_target_signal,binned_repr_matrix_p1', 'method','percentile','threshold',thresh);
    recon = gs(responses_p1, binned_repr_matrix_p1');
    
    C = corr(recon,binned_target_signal);
end

%% Local functions
function [binned_repr_matrix, spect_matrix, stimuli_matrix] = local_create_files_and_stimuli_phaseN(config, phase, pert_bounds, data_dir, reconstruction, n_trials, stimgen, options)
  arguments
        config (1,1) struct
        phase (1,1) {mustBeInteger, mustBeGreaterThan(phase,1)}
        pert_bounds (1,2) 
        data_dir (1,:) char
        reconstruction (:,1) {mustBeReal} = []
        n_trials (1,1) {mustBePositive, mustBeInteger} = []
        stimgen (1,1) AbstractStimulusGenerationMethod = []
        options.mult_range (:,:) {mustBeReal} = []
        options.binrange_range (:,:) {mustBePositive} = []
        options.lowcut_range (:,:) {mustBeGreaterThanOrEqual(options.lowcut_range,0)} = []
        options.highcut_range (:,:) {mustBePositive} = []
    end

    modify_spectrum = ~all(structfun(@isempty,options));

    % Get reconstructions for previous phase
    if ~isempty(config) && isempty(reconstruction)
        reconstruction = get_reconstruction('config', config, 'phase', phase-1, ...
                                            'method', 'linear', 'data_dir', data_dir);
    end

    if isempty(n_trials)
        n_trials = config.n_trials_per_block;
    end

    % Generate a matrix of random values between pert_bounds
    % Pert bounds are tretaed as percentages
    p = min(pert_bounds) + (max(pert_bounds)-min(pert_bounds))*rand(length(reconstruction),n_trials);

    % Apply noise
    good_stim = p(:,1:round(n_trials/2)) .* reconstruction;
    bad_stim = p(:,round(n_trials/2)+1:end) .* -reconstruction;
    binned_repr_matrix = [good_stim, bad_stim];

    binned_repr_matrix = rescale(binned_repr_matrix,-100,0,"InputMin",min(binned_repr_matrix),"InputMax",max(binned_repr_matrix));
    
    % Generate spect and waveforms
    if isempty(stimgen)
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    end

    if modify_spectrum
        filt = false;
        lc = zeros(size(binned_repr_matrix,2),1);
        hc = stimgen.max_freq*ones(size(binned_repr_matrix,2),1);
        mult = 0;
        binrange = 1;
        if ~isempty(options.mult_range)
            mult = rand_vec_in_range(n_trials, min(options.mult_range), max(options.mult_range));
        end

        if ~isempty(options.binrange_range)
            binrange = rand_vec_in_range(n_trials, min(options.binrange_range), max(options.binrange_range));
        end

        if ~isempty(options.lowcut_range)
            lc = rand_vec_in_range(n_trials, min(options.lowcut_range), max(options.lowcut_range));
            filt = true;
        end

        if ~isempty(options.highcut_range)
            hc = rand_vec_in_range(n_trials, min(options.highcut_range), max(options.highcut_range));
            filt = true;
        end
        
        [stimuli_matrix, spect_matrix] = stimgen.binnedrepr2wav(binned_repr_matrix,mult,binrange,'filter',filt,'cutoff',[lc, hc]);
        binned_repr_matrix = stimgen.spect2binnedrepr(spect_matrix);
    else
        % Otherwise just get spectrum and synthesize audio
        spect_matrix = stimgen.binnedrepr2spect(binned_repr_matrix');
        stimuli_matrix = stimgen.synthesize_audio(spect_matrix,stimgen.nfft);
    end
end % function

function r = rand_vec_in_range(n,minimum,maximum)
        r = minimum + (maximum-minimum)*rand(n,1);
end
