function [stim, Fs, X, binned_repr] = generate_stimulus(self)
    % Generate stimuli using a binless white-noise process.
    % 
    % Class Properties Used:
    %   n_bins

    [~, Fs, nfft] = self.get_freq_bins();

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