% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr] = generate_stimulus(self)
% ```
% 
% Generate a stimulus using a binless white-noise process.
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
% 
% **Class Properties Used:**
% 
% ```
% - amplitude_mean
% - amplitude_var
% ```

function [stim, Fs, spect, binned_repr] = generate_stimulus(self)

    Fs = self.get_fs();
    nfft = self.nfft;

    % generate spectrum completely randomly
    % without bins
    % amplitudes are gaussian-distributed
    % with mean `self.amplitude_mean`
    % and standard deviation `self.amplitude_var`.
    spect = self.amplitude_mean + sqrt(self.amplitude_var) * randn(nfft/2, 1);

    % sythesize audio
    stim = self.synthesize_audio(spect, nfft);

    % empty output
    binned_repr = [];

end % function