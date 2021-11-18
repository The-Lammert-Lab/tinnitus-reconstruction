function [stim, Fs, X, binned_repr] = white_no_bins_generate_stimuli(self)
    % Generate stimuli using a binless white-noise process.

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