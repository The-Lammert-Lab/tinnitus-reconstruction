function x = gs(responses, Phi, options)
    arguments
        responses (:,1) {mustBeNumeric}
        Phi (:,:) {mustBeNumeric}
        options.ridge (1,1) logical = false
        options.mean_zero (1,1) logical = false
    end

    if options.mean_zero
        Phi = Phi - mean(Phi,2);
    end

    if options.ridge
        x = (Phi'*Phi + 0.1*eye(size(Phi,2),size(Phi,2)))\(Phi'*responses);
    else
        len_signal = size(Phi, 2);
        x = (1 / len_signal) * Phi' * responses;
        %     x = (Phi'*Phi)\(Phi'*responses);
    end
end