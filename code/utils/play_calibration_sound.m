function play_calibration_sound()
    Fs = 44100;
    tone = pure_tone(1000,1,Fs);
    sound(tone,Fs,24)
end
