% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% TODO: write documentation
% 
% **OUTPUTS:**
% 
%   stim: `n x 1` numerical vector,
%       the stimulus waveform,
%       where `n` is `self.get_nfft() + 1`.
% 
%   Fs: `1x1` numerical scalar,
%       the sample rate in Hz.
% 
%   spect: `m x 1` numerical vector,
%       the half-spectrum,
%       where m is `self.get_nfft() / 2`,
%       in dB.
% 
%   binned_repr: `self.n_bins x 1` numerical vector,
%       the binned representation.
% 
%   frequency_vector: `m x 1` numerical vector,
%       the frequencies associated with the spectrum,
%       where `m` is `self.get_nfft() / 2`,
%       in Hz.
% 
% Class Properties Used:
% 
% ```
%   n_bins
%   amplitude_values
% ```
% 
% See Also: 
% AbstractBinnedStimulusGenerationMethod.get_freq_bins
% AbstractStimulusGenerationMethod.generate_stimuli_matrix

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)

    [~, Fs, nfft, frequency_vector, bin_starts, bin_stops] = self.get_freq_bins();
    spect = self.get_empty_spectrum();
    binned_repr = zeros(self.n_bins, 1);

    for ii = 1:self.n_bins
        this_amplitude_value = self.amplitude_values(randi(length(self.amplitude_values)));
        binned_repr(ii) = this_amplitude_value;

        % mu: the center of the bin
        mu = ((bin_starts(ii) + bin_stops(ii)) / 2);
        % sigma: half the width of the bin
        sigma = ((bin_stops(ii) - bin_starts(ii)) / 2);

        % Create a normal distribution with the correct number of points
        normal = normpdf(frequency_vector, mu, sigma);
        % Rescale spectrum
        normal = this_amplitude_value * normal ./ max(normal);

        % Adda to the spectrum
        spect = spect + normal;
    end

    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);


end % function