%%%% 
% Run this script to demonstrate example for resynth protocol
%%%%

stimgen = UniformPriorStimulusGeneration;
stimgen.n_bins = 32;
stimgen.max_freq = 13000;
stimgen.n_trials = 200;

project_dir = pathlib.strip(mfilename('fullpath'), 3);

[buzzing_wav, buzzing_fs] = audioread(pathlib.join(project_dir,'code/experiment/ATA/ATA_Tinnitus_Buzzing_Tone_1sec.wav'));
buzzing_wav = buzzing_wav(1:floor(0.5 * buzzing_fs));

target_spect = signal2spect(buzzing_wav);
binned_target = stimgen.spect2binnedrepr(target_spect);

[mult, binrange] = adjust_resynth('config_file', 'none', ...
    'stimgen', stimgen, 'target_sound', buzzing_wav, ...
    'target_fs', buzzing_fs, 'recon', binned_target, ...
    'this_hash', 'buzzing_example', ...
    'mult_range', [0, 0.1]);
