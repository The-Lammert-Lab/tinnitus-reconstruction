% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% Generates stimuli by assigning the power in each bin
% by sampling from a power distribution
% learned from ATA tinnitus examples.
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
%   - n_bins
% ```

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
 
    if isempty(self.distribution)
        error("self.distribution must not be empty!")
    end

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % Get the histogram of the power distribution for binning
    [pdf, bin_edges, ~] = histcounts(self.distribution, 16, 'Normalization', 'pdf');
    bin_centers = bin_edges(1) + cumsum(diff(bin_edges)/2);
    pdf = (pdf + 0.01 * mean(pdf));
    pdf = pdf/sum(pdf);
    cdf = cumsum(pdf);

    % Sample power values from the histogram
    r = rand(self.n_bins, 1);
    s = zeros(self.n_bins, 1);
    for ii = 1:length(r)
        [~, idx] = min((cdf - r(ii)) .^ 2);
        s(ii) = bin_centers(idx);
    end

    % Create the random frequency spectrum
    binned_repr = zeros(self.n_bins, 1);
    for ii = 1:self.n_bins
        spect(binnum==ii) = s(ii);
        binned_repr(ii) = s(ii);
    end

    % Generate the waveform
    stim = self.synthesize_audio(spect, nfft);



