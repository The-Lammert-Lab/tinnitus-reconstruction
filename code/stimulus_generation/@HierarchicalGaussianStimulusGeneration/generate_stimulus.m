% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% 
% Generate a vector of stimuli where
% the bin amplitudes are `self.unfilled_dB` for an unfilled bin
% and `self.filled_dB` for a filled bin.
% Filled bins are chosen uniformly from unfilled bins, one at a time.
% The total number of bins-to-be-filled is chosen from a Gaussian distribution.
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
%   - n_bins
%   - n_bins_filled_mean
%   - n_bins_filled_var
%   - unfilled_dB
%   - filled_dB
% ```
% 
% See Also: 
% AbstractBinnedStimulusGenerationMethod.get_freq_bins
% AbstractStimulusGenerationMethod.generate_stimuli_matrix

function [stim, Fs, X, binned_repr, w] = generate_stimulus(self)
    B = self.get_basis();
    Fs = self.get_fs();
    
    % Multiply by random weights
    w = rand(size(B,2),1);
    X = self.scale_fact*rescale(B*w);

    % Synthesize audio
    stim = self.synthesize_audio(X,self.nfft);

    binned_repr = [];
end
