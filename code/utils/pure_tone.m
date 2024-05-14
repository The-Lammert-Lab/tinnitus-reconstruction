% ### pure_tone
%
% Generate a sinusoidal pure tone stimuli
% 
% **ARGUMENTS:**
% 
%   - tone_freq: `1 x 1` positive scalar, the frequency to play
%   - dur: `1 x 1` positive scalar, 
%       the duration of the sound in seconds, default: 0.5  
%   - Fs: `1 x 1` positive scalar, 
%       the sample rate of the sound in Hz, deafult: 44100
% 
% **OUTPUTS:**
% 
%   - stim: `1 x n` numerical vector, the sinusoidal waveform

function stim = pure_tone(tone_freq,dur,Fs)
    arguments
        tone_freq (1,1) {mustBePositive, mustBeReal}
        dur (1,1) {mustBePositive, mustBeReal} = 0.5
        Fs (1,1) {mustBePositive, mustBeReal} = 44100
    end
    t = 0:1/Fs:dur;
    stim = sin(2*pi*tone_freq.*t)';
end
