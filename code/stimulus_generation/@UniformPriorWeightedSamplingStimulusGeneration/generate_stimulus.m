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
%       where `n` is `self.get_nfft() + 1`.
%   - Fs: `1x1` numerical scalar,
%       the sample rate in Hz.
%   - spect: `m x 1` numerical vector,
%       the half-spectrum,
%       where `m` is `self.get_nfft() / 2`,
%       in dB.
%   - binned_repr: `self.n_bins x 1` numerical vector,
%       the binned representation.
%   - frequency_vector: `m x 1` numerical vector
%       The frequencies associated with the spectrum,
%       where `m` is `self.get_nfft() / 2`,
%       in Hz.
% 
% **Class Properties Used:**
% ```
% - n_bins
% ```

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % Generate Random Freq Spec in dB Acccording to Frequency Bin Index
    
    % sample from uniform distribution to get the number of bins to fill
    n_bins_to_fill = randi([self.min_bins, self.max_bins], 1);

    % sample from a weighted distribution without replacement
    % to get the bins that should be filled
    filled_bins = self.sample(n_bins_to_fill);

    % fill those bins
    for ii = 1:length(filled_bins)
        spect(binnum == filled_bins(ii)) = 0;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

    % get the binned representation
    binned_repr = -20 * ones(self.n_bins, 1);
    binned_repr(filled_bins) = 0;

end