% Generate tables with all the necessary information for paper 3

%%%%% IMPORTANT %%%%%
% Check that settings and data dir
% inside patient_reconstructions are correct first

%%% Should be:
% CS = true;
% showfigs = true;
% n_best_plot = 4 %%%%%%% Check here if not getting enough plots
% verbose = false;
% num_from_config = false;
% rc = true;
% rc_adjusted = true;
% knn = false;
% lda = false;
% lwlr = false;
% pnr = false;
% randguess = false;
% svm = false;
% thresh_loud = true;
% follow_up_ttest = true;

%% Analyze data
patient_reconstructions

%% Process results
% Join tables
T_preds = outerjoin(T_CV_rc,T_CV_rc_train,'Keys',{'subject ID'},'MergeKeys',true);
T_preds = outerjoin(T_preds,T_CV_thresh,'Keys',{'subject ID'},'MergeKeys',true);
T_preds = outerjoin(T_preds,T_CV_loud,'Keys',{'subject ID'},'MergeKeys',true);
T_preds = outerjoin(T_preds,T_yesses,'Keys',{'subject ID'},'MergeKeys',true);
T_preds = movevars(T_preds,'subject ID','After',size(T_preds,2));

T_tl_corrs = outerjoin(T_dB_loud_corrs, T_dB_thresh_corrs, 'Keys', {'subject ID'}, 'MergeKeys', true);
T_tl_corrs = movevars(T_tl_corrs,'subject ID','After',size(T_tl_corrs,2));

% Create prediction ttest table
T_preds_ttest = [table([mean(pred_bal_acc_rc); mean(pred_bal_acc_tl_loud); mean(pred_bal_acc_tl_thresh)], ...
    [CV_rc_bal_acc_p; CV_loud_bal_acc_p; CV_thresh_bal_acc_p], ...
    'VariableNames', ["Mean", "P Value"], 'RowNames', {'RC', 'Loud', 'Thresh'}), ...
    [struct2table(CV_rc_bal_acc_tstats); 
    struct2table(CV_loud_bal_acc_tstats);
    struct2table(CV_thresh_bal_acc_tstats)]];

T_follow_up_stats = table([mean(standard_rating); mean(adjusted_rating); mean(whitenoise_rating)], ...
    [std(standard_rating); std(adjusted_rating); std(whitenoise_rating)], ...
    'VariableNames',["Mean", "SD"], 'RowNames',{'Standard', 'Adjusted', 'White'});

% Prune tables
preds_rmcols = contains(T_preds.Properties.VariableNames, {'Pred Acc'}); % Only care about BA
T_preds = removevars(T_preds, preds_rmcols);

corrs_rmcols = contains(T_tl_corrs.Properties.VariableNames, {'CS'}); % Not reporting CS in paper
T_tl_corrs = removevars(T_tl_corrs, corrs_rmcols);

tl_round_cols = ~contains(T_tl_corrs.Properties.VariableNames, {'p val'}); % Don't round p val cols b/c goes to 0
tl_round_cols(end) = false; % Last is subject ID, which causes round to error

T_follow_up_ttest = removevars(T_follow_up_ttest, 'sd'); % Remove sd b/c it's paired. Want to report individual SDs

% Round values
T_preds(:,1:end-1) = array2table(round(T_preds{:,1:end-1},4));
T_tl_corrs(:,tl_round_cols) = array2table(round(T_tl_corrs{:,tl_round_cols},4));

%% Put tables into figs
table2fig(T_tl_corrs, 'Threshold/Loudness Correlations')
table2fig(T_preds, 'Response Prediction')
table2fig(T_preds_ttest, 'Response Prediction T-tests')
table2fig(T_ratings, 'Follow Up Ratings')
table2fig(T_follow_up_ttest, 'Follow Up T-test')
table2fig(T_follow_up_stats, 'Follow Up Stats')

%% Helper func
function table2fig(T, name)
    arguments
        T table
        name char = ''
    end
    uitable(uifigure('Name',name),'Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
        'RowName',T.Properties.RowNames,'Units','Normalized','Position',[0,0,1,1]);
end
