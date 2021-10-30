function [stim] = synthesize_audio(X, nfft)

    % Synthesize audio from spectrum, X

    arguments
        X {mustBeNumeric}
        nfft {mustBeNumeric}
    end

    % Synthesize Audio
    phase = 2*pi*(rand(nfft/2,1)-0.5); % assign random phase to freq spec
    s = (10.^(X./10)).*exp(1i*phase); % convert dB to amplitudes
    ss = [1; s; conj(flipud(s))];
    stim = ifft(ss); % transform from freq to time domain

end % function