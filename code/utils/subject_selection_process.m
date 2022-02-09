function [y, X] = subject_selection_process(target_signal, stimuli, n_samples)
    % Returns a response vector and the stimuli
    % where the response vector is made of up -1 and 1 values
    % corresponding to yes and no statements
    % about how well the stimuli correspond to the target signal.
    % 
    % Arguments:
    % 
    %   target_signal: numerical vector
    %       The signal to compare against (e.g., the tinnitus signal).
    % 
    %   stimuli: numerical matrix
    %       An m x n matrix where m is the number of samples/trials
    %       and n is the same length as the target signal.
    %       If stimuli is empty, a random Bernoulli matrix (p = 0.5) is used.
    %   
    %   n_samples: integer scalar
    %       How many samples are used when generating the Bernoulli matrix default
    %       for stimuli, if the stimuli argument is empty.
    % 
    % Returns:
    % 
    %   y: numerical vector
    %       Vector of -1 and 1 corresponding to negative and positive responses.
    % 
    %   X: numerical matrix
    %       The stimuli.
    % 
    % Examples:
    % 
    %   y = subject_selection_process(target_signal, stimuli)
    % 
    %   [y, X] = subject_selection_process(target_signal, [], n_samples)
    % 
    % See Also: Stimuli/subject_selection_process
    % 
    if isempty(stimuli)
        X = round(rand(n_samples, length(target_signal)));
    else
        X = stimuli;
    end

    % ideal selection
    e = X * target_signal(:);
    y = double(e >= prctile(e, 50));
    y(y == 0) = -1;
end