% ### semitones 
% 
% Returns one octave of semitones from the initial frequency,
% includes both octave endpoints.
% 
% **ARGUMENTS:**
% 
%   - init_freq: `1 x 1` scalar, the initial frequency.
% 
% **OUTPUTS:**
% 
%   - tones: `13 x 1` numerical vector, 
%       one octave worth of semitones starting at `init_freq`

function tones = semitones(init_freq)
    arguments
        init_freq (1,1) {mustBeReal}
    end

    tones = zeros(13,1);
    tones(1) = init_freq;
    for ii = 2:length(tones)
        tones(ii) = 2^(1/12)*tones(ii-1);
    end
end
