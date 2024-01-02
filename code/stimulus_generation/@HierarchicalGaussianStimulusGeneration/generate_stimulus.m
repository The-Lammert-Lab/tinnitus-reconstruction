% ### generate_stimulus
% 
% ```matlab
% [stim, Fs, spect, binned_repr, w] = generate_stimulus(self)
% ```
% 
% Generate a stimulus by applying random weights to a basis of Gaussians.
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
%   w: `self.n_broad + self.n_med + self.n_narrow x 1` numerical vector,
%       the weight vector corresponding to the each curve.
% 
% **Class Properties Used:**
% 
% ```
%   - scale_fact
% ```
% 
% See Also: 
% HierarchicalGaussianStimulusGeneration.get_basis
% AbstractStimulusGenerationMethod.generate_stimuli_matrix

function [stim, Fs, spect, binned_repr, w] = generate_stimulus(self)
    B = self.get_basis();
    Fs = self.get_fs();
    
    % Multiply by random weights
    w = rand(size(B,2),1);
    spect = self.scale_fact*rescale(B*w);

    % Synthesize audio
    stim = self.synthesize_audio(spect,self.nfft);

    binned_repr = [];
end
