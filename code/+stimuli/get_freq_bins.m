function [binnum, Fs, nfft] = get_freq_bins(options)
    % Generates a vector indicating
    % which frequencies belong to the same bin,
    % following a tonotopic map of audible frequency perception.

    arguments
        options.n_bins (1,1) {mustBeNumeric} = 100
        options.min_freq (1,1) {mustBeNumeric} = 100
        options.max_freq (1,1) {mustBeNumeric} = 22e3
    end

    Fs = 2*options.max_freq; % sampling rate of waveform
    nfft = Fs*options.bin_duration; % number of samples for Fourier transform
    % nframes = floor(totaldur/options.bin_duration); % number of temporal frames

    % Define Frequency Bin Indices 1 through options.n_bins
    bintops = round(mels2hz(linspace(hz2mels(options.min_freq), hz2mels(options.max_freq), options.n_bins+1)));
    binst = bintops(1:end-1);
    binnd = bintops(2:end);
    binnum = linspace(options.min_freq, options.max_freq, nfft/2);
    for itor = 1:options.n_bins
        binnum(binnum <= binnd(itor) & binnum >= binst(itor)) = itor;
    end