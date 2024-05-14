% ### wav2spect 
% 
% Reads an audio file (e.g., a .wav file) and returns a spectrum
% in terms of magnitudes, s (in dB), and frequencies, f (in Hz).
% 
% **ARGUMENTS:**
% 
%   - audio_file: `char`, path to the audio file.
%   - duration: `1x1` scalar, default: 0.5,
%       the duration to crop the audio file to in seconds.
% 
% **OUTPUTS:**
% 
%   - s: The spectrum in dB
%   - f: The associated frequencies in Hz.

function [s, f] = wav2spect(audio_file, duration)

    % read the audio file
    [audio, fs] = audioread(audio_file);
    if mod(length(audio), 2) ~= 0
        audio = audio(1:end-1,:);
    end

    if nargin < 2
        duration = 0.5;
    end

    audio = audio(1:(fs * duration));

    % compute the short-time Fourier transform
    % s is an nfft/2 vector or matrix. f should be the same size.
    % nfft = length(audio).
    [s, f] = spectrogram(audio, [], [], length(audio)-1, fs);

    % remove complex component, convert to dB, average out temporal info
    s = mean(convert_to_db(abs(s).^2),2);

    return
end
    
