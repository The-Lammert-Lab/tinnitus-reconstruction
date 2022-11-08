% ### get_highest_power_of_2
% Compute the highest power of two less than or equal
% to a number.
% For example, an input of 9 would return 8.
% 
% **EXAMPLE:**
% 
% ```matlab
% n = get_highest_power_of_2(N);
% ```
% 
% **ARGUMENTS:**
%   - N: a 1x1 scalar, positive, real integer
% 
% **OUTPUTS:**
%   - n: a 1x1 scalar, positive, real power of 2
% 

function n = get_highest_power_of_2(N)

    arguments
        N (1,1) {mustBeReal, mustBeInteger, mustBePositive}
    end

    % If N is a power of 2, return it.
    if ~bitand(N, N - 1)
        n = N;
        return
    end

    % Set only the most significant bit
    n = double(bitshift(0x8000000000000000, length(dec2bin(N)) - 64));
end