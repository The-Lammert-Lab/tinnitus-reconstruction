function wav = white_noise(dur,Fs)
    arguments
        dur (1,1) {mustBePositive, mustBeReal} 
        Fs (1,1) {mustBePositive, mustBeReal} = 44100
    end
    wav = randn(dur*Fs,1);
end
