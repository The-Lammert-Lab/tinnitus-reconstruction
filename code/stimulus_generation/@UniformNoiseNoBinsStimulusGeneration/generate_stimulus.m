% ### generate_stimulus
% 
% Generate stimuli using a binless white-noise process.
% 
% **Class Properties Used:**
% ```
% - n_bins
% ```

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