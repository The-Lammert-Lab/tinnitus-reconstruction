% ### generate_stimulus
%
% ```matlab
%  [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)
% ```
% 
% Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
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
% - n_bins_filled_mean
% - n_bins_filled_var
% ```

function [stim, Fs, spect, binned_repr, frequency_vector] = generate_stimulus(self)

    % Define Frequency Bin Indices 1 through self.n_bins
    [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins();
    spect = self.get_empty_spectrum();

    % Generate Random Freq Spec in dB Acccording to Frequency Bin Index
    
    % master list of frequency bins unfilled
    frequency_bin_list = 1:self.n_bins;

    % sample from uniform distribution to get the number of bins to fill
    n_bins_to_fill = randi([self.min_bins, self.max_bins], 1);

    if n_bins_to_fill < 1
        n_bins_to_fill = 1;
    end

    filled_bins = zeros(length(n_bins_to_fill), 1);

    % fill the bins
    for ii = 1:n_bins_to_fill
        % select a bin at random from the list
        random_bin_index = 0;
        while random_bin_index < 1 || random_bin_index > self.n_bins
            random_bin_index = randi([1 length(frequency_bin_list)], 1, 1);
        end
        bin_to_fill = frequency_bin_list(random_bin_index);
        filled_bins(ii) = bin_to_fill;
        % fill that bin
        spect(binnum==bin_to_fill) = self.filled_dB;
        % remove that bin from the master list
        frequency_bin_list(frequency_bin_list==bin_to_fill) = [];
    end


    % Synthesize Audio
    stim = self.synthesize_audio(spect, nfft);

    % get the binned representation
    binned_repr = self.unfilled_dB * ones(self.n_bins, 1);
    binned_repr(filled_bins) = self.filled_dB;

end