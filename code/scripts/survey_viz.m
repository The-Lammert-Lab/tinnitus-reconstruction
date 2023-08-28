%%%
% This script collects and analyzes subjective rankings from
% compare_recons.m
%%%

%% Data setup
data_dir = '~/Desktop/Lammert_Lab/Tinnitus/resynth_test_data';
d = dir(pathlib.join(data_dir, 'survey_*.csv'));

%% Load
fname = d(1).name;
underscores = find(fname == '_');
user_id = fname(underscores(end)+1:end-4);
T = readtable(fullfile(d(1).folder, d(1).name));
T.user_id = {user_id};

for ii = 2:length(d)
    fname = d(ii).name;
    underscores = find(fname == '_');
    user_id = fname(underscores(end)+1:end-4);
    T2 = readtable(fullfile(d(ii).folder, d(ii).name));
    T2.user_id = {user_id};
    T = [T; T2];
end

% Add r-scores
T_rvals = readtable(fullfile(data_dir,'rvals.csv'));
T = outerjoin(T,T_rvals,'MergeKeys',true);

%% Plot setup
user_ids = unique(T.user_id);
unique_hashes = unique(T.hash);
lbl = {'white noise', 'standard', 'sharpened'};

%% Bar ratings
figure
tiledlayout('flow')
for ii = 1:length(unique_hashes)
    this_hash = unique_hashes(ii);
    ind = strcmp(T.hash,this_hash);
    y = [T.whitenoise(ind, :), ...
        T.recon_standard(ind, :), ...
        T.recon_adjusted(ind, :)]';

    nexttile
    bar(y)
    set(gca, 'XTickLabel', lbl, 'XTick', 1:length(lbl), 'YTick', 1:7)
    title(['hash: ', this_hash{:}, '. r: ', num2str(T.r_lr(ind,:))], 'FontSize', 16)
    grid on
    legend(user_ids)
end

%% Scatter params
figure
for ii = 1:length(user_ids)
    ind = strcmp(T.user_id,user_ids(ii));
    scatter(T.mult(ind,:), T.binrange(ind,:), 'filled');
    hold on
end
legend(user_ids)
xlabel('Mult param', 'FontSize', 16)
ylabel('Binrange param', 'FontSize', 16)
