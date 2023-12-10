function [stim, Fs, X, binned_repr, w] = generate_stimulus(self)
    B = self.get_basis();
    Fs = self.get_fs();
    
    % Multiply by random weights
    w = rand(size(B,2),1);
    X = self.scale_fact*rescale(B*w);

    % Synthesize audio
    stim = self.synthesize_audio(X,self.nfft);

    binned_repr = [];
end
