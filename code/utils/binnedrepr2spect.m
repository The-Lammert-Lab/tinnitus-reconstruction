% ### binnedrepr2spect  
% 
% ```matlab
%   T = binnedrepr2spect(binned_repr, B)
%   T = binnedrepr2spect(binned_repr, B, n_bins)
% ```
%
% Get the stimuli spectra from a binned representation.
%
% **ARGUMENTS:**
% 
%   - binned_repr: `n_trials x n_bins` matrix
%       representing the amplitude in each frequency bin
%       for each trial.
%   - B: `1 x n_frequencies` vector
%       representing the bin numbers
%       (e.g., `[1, 1, 2, 2, 2, 3, 3, 3, 3, ...]`)
%   - n_bins: `1 x 1` scalar
%       representing the number of bins
%       if not passed as an argument,
%       it is computed from the maximum of B
% 
% **OUTPUTS:**
% 
%   - T: `n_trials x n_frequencies` matrix
%       representing the stimulus spectra
% 
% See Also:
% spect2binnedrepr

function T = binnedrepr2spect(binned_repr, B, n_bins)

    if nargin < 3
        n_bins = max(B);
    end

    T = zeros(size(binned_repr, 1), length(B));
    for bin_num = 1:n_bins
        T(:, B == bin_num) = repmat(binned_repr(:, bin_num), 1, sum(B == bin_num));
    end
end