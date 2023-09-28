function [stim, Fs, X, binned_repr] = generate_stimulus(self)
    Fs = self.get_fs();
    nfft = self.get_nfft();

    X = self.unfilled_dB*ones(nfft/2, 1);
    X(randi(length(X))) = 0;
    stim = self.synthesize_audio(X, nfft);

    binned_repr = [];
end
