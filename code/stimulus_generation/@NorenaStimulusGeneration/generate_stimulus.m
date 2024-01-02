% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr] = generate_stimulus(self)
% ```
% 
% Generate a stimulus where one random Hz value is 0dB and the rest are -100dB
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

function [stim, Fs, spect, binned_repr] = generate_stimulus(self)
    Fs = self.get_fs();
    nfft = self.nfft;

    spect = -100*ones(nfft/2, 1);
    spect(randi(length(spect))) = 0;
    stim = self.synthesize_audio(spect, nfft);

    binned_repr = [];
end
