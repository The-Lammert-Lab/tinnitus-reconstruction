% ### wav2spect 
% 
% Reads an audio file (e.g., a .wav file) and returns a spectrum
% in terms of magnitudes, s, and frequencies, f, in Hz.

function [s, f] = wav2spect(audio_file)

    % read the audio file
    [audio, fs] = audioread(audio_file);

    % compute the short-time Fourier transform
    [s, f] = spectrogram(audio, [], [], [], fs);

    % average out temporal information
    s = mean(abs(s), 2);

    return
end
    
