%% Compute stats used in the main paper

T2 = T(T.n_bins == 8, :);
groupsummary(T2, "target_signal_name", ["mean", "std"], ["r_lr_bins_1", "r_synth", "r_rand"])

%% Stats for buzzing

T3 = T2(strcmp(T2.target_signal_name, 'buzzing'), :);
r_values = fisher_transform(T3.r_lr_bins_1);

[H, P, CI, stats] = ttest(r_values, [], 'tail', 'right');
disp('One-tailed t-test for buzzing on Fisher-transformed r-values:')
disp(['p = ', num2str(P)])
disp(stats)

%% Stats for roaring

T3 = T2(strcmp(T2.target_signal_name, 'roaring'), :);
r_values = fisher_transform(T3.r_lr_bins_1);

[H, P, CI, stats] = ttest(r_values, [], 'tail', 'right');
disp('One-tailed t-test for roaring on Fisher-transformed r-values:')
disp(['p = ', num2str(P)])
disp(stats)

%% Stats for combined

r_values = fisher_transform(T2.r_lr_bins_1);

[H, P, CI, stats] = ttest(r_values, [], 'tail', 'right');
disp('One-tailed t-test for combined on Fisher-transformed r-values:')
disp(['p = ', num2str(P)])
disp(stats)