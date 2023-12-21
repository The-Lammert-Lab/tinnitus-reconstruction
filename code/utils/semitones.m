% ### semitones 
% 
% Returns one octave of semitones from the initial frequency,
% includes both octave endpoints.
% 
% **ARGUMENTS:**
% 
%   - init_freq: `1 x 1` scalar, the initial frequency.
%   - n: `1 x 1` positive integer, default: `12`,
%       the number of semitones above init_freq to to return.
%   - direction: `char`, default: `'up'`, options: `'up'`, `'down'`.
%       direction in which to generate semitones from `init_freq`.
% 
% **OUTPUTS:**
% 
%   - tones: `n+1 x 1` numerical vector, 
%       `n+1` semitones starting at `init_freq`.

function tones = semitones(init_freq, n, direction)
    arguments
        init_freq (1,1) {mustBeReal}
        n (1,1) {mustBePositive, mustBeInteger} = 12
        direction (1,:) char = 'up'
    end

    tones = zeros(n+1,1);
    tones(1) = init_freq;
    for ii = 2:length(tones)
        switch direction
            case 'up'
                tones(ii) = 2^(1/12)*tones(ii-1);
            case 'down'
                tones(ii) = 2^(-1/12)*tones(ii-1);
            otherwise
                error(['Unknown direction: ', direction, 'specified'])
        end
    end
end
