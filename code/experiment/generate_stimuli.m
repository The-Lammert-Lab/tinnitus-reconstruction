function [stim, Fs, nfft] = generate_stimuli(varargin)
    % Generates stimuli by generating a frequency spectrum with -20 dB and 0 dB
    % amplitudes based on a tonotopic map of audible frequency perception.

    options = struct;
    options.min_freq = 100;
    options.max_freq = 22e3;
    options.n_bins = 100;
    options.bin_duration = 0.4;
    options.prob_f = 0.4;

    if ~isempty(varargin)
        options = corelib.parseNameValueArguments(options, varargin);
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
    X = zeros(nfft/2,1);
    for itor = 1:options.n_bins
        X(binnum==itor) = -20 * floor(2 * rand(1,1) .^ options.prob_f);
    end

    % Synthesize Audio
    phase = 2*pi*(rand(nfft/2,1)-0.5); % assign random phase to freq spec
    s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
    ss = [1; s; conj(flipud(s))];
    stim = ifft(ss); % transform from freq to time domain
end % function