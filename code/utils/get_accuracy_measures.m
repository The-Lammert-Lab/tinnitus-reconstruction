% ### get_accuracy_measures
% 
% Computes standard accuracy measures between true and predicted labels.
% Values greater than or equal to 1 are considered positives,
% and values less than 1 are considered negative.
% 
% **ARGUMENTS:**
% 
%   - y: `m x p` numerical matrix,
%       representing true labels.
%   - y_hat: `m x n` numerical matrix,
%       representing predicted labels.
% 
% **OUTPUTS:**
% 
%   - accuracy: `scalar` or `1 x max(n,p)` vector,
%       the correct prediction rate. 
%   - balanced_accuracy: `scalar` or `1 x max(n,p)` vector,
%       the average of `sensitivity` and `specificity`.
%   - sensitivity: `scalar` or `1 x max(n,p)` vector,
%       the true positive rate.
%   - specificity: `scalar` or `1 x max(n,p)` vector,
%       the true negative rate.

function [accuracy, balanced_accuracy, sensitivity, specificity] = get_accuracy_measures(y,y_hat)
    TP = sum((y>=1)&(y_hat>=1));
    FP = sum((y<1)&(y_hat>=1));
    FN = sum((y>=1)&(y_hat<1));
    TN = sum((y<1)&(y_hat<1));

    specificity = TN./(TN+FP);
    sensitivity = TP./(TP+FN);
    balanced_accuracy = (sensitivity + specificity) ./ 2;
    accuracy = (TP + TN) ./ (TP + TN + FP + FN);
end
