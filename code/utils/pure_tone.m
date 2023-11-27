function stim = pure_tone(tone_freq,dur,Fs)
    arguments
        tone_freq (1,1) {mustBePositive, mustBeReal}
        dur (1,1) {mustBePositive, mustBeReal} = 0.5
        Fs (1,1) {mustBePositive, mustBeReal} = 44100
    end
    t = 0:1/Fs:dur;
    stim = sin(2*pi*tone_freq.*t);
end
