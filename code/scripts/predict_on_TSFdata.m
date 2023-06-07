% Run just the cross validation section on data used to train ML model

data_path = '~/repos/TinnitusStimulusFitter.jl/data/smote_patient_data';
data_dir = dir(data_path);
data_dir = data_dir(3:end); % remove '.' and '..'
n = length(data_dir);
row_names = cellstr(strcat('Subject', {' '}, string((1:n))));

% Prediction settings
folds = 5;
knn = true;
mean_zero = true;
from_responses = false;
gs_ridge = true;
thresh_vals = linspace(10,90,200);
k_vals = 1:2:15;
verbose = false;

% Initialize
pred_acc_cs = zeros(n,1);
pred_acc_lr = zeros(n,1); 

pred_bal_acc_cs = zeros(n,1);
pred_bal_acc_lr = zeros(n,1);

pred_acc_on_train_cs = zeros(n,1);
pred_acc_on_train_lr = zeros(n,1); 

pred_bal_acc_on_train_cs = zeros(n,1);
pred_bal_acc_on_train_lr = zeros(n,1);

if knn
    pred_acc_knn = zeros(n,1);
    pred_bal_acc_knn = zeros(n,1);
    pred_acc_on_train_knn = zeros(n,1); 
    pred_bal_acc_on_train_knn = zeros(n,1);
end

for ii = 1:n
    % Get config
    responses = readmatrix(pathlib.join(data_path,data_dir(ii).name,'responses.csv'));
    stimuli_matrix = readmatrix(pathlib.join(data_path,data_dir(ii).name,'stimuli.csv'));

    % Generate cross-validated predictions
    [given_responses, training_responses, pred_on_test, pred_on_train] = crossval_predicted_responses(folds, ...
                                                                            'responses', responses, 'stimuli', stimuli_matrix', ...
                                                                            'knn', knn, 'from_responses', from_responses, ...
                                                                            'mean_zero', mean_zero, 'ridge_reg', gs_ridge, ...
                                                                            'threshold_values', thresh_vals, 'k_vals', k_vals, ...
                                                                            'verbose', verbose ...
                                                                        );

    % Assess prediction quality
    [pred_acc_cs(ii), pred_bal_acc_cs(ii), ~, ~] = get_accuracy_measures(given_responses, pred_on_test.cs);
    [pred_acc_lr(ii), pred_bal_acc_lr(ii), ~, ~] = get_accuracy_measures(given_responses, pred_on_test.lr);

    [pred_acc_on_train_cs(ii), pred_bal_acc_on_train_cs(ii), ~, ~] = get_accuracy_measures(training_responses, pred_on_train.cs);
    [pred_acc_on_train_lr(ii), pred_bal_acc_on_train_lr(ii), ~, ~] = get_accuracy_measures(training_responses, pred_on_train.lr);

    if knn
        [pred_acc_knn(ii), pred_bal_acc_knn(ii), ~, ~] = get_accuracy_measures(given_responses, pred_on_test.knn);
        [pred_acc_on_train_knn(ii), pred_bal_acc_on_train_knn(ii), ~, ~] = get_accuracy_measures(training_responses, pred_on_train.knn);
    end
end

% Print results
T_CV = table(pred_bal_acc_lr, pred_bal_acc_cs, pred_acc_lr, pred_acc_cs, ...
    'VariableNames', ["LR CV Pred Bal Acc", "CS CV Pred Bal Acc", "LR CV Pred Acc", "CS CV Pred Acc"], ...
    'RowNames', row_names)

T_CV_on_train = table(pred_bal_acc_on_train_lr, pred_bal_acc_on_train_cs, pred_acc_on_train_lr, pred_acc_on_train_cs, ...
    'VariableNames', ["LR CV Pred Bal Acc On Train", "CS CV Pred Bal Acc On Train", "LR CV Pred Acc On Train", "CS CV Pred Acc On Train"], ...
    'RowNames', row_names)

if knn
    T_CV_knn = table(pred_bal_acc_knn, pred_acc_knn, ...
        'VariableNames', ["KNN CV Pred Bal Acc", "KNN CV Pred Acc"], ...
        'RowNames', row_names)
    
    T_CV_on_train_knn = table(pred_bal_acc_on_train_knn, pred_acc_on_train_knn, ...
        'VariableNames', ["KNN CV Pred Bal Acc On Train", "KNN CV Pred Acc On Train"], ...
        'RowNames', row_names)
end
