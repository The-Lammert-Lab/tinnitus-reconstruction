% ### rand_str
% 
% Generates a random string of length `len`
% with numbers 0-9 and letters Aa-Zz
% 
% **ARGUMENTS:**
% 
% - len: `1 x 1` positive integer, default: `8`
%       the length of the string
% 
% **OUTPUTS:**
% 
% - str: `1 x len` random character vector

function str = rand_str(len)
    arguments
        len (1,1) {mustBePositive, mustBeInteger} = 8
    end
    symbols = ['a':'z' 'A':'Z' '0':'9'];
    nums = randi(numel(symbols),[1 len]);
    str = symbols(nums);
end
