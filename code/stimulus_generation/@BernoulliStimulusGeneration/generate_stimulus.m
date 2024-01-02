% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, X, binned_repr] = generate_stimulus(self)
% ```
% 
% Generate a stimulus vector of length `self.nfft+1`.
% Bins are filled with an an amplitude of `self.unfilled_dB` or `self.filled_dB`.
% Each bin is randomly filled with a change of being filled
% (amplitude = 0) with a probability of `self.bin_prob`.
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
%   n_bins
%   bin_prob
%   unfilled_dB
%   filled_dB
% ```

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();
    binned_repr = zeros(self.n_bins, 1);
    
    % get the amplitude values
    amplitude_values = self.unfilled_dB * ones(self.n_bins, 1);
    amplitude_values(rand(self.n_bins, 1) < self.bin_prob) = self.filled_dB;

    for ii = 1:self.n_bins
        binned_repr(ii) = amplitude_values(ii);
        spect(binnum==ii) = amplitude_values(ii);
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

end % function
