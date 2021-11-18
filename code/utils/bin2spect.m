function [stim, Fs, X, f, filled_bins] = bin2spect(bin_repr, options)

    %   [stim, Fs, X, f, filled_bins] = bin2spect(bin_repr, options)
    % 
    % Generates stimuli from a bin representation
    % based on a tonotopic map of audible frequency perception.

    arguments
        bin_repr
        options.min_freq (1,1) {mustBeNumeric} = 100
        options.max_freq (1,1) {mustBeNumeric} = 22e3
        options.n_bins (1,1) {mustBeNumeric} = 100
        options.bin_duration (1,1) {mustBeNumeric} = 0.4
        options.n_bins_filled_mean (1,1) {mustBeNumeric} = 10
        options.n_bins_filled_var (1,1) {mustBeNumeric} = 3
    end

    % Stimulus Configuration
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
    
    filled_bins = 1:options.n_bins;
    filled_bins(~bin_repr) = [];

    % fill the bins
    X = -20 * ones(nfft/2, 1);

    for ii = 1:filled_bins
        X(binnum == filled_bins(ii)) = 0;
    end

    % Synthesize Audio
    f = linspace(options.min_freq, options.max_freq, length(X));
    phase = 2*pi*(rand(nfft/2,1)-0.5); % assign random phase to freq spec
    s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
    ss = [1; s; conj(flipud(s))];
    stim = ifft(ss); % transform from freq to time domain

end % function