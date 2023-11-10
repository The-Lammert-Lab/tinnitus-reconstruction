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


%% Run multiple phases in bin space

% Setup
phase = 2;
n_phases = 4;
% no_percents = [95, 85, 80, 75];
no_percents = [95, 50, 50, 50];
n_trials = 2000;

pert_bounds = [0.5 1.5];
% mult_bounds = [0.001, 0.1];
% binrange_bounds = [10, 80];
lowcutoff_bounds = [0, 3000];
% highcutoff_bounds = [10000, 13000];

mult_bounds = [];
binrange_bounds = [];
lowcutoff_bounds = [];
highcutoff_bounds = [];

% Stuff that likely won't change
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/NB_consistency_experiments';
stimgen = UniformPriorStimulusGeneration;
stimgen.n_trials = n_trials / n_phases;
stimgen.n_bins = 32;
stimgen.min_bins = 6;
stimgen.max_bins = 16;

% Prepare target signal
target_filename = '~/repos/tinnitus-reconstruction/code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav';
target_spect = wav2spect(target_filename);
binned_target_signal = stimgen.spect2binnedrepr(target_spect);

% Preallocate arrays
C = zeros(n_phases,1);
recons = zeros(stimgen.n_bins, n_phases);

% Run analysis
[~, ~, spect_matrix_p1, binned_repr_matrix_p1] = stimgen.generate_stimuli_matrix();
responses_p1 = subject_selection_process(binned_target_signal,binned_repr_matrix_p1', 'method','percentile','threshold',no_percents(1));
recon = gs(responses_p1, binned_repr_matrix_p1');
C(1) = corr(recon,binned_target_signal);
recons(:,1) = recon;

for ii = 2:n_phases
    [binned_repr_matrix, spect_matrix, ~] = local_create_files_and_stimuli_phaseN(struct, phase, ...
        pert_bounds, data_dir, recons(:,ii-1), stimgen.n_trials, stimgen, ...
        'mult_range',mult_bounds,'binrange_range',binrange_bounds, ...
        'lowcut_range',lowcutoff_bounds,'highcut_range',highcutoff_bounds);
    responses = subject_selection_process(binned_target_signal,binned_repr_matrix', 'method','percentile','threshold',no_percents(ii));
    recon = gs(responses, binned_repr_matrix');

    C(ii) = corr(recon,binned_target_signal);
    recons(:,ii) = recon;
end

C

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
    binned_repr_matrix = p .* reconstruction;
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
