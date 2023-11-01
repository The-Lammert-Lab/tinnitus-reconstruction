%%% 
% This script compares data day-to-day consistency in reconstructions
% From data collected by NB with all settings the same
%%%

%% Setup
DATA_DIR = '~/Desktop/Lammert_Lab/Tinnitus/NB_consistency_experiments';
recon_method = 'linear';
verbose = false;

%% Load data

d = dir(fullfile(DATA_DIR, '*.yaml'));
p_yesses = zeros(length(d),1);
subj_recons = cell(length(d),1);
ideal_recons_sign = cell(length(d),1);
ideal_recons_percent = cell(length(d),1);
for ii = 1:length(d)
    % Read in config
    config = parse_config(fullfile(DATA_DIR, d(ii).name));

    if ii == 1
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
        [target_signal, Fs] = audioread(config.target_signal_filepath);
        binned_target_signal = 
    end

    % Load stimuli and responses
    [responses, stimuli] = collect_data('config', config, 'verbose', verbose, 'data_dir', DATA_DIR);
    % Get percent yes
    p_yesses(ii) = 100*sum(responses == 1) / length(responses);
    % Get data-driven reconstruction
    subj_recons(ii) = get_reconstruction('config', config, 'method', recon_method, 'data_dir', DATA_DIR);
    % Get ideal observer reconstruction for same stimuli at 50% yes
    ideal_recons_sign(ii) = subject_selection_process()
    % Get ideal observer reconstruction for same stimuli at data informed % yes
end


%% Compare reconstructions