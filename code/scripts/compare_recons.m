% ### compare_recons
% The purpose of this script is to assess the qualitative effect of the
% peak-sharpening procedure. 
% Runs adjust_resynth.m followed by follow_up.m on select
% configs/associated data.
% End of documentation

%% Setup

% Change these as appropriate
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/resynth_test_data/';
USER_ID = 'TS';

% Setup variables
d = dir(pathlib.join(data_dir, '*.yaml'));
project_dir = pathlib.strip(mfilename('fullpath'), 3);
n_trials = 200;

[buzzing_wav, buzzing_fs] = audioread(pathlib.join(project_dir,'code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav'));
[roaring_wav, roaring_fs] = audioread(pathlib.join(project_dir,'code/experiment/ATA/ATA_Tinnitus_Roaring_Tone_1sec.wav'));

%% Data-generated reconstructions
for i = 1:length(d)
    % Get config path and load config to determine target sound
    config_path = pathlib.join(d(i).folder, d(i).name);
    config = parse_config(config_path);

    % Read in target sound b/c configs have paths from different machines
    if strcmp(config.target_signal_name, 'buzzing')
        target_sound = buzzing_wav;
        target_fs = buzzing_fs;
    else
        target_sound = roaring_wav;
        target_fs = roaring_fs;
    end

    % Run resynth adjustment
    [mult, binrange] = adjust_resynth('config_file', config_path, ...
        'data_dir', data_dir, 'target_sound', target_sound, ...
        'target_fs', target_fs, 'n_trials', n_trials);

    % Pass parameters to follow_up and answer the questions.
    follow_up('config_file', config_path, ...
        'data_dir', data_dir, 'target_sound', target_sound, ...
        'target_fs', target_fs, 'mult', mult, 'binrange', binrange, ...
        'survey', false, 'n_trials', n_trials, 'version', 2);

    % Rename the file with the supplied user ID 
    movefile(pathlib.join(data_dir, ['survey_', get_hash(config), '.csv']), ...
        pathlib.join(data_dir, ['survey_', get_hash(config), '_', USER_ID, '.csv']));

    % follow_up doesn't delete its figure at the end
    delete(gcf)
end

%% Binned target signals

% All relevant stimgen information is the same, so just use last one.
stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
stimgen = stimgen.from_config(config);

% Package everything so loop runs nicely
C = {buzzing_wav, buzzing_fs, 'buzzingBinned'; 
    roaring_wav, roaring_fs, 'roaringBinned'};

for i = 1:size(C,1)
    % Truncate target sound (to be binned) to 500 ms if it's longer
    if length(C{i,1}) > floor(0.5 * C{i,2})
        target_wav = C{i,1}(1:floor(0.5 * C{i,2}));
    else
        target_wav = C{i,1};
    end

    % Bin target sound
    target_spect = signal2spect(target_wav);
    binned_target = stimgen.spect2binnedrepr(target_spect);

    % Run resynth adjustment
    [mult, binrange] = adjust_resynth('config_file', config_path, ...
        'data_dir', data_dir, 'target_sound', C{i,1}, ...
        'target_fs', C{i,2}, 'recon', binned_target, 'this_hash', C{i,3});

    % Pass parameters to follow_up and answer the questions.
    follow_up('config_file', config_path, 'data_dir', data_dir, ...
        'target_sound', C{i,1}, 'target_fs', C{i,2}, 'mult', mult, ...
        'binrange', binrange, 'survey', false, 'recon', binned_target, ...
        'this_hash', C{i,3}, 'version', 2);

    % Rename the file with the supplied user ID
    movefile(pathlib.join(data_dir, ['survey_', C{i,3}, '.csv']), ...
        pathlib.join(data_dir, ['survey_', C{i,3}, '_', USER_ID, '.csv']));
    
    % follow_up doesn't delete its figure at the end
    delete(gcf)
end
