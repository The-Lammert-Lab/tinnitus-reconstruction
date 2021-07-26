function [stim, Fs, nfft] = generate_stimuli(minfreq,maxfreq,nbins_freq,bindur,probfact)

% Example inputs
% minfreq = 100; % minimum frequency for synthesis
% maxfreq = 22000; % maximum frequency for synthesis
% nbins_freq = 100; % number of frequency bins
% bindur = 0.02; % duration of the time bins in seconds
% probfact = 0.40; %(0.35 1.0)

% Stimulus Configuration
Fs = 2*maxfreq; % sampling rate of waveform
nfft = Fs*bindur; % number of samples for Fourier transform
% nframes = floor(totaldur/bindur); % number of temporal frames

% Define Frequency Bin Indices 1 through nbins_freq
bintops = round(mels2hz(linspace(hz2mels(minfreq),hz2mels(maxfreq),nbins_freq+1)));
binst = bintops(1:end-1);
binnd = bintops(2:end);
binnum = linspace(minfreq,maxfreq,nfft);
for itor = 1:nbins_freq
    binnum(binnum<=binnd(itor) & binnum>=binst(itor)) = itor;
end

% Generate Random Freq Spec in dB Acccording to Frequency Bin Index
X = zeros(nfft,1);
for itor = 1:nbins_freq
    X(binnum==itor) = -20*floor(2*rand(1,1).^probfact);
end

% XX = zeros(nfft,nframes); % time-frequency stimulus
% Y = zeros(nfft*nframes,1); % time-domain stimulus 
% for ftor = 1:nframes
    
% Generate Random Freq Spec in dB According to Frequency Bin Index
for itor = 1:nbins_freq
    X(binnum==itor) = -20*floor(2*rand(1,1).^probfact);
    % X(binnum==itor) = -100 * rand(1, 1);
end
    
% Synthesize Audio
phase = 2*pi*(rand(nfft,1)-0.5); % assign random phase to freq spec
s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
y = ifft(s); % transform from freq to time domain
        
% end
stim = real(y);% .* hamming(length(y));
% stim = real(Y).*hamming(length(Y));
% stim_tf = XX;

%eof