classdef (Abstract) AbstractBinnedStimulusGenerationMethod < AbstractStimulusGenerationMethod
% Abstract class describing a stimulus generation method
% that uses bins.

properties
    n_bins (1,1) {mustBePositive, mustBeInteger} = 100
end % abstract properties

methods

    function [binnum, Fs, nfft, frequency_vector, bin_starts, bin_stops] = get_freq_bins(self)
        % ### get_freq_bins
        % 
        % ```matlab
        % [binnum, Fs, nfft, frequency_vector] = self.get_freq_bins()
        % ```
        % 
        % Generates a vector indicating
        % which frequencies belong to the same bin,
        % following a tonotopic map of audible frequency perception.
        % 
        % **OUTPUTS:**
        % 
        %   - binnum: `n x 1` numerical vector
        %       that contains the mapping from frequency to bin number
        %       e.g., `[1, 1, 2, 2, 2, 3, 3, 3, 3, ...]`
        % 
        %   - Fs: `1x1` numerical scalar,
        %       the sampling rate in Hz
        % 
        %   - nfft: `1x1` numerical scalar,
        %       the number of points of the full FFT
        %
        %   - frequency_vector: `n x 1` numerical vector.
        %       the frequencies that `binnum` maps to bin numbers
        % 
        % See Also: 
        % AbstractStimulusGenerationMethod.get_fs
        % AbstractStimulusGenerationMethod.get_nfft

        Fs = self.get_fs(); % sampling rate of waveform
        nfft = self.get_nfft(); % number of samples for Fourier transform
        % nframes = floor(totaldur/self.bin_duration); % number of temporal frames

        % Define Frequency Bin Indices 1 through self.n_bins
        bintops = round(mels2hz(linspace(hz2mels(self.min_freq), hz2mels(self.max_freq), self.n_bins+1)));
        bin_starts = bintops(1:end-1);
        bin_stops = bintops(2:end);
        binnum = zeros(nfft/2, 1);
        frequency_vector = linspace(0, Fs/2, nfft/2)';

        for itor = 1:self.n_bins
            binnum(frequency_vector <= bin_stops(itor) & frequency_vector >= bin_starts(itor)) = itor;
        end

    end % function

    function spect = get_empty_spectrum(self)
        % ### get_empty_spectrum
        % 
        % ```matlab
        % [spect] = self.get_empty_spectrum()
        % ```
        % 
        % **OUTPUTS:**
        % 
        %   - spect: `n x 1` numerical vector,
        %   where `n` is equal to the number of fft points (nfft)
        %   and all values are set to -100 dB.
        % 
        % See Also:
        % AbstractBinnedStimulusGenerationMethod.get_freq_bins

        spect = -100 * ones(self.get_nfft() / 2, 1);

    end % function


    function binned_repr = spect2binnedrepr(self, T)
        % ### spect2binnedrepr
        % 
        % Get the binned representation
        % which is a vector containing the amplitude
        % of the spectrum in each frequency bin.
        % 
        % **ARGUMENTS:**
        % 
        %   - T: `n_frequencies x n_trials` matrix
        %       representing the stimulus spectra
        % 
        % **OUTPUTS:**
        % 
        %   - binned_repr: `n_trials x n_bins` matrix
        %       representing the amplitude for each frequency bin
        %       for each trial
        % 
        % See Also: 
        % binnedrepr2spect
        % spect2binnedrepr
        % AbstractBinnedStimulusGenerationMethod.binnedrepr2wav

        binned_repr = zeros(self.n_bins, size(T, 2));
        B = self.get_freq_bins();
        
        assert(length(T) == length(B));

        for bin_num = 1:self.n_bins
            a = T(B == bin_num, :);
            binned_repr(bin_num, :) = mean(a,1);
        end

    end % function

    function T = binnedrepr2spect(self, binned_repr)
        % ### binnedrepr2spect
        % 
        % Get the stimuli spectra from a binned representation.
        %
        % **ARGUMENTS:**
        % 
        % - binned_repr: `n_bins x n_trials`
        %   representing the amplitude in each frequency bin
        %   for each trial
        % 
        % **OUTPUTS:**
        % 
        % - T: `n_frequencies x n_trials`
        %   representing the stimulus spectra
        % 
        % See also:
        % binnedrepr2spect
        % spect2binnedrepr
        % AbstractBinnedStimulusGenerationMethod.binnedrepr2wav

        B = self.get_freq_bins();
        T = -100 * ones(length(B), size(binned_repr, 2));
        for bin_num = 1:self.n_bins
            T(B == bin_num, :) = repmat(binned_repr(bin_num, :), sum(B == bin_num), 1);
        end
    end

    function [wav, X] = binnedrepr2wav(self, binned_rep, mult, binrange, new_n_bins)
        % ### binnedrepr2wav
        %
        % Get the peak-sharpened waveform of a binned representation 
        %
        % **ARGUMENTS:**
        %
        %   - binned_repr: `n_bins x 1` numerical vector
        %       representing the amplitude in each frequency bin.
        %   - mult: `1 x 1` scalar, the peak sharpening factor.
        %   - binrange: `1 x 1` scalar, must be between [1, 100],
        %       the upper bound of the dynamic range of the 
        %       stimuli from [0, binrange]
        %   - new_n_bins: `1 x 1` scalar, default: 256,
        %       the number of bins to upsample to before synthesis.
        %
        % **OUTPUTS:**
        %
        %   - wav: `nfft+1 x 1` numerical vector
        %       representing the upsampled, peak-sharpened
        %       wavform of the binned representation.
        %   - X: `nfft/2 x 1` numerical vector,
        %       the upsampled, peak-sparpened 
        %       spectrum of the binned representation.
        % 
        % See Also:
        % binnedrepr2spect
        % spect2binnedrepr

        arguments
            self (1,1) AbstractBinnedStimulusGenerationMethod
            binned_rep (:,1) {mustBeReal}
            mult (1,1) {mustBePositive}
            binrange (1,1) {mustBeGreaterThanOrEqual(binrange,1), mustBeLessThanOrEqual(binrange,100)}
            new_n_bins (1,1) {mustBeInteger, mustBePositive} = 256
        end

        % Setup
        nfft = self.get_nfft();
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Rescale dynamic range of audio signal by adjusting bin heights
        binned_rep = binrange*rescale(binned_rep);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Interpolate to `new_n_bins` bins via spline interpolation
        binidx = 1:self.n_bins;
        binidx2 = linspace(1,self.n_bins,new_n_bins);
        binned_rep = interp1(binidx,binned_rep,binidx2,'spline');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get bin numbers for the new number of bins
        old_n_bins = self.n_bins;
        self.n_bins = new_n_bins;

        binnum = self.get_freq_bins();

        % Reset n_bins
        self.n_bins = old_n_bins;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Sharpen peaks in interpolated spectrum
        thing = conv(binned_rep,[1 -2 1],'same');
        thing([1,end]) = 0;
        thing2 = conv(thing,[1 -2 1],'same');
        thing2([1:2,end-1:end]) = 0;
        binned_rep = binned_rep - (mult*(50^2)/40)*thing + (mult*(50^4)/600)*thing2;
        binned_rep = binned_rep-min(binned_rep);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Assign power to bins
        X = zeros(nfft/2,1);
        for itor = 1:new_n_bins
            X(binnum==itor) = binned_rep(itor);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % Synthesize audio
        stim = self.synthesize_audio(X,nfft);
        stim = stim./max(abs(stim));
        wav = stim./(8*sqrt(mean(stim.^2)));
    end

    function W = bin_signal(self, W, Fs)
        % ### bin_signal
        % 
        % ```matlab
        % W = self.bin_signal(W)
        % ```
        % 
        % Inputs a waveform,
        % converts to a spectrum,
        % bins the spectrum,
        % and then converts back to a waveform.
        % 
        % **ARGUMENTS:**
        % 
        %   W: `n x 1` numerical vector,
        %       the waveform
        %   Fs: `1x1` numerical scalar,
        %       the sample rate
        % 
        % See Also: 
        % AbstractBinnedStimulusGenerationMethod.binnedrepr2spect 
        % AbstractBinnedStimulusGenerationMethod.spect2binnedrepr 
        % signal2spect

        arguments
            self (1,1) AbstractBinnedStimulusGenerationMethod
            W {mustBeReal}
            Fs = []
        end

        if isempty(Fs)
            Fs = self.get_fs();
        end

        if mod(length(W), 2) ~= 0
            warning('W is not of even length, will zero-pad.')
            W(end+1, :) = 0;
        end

        nfft = length(W);
        dur = self.duration;

        self.duration = nfft / Fs;

        W = signal2spect(W);
        W = self.spect2binnedrepr(W);
        W = self.binnedrepr2spect(W);
        W = self.synthesize_audio(W, nfft);

        self.duration = dur;

    end
        

end % methods

end % classdef