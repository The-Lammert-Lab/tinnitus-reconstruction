function [stim, Fs, nfft] = generate_stimuli(options)
    % Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
    % amplitudes based on a tonotopic map of audible frequency perception.

    arguments
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

    % Generate Random Freq Spec in dB Acccording to Frequency Bin Index
    
    % master list of frequency bins unfilled
    frequency_bin_list = 1:options.n_bins;

    % sample from Gaussian distribution to get the number of bins to fill
    n_bins_to_fill = normrnd(options.n_bins_filled_mean, options.n_bins_filled_var);

    % fill the bins
    X = -20 * ones(nfft/2, 1);
    for ii = 1:n_bins_to_fill
        % select a bin at random from the list
        random_bin_index = 0;
        while random_bin_index < 1 || random_bin_index > options.n_bins
            random_bin_index = randi([1 length(frequency_bin_list)], 1, 1);
        end
        bin_to_fill = frequency_bin_list(random_bin_index);
        % fill that bin
        X(binnum==bin_to_fill) = 0;
        % remove that bin from the master list
        frequency_bin_list(frequency_bin_list==bin_to_fill) = [];
    end
    % X = zeros(nfft/2,1);
    % for itor = 1:options.n_bins
    %     X(binnum==itor) = -20 * floor(2 * rand(1,1) .^ options.prob_f);
    % end

    % Synthesize Audio
    phase = 2*pi*(rand(nfft/2,1)-0.5); % assign random phase to freq spec
    s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
    ss = [1; s; conj(flipud(s))];
    stim = ifft(ss); % transform from freq to time domain
end % function