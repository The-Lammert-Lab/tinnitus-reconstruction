% ### generate_stimulus
% 
% Generate stimuli using a binless white-noise process
% with amplitudes randomly distributed between -20 and 0 dB.
% 
% **OUTPUTS:**
% 
%   stim: `self.nfft + 1 x 1` numerical vector,
%       the stimulus waveform,
% 
%   Fs: `1x1` numerical scalar,
%       the sample rate in Hz.
% 
%   spect: `self.nfft / 2 x 1` numerical vector,
%       the half-spectrum, in dB.
% 
%   binned_repr: `[]`, empty because this is not a binned class.

function [stim, Fs, X, binned_repr] = generate_stimulus(self)

    Fs = self.get_fs();
    nfft = self.nfft;
    
    % generate spectrum completely randomly
    % without bins
    % amplitudes are uniformly-distributed
    % between -20 and 0.
    X = -20 * rand(nfft/2, 1);

    % sythesize audio
    stim = self.synthesize_audio(X, nfft);

    % empty output
    binned_repr = [];

end % function