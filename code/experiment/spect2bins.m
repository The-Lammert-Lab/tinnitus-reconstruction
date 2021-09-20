function binary_repr = spect2bins(X, options)

    %   binary_repr = spect2bins(X, options)

    % Go from a spectrum representation of a stimulus
    % to a binary representation, where there is a true
    % value when a bin is filled and false elsewhere.
    %
    % X: vector representing the stimulus spectrum in dB
    % 
    
    arguments
        X {mustBeNumeric}
        options.min_freq (1,1) {mustBeNumeric} = 100
        options.max_freq (1,1) {mustBeNumeric} = 22e3
        options.n_bins (1,1) {mustBeNumeric} = 100
        options.bin_duration (1,1) {mustBeNumeric} = 0.4
        % options.prob_f (1,1) {mustBeNumeric} = 0.4
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

    % Compute the binary representation
    % where there is a 'true', whenever there is
    % a filled bin and 'false' elsewhere
    binary_repr = false(options.n_bins, 1);
    for ii = 1:options.n_bins
        binary_repr(ii) = any(X(binnum == ii) >= 0);
    end

end % function