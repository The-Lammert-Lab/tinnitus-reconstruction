% ### get_accuracy_measures
% 
% Computes standard accuracy measures between true and predicted labels
% 
% **ARGUMENTS:**
% 
%   - y: `m x n` numerical matrix,
%       representing true labels. Values must be either `1` or `-1`.
% 
%   - y_hat: `m x n` numerical matrix,
%       representing predicted labels. Values must be either `1` or `-1`.
% 
% **OUTPUTS:**
% 
%   - accuracy: `scalar`,
%       the correct prediction rate.
% 
%   - balanced_accuracy: `scalar`,
%       the average of `sensitivity` and `specificity`.
% 
%   - sensitivity: `scalar`,
%       the true positive rate.
% 
%   - specificity: `scalar`,
%       the true negative rate.

function [accuracy, balanced_accuracy, sensitivity, specificity] = get_accuracy_measures(y,y_hat)
    TP = sum((y==1)&(y_hat==1));
    FP = sum((y==-1)&(y_hat==1));
    FN = sum((y==1)&(y_hat==-1));
    TN = sum((y==-1)&(y_hat==-1));

    specificity = TN/(TN+FP);
    sensitivity = TP/(TP+FN);
    balanced_accuracy = (sensitivity + specificity) / 2;
    accuracy = (TP + TN) / (TP + TN + FP + FN);
end
