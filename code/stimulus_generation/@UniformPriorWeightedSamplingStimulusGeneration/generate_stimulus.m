% ### generate_stimulus
%
% ```matlab
%  [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% Generates a stimulus by generating a frequency spectrum 
% with `self.unfilled_dB` and `self.filled_dB` dB amplitudes. 
% The number of filled bins is selected
% from a uniform distribution on `[self.min_bins, self.max_bins]`, 
% but which bins are filled is determined from a non-uniform distribution.
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
% - n_bins
% ```
% 
% See Also:
% UniformPriorWeightedSamplingStimulusGeneration.sample

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
        spect(binnum == filled_bins(ii)) = self.filled_dB;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

    % get the binned representation
    binned_repr = self.unfilled_dB * ones(self.n_bins, 1);
    binned_repr(filled_bins) = self.filled_dB;

end