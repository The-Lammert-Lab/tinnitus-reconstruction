% ### generate_stimuli_matrix
%
% ```matlab
% [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix] = generate_stimuli_matrix(self)
% ```
%
% Unique function for `UniformPriorRandomNBinsStimulusGeneration`
% Since self.n_bins is changed at each `generate_stimulus()` call,
% This function pads the matrix with NaN values.
% Generates a matrix of stimuli.
% Explicitly calls the `generate_stimulus()`
% class method.
%
% **OUTPUTS:**
%
%   - stimuli_matrix: `n x self.n_trials` numerical vector,
%       the stimulus waveform,
%       where `n` is `self.nfft + 1`.
%
%   - Fs: `1x1` numerical scalar,
%       the sample rate in Hz.
%
%   - spect_matrix: `m x self.n_trials` numerical vector,
%       the half-spectrum,
%       where `m` is `self.nfft / 2`,
%       in dB.
%
%   - binned_repr_matrix: `self.n_bins x self.n_trials` numerical vector,
%       the binned representation.
%
% See Also:
% UniformPriorRandomNBinsStimulusGeneration.generate_stimulus

function [stimuli_matrix, Fs, spect_matrix, binned_repr_matrix, W] = generate_stimuli_matrix(self)
    % generate first stimulus
    binned_repr_matrix = NaN(max(self.n_bins_range), self.n_trials);
    [stim1, Fs, spect, binned_repr, ~] = self.generate_stimulus();
    binned_repr_matrix(1:length(binned_repr),1) = binned_repr;

    % instantiate stimuli matrix
    stimuli_matrix = zeros(length(stim1), self.n_trials);
    spect_matrix = zeros(length(spect), self.n_trials);
    stimuli_matrix(:, 1) = stim1;
    spect_matrix(:, 1) = spect;
    for ii = 2:self.n_trials
        [stimuli_matrix(:, ii), ~, spect_matrix(:, ii), binned_repr] = self.generate_stimulus();
        binned_repr_matrix(1:length(binned_repr), ii) = binned_repr;
    end

    % Trim to smallest number of bins (if max(n_bins) was never hit during randomization)
    [r,~] = find(~isnan(binned_repr_matrix));
    most_bins_filled = max(r);
    binned_repr_matrix(most_bins_filled+1:end,:) = [];

    W = [];
end
