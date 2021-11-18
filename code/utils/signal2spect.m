function s = signal2spect(x)
    % Return the spectrum of a signal
    % in dB.

    s = 10 * log10(abs(fft(x)));

    if isvector(s)
        s = s(1:floor(end/2));
    else
        s = s(1:floor(end/2), :);
    end