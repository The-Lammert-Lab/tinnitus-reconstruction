% ### generate_stimulus
% 
% ```matlab
%  [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% 
% Generate a vector of stimuli where
% the bin amplitudes are chosen randomly
% from a uniform distribution over [-20, 0] dB.
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
% 
% ```
% - n_bins
% ```
% 
% See Also:
% AbstractBinnedStimulusGenerationMethod.get_freq_bins
% AbstractStimulusGenerationMethod.generate_stimuli_matrix

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();
    binned_repr = zeros(self.n_bins, 1);

    for ii = 1:self.n_bins
        this_amplitude_value = -20 * rand();
        binned_repr(ii) = this_amplitude_value;
        spect(binnum==ii) = this_amplitude_value;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

end % function
