% ### gen_octaves 
% 
% Returns a vector of doubled values from 
% min_freq to as close to max_freq as possible 
% with optional, equally spaced in-octave values.
% 
% **ARGUMENTS:**
% 
%   - min_freq: `1 x 1` scalar, the minimum and initial frequency
%   - max_freq: `1 x 1` scalar, the maximum possible frequency, 
%       not guaranteed to be in the final array.
%   - n_in_oct: `1 x 1` integer, the number of points inside each octave.
%       If `spacing_type` == `'semitone'`, 
%       `n_in_oct` must be in {1,2,3,5,11}. 
%       Otherwise, can be any integer >= 0.
%   - spacing_type: `char`, default: `'semitone'`, 
%       the in-octave spacing method. 
%       `'linear'` returns linearly spaced spaced values
%       `'semitone'` splits the octave into half notes 
%       then chooses `n_in_oct` evenly spaced values.
% 
%   **OUTPUTS:**
% 
%   - freqs: `n x 1` numerical vector of octaves starting at `min_freq`.

function freqs = gen_octaves(min_freq, max_freq, n_in_oct, spacing_type)
    arguments
        min_freq (1,1) {mustBeReal}
        max_freq (1,1) {mustBeReal,mustBeGreaterThan(max_freq,min_freq)}
        n_in_oct (1,1) {mustBeInteger, mustBeGreaterThanOrEqual(n_in_oct,0)} = 0
        spacing_type (1,:) char = 'semitone'
    end

    n_octs = floor(log2(max_freq/min_freq)); % Number of octaves between min and max
    oct_vals = min_freq * 2.^(0:n_octs); % Octave frequency values
    
    freqs = zeros(length(oct_vals)+(n_in_oct*n_octs),1);
    oct_marks = 1:n_in_oct+1:length(freqs);
    for ii = 1:n_octs
        switch spacing_type
            case 'linear'
                freqs(oct_marks(ii):oct_marks(ii)+n_in_oct+1) = linspace(oct_vals(ii),oct_vals(ii+1),n_in_oct+2);
            case 'semitone'
                half_steps = semitones(oct_vals(ii));
                inds = linspace(1,length(half_steps),n_in_oct+2);

                % Provide a more useful message if indices aren't integers
                % A way to check this before loop would be nice.
                if all(rem(inds,1))
                    error(['Unable to break semitone scaling into ', num2str(n_in_oct), ' intervals inside an octave'])
                end
                freqs(oct_marks(ii):oct_marks(ii)+n_in_oct+1) = half_steps(inds);
        end
    end
end
