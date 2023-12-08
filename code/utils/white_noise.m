% ### white_noise
% 
% Generate a white noise waveform of specified length
% 
% **ARGUMENTS:**
% 
%   - dur: `1 x 1` positive scalar,
%       the duration of the waveform in seconds.
%   - Fs: `1 x 1` positive scalar, default: 44100
%       The sampling rate in Hz.
%
% **OUTPUTS:**
% 
%   - wav: `n x 1` numerical vector, where `n` is dur*Fs, 
%       the white noise waveform.

function wav = white_noise(dur,Fs)
    arguments
        dur (1,1) {mustBePositive, mustBeReal} 
        Fs (1,1) {mustBePositive, mustBeReal} = 44100
    end
    wav = randn(dur*Fs,1);
end
