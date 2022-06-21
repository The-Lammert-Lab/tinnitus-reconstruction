classdef (Abstract) AbstractBinnedStimulusGenerationMethod < AbstractStimulusGenerationMethod
% Abstract class describing a stimulus generation method
% that uses bins.

properties
    n_bins (1,1) {mustBePositive, mustBeInteger} = 100
end % abstract properties

methods

    function [binnum, Fs, nfft, frequency_vector] = get_freq_bins(self)
        % 
        %   [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins()  
        % 
        % Arguments:
        % 
        %   binnum: n x 1 numerical vector
        %       Contains the mapping from frequency to bin number
        %       e.g., [1, 1, 2, 2, 2, 3, 3, 3, 3, ...]
        % 
        %   Fs: 1x1 numerical scalar
        %       Sampling rate in Hz
        % 
        %   nfft: 1x1 numerical scalar
        %       Number of points of the full FFT
        %
        %   frequency_vector: n x 1 numerical vector
        %       Frequencies that `binnum` maps to bin numbers
        %  
        % Generates a vector indicating
        % which frequencies belong to the same bin,
        % following a tonotopic map of audible frequency perception.
        % 
        % See Also: get_fs, get_nfft


        Fs = self.get_fs(); % sampling rate of waveform
        nfft = self.get_nfft(); % number of samples for Fourier transform
        % nframes = floor(totaldur/self.bin_duration); % number of temporal frames

        % Define Frequency Bin Indices 1 through self.n_bins
        bintops = round(mels2hz(linspace(hz2mels(self.min_freq), hz2mels(self.max_freq), self.n_bins+1)));
        binst = bintops(1:end-1);
        binnd = bintops(2:end);
%         binnum = zeros(nfft/2, 1);
        frequency_vector = linspace(0, Fs/2, nfft/2)';

        for itor = 1:self.n_bins
            binnum(frequency_vector <= binnd(itor) & frequency_vector >= binst(itor)) = itor;
        end

    end % function

    function spect = get_empty_spectrum(self)
        % 
        %   [spect] = self.get_empty_spectrum();
        % 
        %   Returns:
        %       spect: n x 1 numerical vector
        %           where n is equal to the number of fft points (nfft).
        % 
        %   Returns a spectrum vector of the correct size
        %   with all values set to -100 dB.
        % 
        % See Also: get_freq_bins

        spect = -100 * ones(self.get_nfft() / 2, 1);

    end % function


    function binned_repr = spect2binnedrepr(self, T)
        % Get the binned representation
        % which is a vector containing the amplitude
        % of the spectrum in each frequency bin.
        % 
        % ARGUMENTS:
        % 
        %   T: n_frequencies x n_trials
        %       representing the stimulus spectra
        % 
        % OUTPUTS:
        % 
        %   binned_repr: n_trials x n_bins matrix
        %       representing the amplitude for each frequency bin
        %       for each trial
        % 
        % See Also: binnedrepr2spect, spect2binnedrepr

        binned_repr = zeros(self.n_bins, size(T, 2));
        B = self.get_freq_bins();
        for bin_num = 1:self.n_bins
            a = T(B == bin_num, :);
            binned_repr(bin_num, :) = a(1, :);
        end

    end % function

    function T = binnedrepr2spect(self, binned_repr)
        %
        % Get the stimuli spectra from a binned representation.
        %
        % ARGUMENTS:
        % binned_repr: n_bins x n_trials
        %   representing the amplitude in each frequency bin
        %   for each trial
        % 
        % OUTPUTS:
        % T: n_frequencies x n_trials
        %   representing the stimulus spectra
        % 
        % See Also: binnedrepr2spect, spect2binnedrepr

        B = self.get_freq_bins();
        T = zeros(length(B), size(binned_repr, 2));
        for bin_num = 1:self.n_bins
            T(B == bin_num, :) = repmat(binned_repr(bin_num, :), sum(B == bin_num), 1);
        end
    end

end % methods

end % classdef