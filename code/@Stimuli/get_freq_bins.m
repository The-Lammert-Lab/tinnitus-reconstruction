function [binnum, Fs, nfft] = get_freq_bins(self)
    % Generates a vector indicating
    % which frequencies belong to the same bin,
    % following a tonotopic map of audible frequency perception.

    Fs = 2*self.max_freq; % sampling rate of waveform
    nfft = Fs*self.bin_duration; % number of samples for Fourier transform
    % nframes = floor(totaldur/self.bin_duration); % number of temporal frames

    % Define Frequency Bin Indices 1 through self.n_bins
    bintops = round(mels2hz(linspace(hz2mels(self.min_freq), hz2mels(self.max_freq), self.n_bins+1)));
    binst = bintops(1:end-1);
    binnd = bintops(2:end);
    binnum = linspace(self.min_freq, self.max_freq, nfft/2);
    for itor = 1:self.n_bins
        binnum(binnum <= binnd(itor) & binnum >= binst(itor)) = itor;
    end
