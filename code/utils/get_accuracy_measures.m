function [accuracy, balanced_accuracy, sensitivity, specificity] = get_accuracy_measures(y,y_hat)
    TP = sum((y==1)&(y_hat==1));
    FP = sum((y==-1)&(y_hat==1));
    FN = sum((y==1)&(y_hat==-1));
    TN = sum((y==-1)&(y_hat==-1));

    specificity = TN/(TN+FP);
    sensitivity = TP/(TP+FN);
    accuracy = (TP + TN) / (TP + TN + FP + FN);
    balanced_accuracy = (sensitivity + specificity) / 2;
end
