% Model of a subject performing the task.
% Takes in a signal (the stimuli)
% and returns an n_samples x 1 vector of 
% -1 for "no"
% and 1 for "yes".

function [y, X] = subject_selection_process(signal, stimuli, n_samples)

    if isempty(stimuli)
        X = round(rand(n_samples, length(signal)));
    else
        X = stimuli;
    end



    % ideal selection
    e = X * signal(:);
    y = double(e >= prctile(e, 50));
    y(y == 0) = -1;
end