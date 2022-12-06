% ### white_noise
% Generate a white noise stimulus based on a config file's settings.
% 
% **ARGUMENTS:**
%   - config_file: string or character array, name-value, default: ``''``
%       A path to a YAML-spec configuration file.
%       Either this argument or ``config`` is required.
%   - config: struct, name-value, default: ``[]``
%       A configuration file struct
%       (e.g., one created by ``parse_config``).
% 
% **OUTPUTS:**
%   - white_waveform: `n x 1` white noise waveform
%   - fs: `1 x 1` Associated frequency of waveform.

function [white_waveform, Fs] = white_noise(options)

    arguments
        options.config_file (1,:) char = ''
        options.config = []
        options.stimgen = []
        options.target_filepath (1,:) char = ''
        options.freqs (:,1) {mustBeNumeric} = []
    end

    % Process config
    if isempty(options.config)
        [config, ~] = parse_config(options.config_file);
    else
        config = options.config;
    end

    % Set stimgen
    if isempty(options.stimgen)
        stimgen = eval([char(config.stimuli_type), 'StimulusGeneration()']);
        stimgen = stimgen.from_config(config);
    else
        stimgen = options.stimgen;
    end

    if isempty(options.freqs)
        [~, options.freqs] = wav2spect(config.target_signal_filepath);
    end

    % Generate noise
    whitenoise = zeros(config.n_bins,1);
    white_spect = stimgen.binnedrepr2spect(whitenoise);
    white_spect(options.freqs(1:length(white_spect),1) > config.max_freq) = -20;
    white_waveform = stimgen.synthesize_audio(white_spect, stimgen.get_nfft());
    Fs = stimgen.Fs;
end
