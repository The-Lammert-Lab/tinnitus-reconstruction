% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ``` 
% 
% Generate a stimulus vector of length `self.nfft+1`
% where the bin of a randomly chosen frequency is filled.
%
% **OUTPUTS:**
% 
%   stim: `self.nfft + 1 x 1` numerical vector,
%       the stimulus waveform,
% 
%   Fs: `1x1` numerical scalar,
%       the sample rate in Hz.
% 
%   spect: `self.nfft / 2 x 1` numerical vector,
%       the half-spectrum, in dB.
% 
%   binned_repr: `self.n_bins x 1` numerical vector,
%       the binned representation.
% 
%   frequency_vector: `self.nfft / 2 x 1` numerical vector,
%       the frequencies associated with the spectrum, in Hz.
% 
% **Class Properties Used:**
% 
% ```
% - min_freq
% - max_freq
% - filled_dB
% - unfilled_dB
% ```

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % Pick a random index (frequency) and get bin number
    valid_inds = find(frequency_vector >= self.min_freq & frequency_vector <= self.max_freq);
    bin_to_fill = binnum(randi([min(valid_inds), max(valid_inds)]));

    % Fill the bin
    spect(binnum==bin_to_fill) = self.filled_dB;

    % Create a vector of unfilled bins and fill the selected one.
    binned_repr = self.unfilled_dB*ones(self.n_bins,1);
    binned_repr(bin_to_fill) = self.filled_dB;

    stim = self.synthesize_audio(spect, nfft);
end
