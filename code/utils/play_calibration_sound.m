% ### play_calibration_sound
% 
% Plays a 1000 Hz tone at system volume with a sample rate of 44100 Hz.
% No arguments.

function play_calibration_sound()
    Fs = 44100;
    tone = pure_tone(1000,1,Fs);
    sound(tone,Fs,24)
end
