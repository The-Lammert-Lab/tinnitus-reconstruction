% ### generate_stimulus
%
% ```matlab
%  [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% Generates stimuli by generating a frequency spectrum with -100 dB and 0 dB
% amplitudes based on a tonotopic map of audible frequency perception.
% 
% **OUTPUTS:**
% 
%   - stim: `n x 1` numerical vector,
%       the stimulus waveform,
%       where `n` is `self.nfft + 1`.
%   - Fs: `1x1` numerical scalar,
%       the sample rate in Hz.
%   - spect: `m x 1` numerical vector,
%       the half-spectrum,
%       where `m` is `self.nfft / 2`,
%       in dB.
%   - binned_repr: `self.n_bins x 1` numerical vector,
%       the binned representation.
%   - frequency_vector: `m x 1` numerical vector
%       The frequencies associated with the spectrum,
%       where `m` is `self.nfft / 2`,
%       in Hz.
% 
% **Class Properties Used:**
% ```
% - n_bins
% - n_bins_range
% ```

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % Randomize the number of bins
    self.n_bins = self.n_bins_range(randi(length(self.n_bins_range)));

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % sample from uniform distribution to get the number of bins to fill
    n_bins_to_fill = randi(self.n_bins);
    bins_to_fill = randsample(1:self.n_bins,n_bins_to_fill,false);

    % Fill the bins
    [rows_to_fill, ~] = find(binnum==bins_to_fill);
    spect(rows_to_fill) = self.filled_dB;

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

    % get the binned representation
    binned_repr = self.unfilled_dB * ones(self.n_bins, 1);
    binned_repr(bins_to_fill) = self.filled_dB;
end
