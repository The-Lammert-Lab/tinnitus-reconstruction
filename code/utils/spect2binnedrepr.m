% ### spect2binnedrepr
% 
% binned_repr = spect2binnedrepr(T, B)
% binned_repr = spect2binnedrepr(T, B, n_bins)
%
% Get the binned representation,
% which is a vector containing the amplitude
% of the spectrum in each frequency bin.
%
% ARGUMENTS:
%   T: n_trials x n_frequencies matrix
%       representing the stimulus spectra
% 
%   B: 1 x n_frequencies vector
%       representing the bin numbers
%   (e.g., [1, 1, 2, 2, 2, 3, 3, 3, 3, ...])
% 
%   n_bins: 1x1 scalar
%       representing the number of bins
%       if not passed as an argument,
%       it is computed from the maximum of B
% 
% OUTPUTS:
%   binned_repr: n_trials x n_bins matrix
%       representing the amplitude for each frequency bin
%       for each trial
% 
% See Also: 
% * [binnedrepr2spect](./binnedrepr2spect)
% * [spect2bin](./spect2bin)
% * [bin2spect](./bin2spect)

function binned_repr = spect2binnedrepr(T, B, n_bins)

    if nargin < 3
        n_bins = max(B);
    end

    binned_repr = zeros(size(T, 1), n_bins);
    for bin_num = 1:n_bins
        a = T(:, B == bin_num);
        binned_repr(:, bin_num) = mean(a, 2);
    end
end