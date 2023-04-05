% ### generate_stimulus
% 
% Generate stimuli using a binless white-noise process.
% 
% Class Properties Used:
% 
% ```
% - amplitude_mean
% - amplitude_var
% ```

function [stim, Fs, X, binned_repr] = generate_stimulus(self)

    Fs = self.get_fs();
    nfft = self.get_nfft();

    % generate spectrum completely randomly
    % without bins
    % amplitudes are gaussian-distributed
    % with mean `self.amplitude_mean`
    % and standard deviation `self.amplitude_var`.
    X = self.amplitude_mean + sqrt(self.amplitude_var) * randn(nfft/2, 1);

    % sythesize audio
    stim = self.synthesize_audio(X, nfft);

    % empty output
    binned_repr = [];

end % function