function x = gs(responses, Phi)
    len_signal = size(Phi, 2);
    x = (1 / len_signal) * Phi' * responses;
end