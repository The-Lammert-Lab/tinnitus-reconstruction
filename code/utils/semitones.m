function tones = semitones(init_freq)
    tones = zeros(13,1);
    tones(1) = init_freq;
    for ii = 2:length(tones)
        tones(ii) = 2^(1/12)*tones(ii-1);
    end
end
