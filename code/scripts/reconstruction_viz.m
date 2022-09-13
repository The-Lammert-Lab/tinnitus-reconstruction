
%% Visualization for reconstructions
% Run ``pilot_reconstructions.m`` first.

%% Plotting the bin-representation of the target signal vs. the reconstructions

alpha = 0.25;

% Regular experiments (no 2-AFC or resynth)

fig1 = new_figure();

% Subset the data table
T2 = T(~(contains(T.experiment_name, 'resynth') | contains(T.experiment_name, '2afc')), :);

fig1 = plot_reconstructions(fig1, T2, binned_target_signal, data_names, PUBLISH, alpha);

% Resynth experiments (no 2-AFC or regular)

fig2 = new_figure();

% Subset the data table
T2 = T(contains(T.experiment_name, 'resynth'), :);

% Get binned resynth target signal
% They are the reconstructions from the original signal
experiment_names = cellfun(@(x) strrep(x, '-resynth', ''), T2.experiment_name, 'UniformOutput', false);
T_filtered = T(contains(T.experiment_name, experiment_names), :);
binned_resynth_target_signal = [T_filtered.reconstructions_cs_1{:}];

fig2 = plot_reconstructions(fig2, T2, binned_resynth_target_signal, data_names, PUBLISH, alpha);

return

% 2-AFC experiments

fig2 = new_figure();
T2 = T(contains(T.experiment_name, '2afc'), :);

fig2 = plot_reconstructions(fig2, T2, binned_target_signal, data_names, PUBLISH, alpha);

return



return

% % Plotting the r^2 values vs. the trial numbers (using trial fractions)

% fig2 = new_figure();

% cmap = colormaps.linspecer(length(unique(T.subject_ID)));
% alpha = 1;

% subplot_labels = unique(T.target_signal_name)';

% for ii = length(subplot_labels):-1:1
%     ax(ii) = subplot(2, 1, ii, 'Parent', fig2);
%     hold on
% end

% for ii = 1:length(subplot_labels)
%     ylabel(ax(ii), 'r^2')

%     p = plot(ax(ii), 2e3 * [0, trial_fractions], [NaN, r2_synth(1, :)], '-xk', 'MarkerSize', 10);
%     p.Color(4) = alpha;

%     % Reconstructions from subjects
%     T2 = T(strcmp(T.target_signal_name, subplot_labels{ii}), :);
%     legend_labels = cell(2 * height(T2), 1);
%     for qq = 1:height(T2)
%         if PUBLISH
%             this_subject_ID = ['subject #', num2str(qq)];
%         else
%             this_subject_ID = T2.subject_ID{qq};
%         end

%         p = plot(ax(ii), 2e3 * [0, trial_fractions], [NaN, r2_cs_bins(qq, :)], '-x', 'MarkerSize', 10, 'Color', cmap(qq, :), 'MarkerFaceColor', cmap(qq, :), 'MarkerEdgeColor', cmap(qq, :));
%         legend_labels{2 * qq - 1} = [this_subject_ID, ' CS'];
%         p.Color(4) = alpha;
%         p = plot(ax(ii), 2e3 * [0, trial_fractions], [NaN, r2_lr_bins(qq, :)], '-o', 'MarkerSize', 10, 'Color', cmap(qq, :), 'MarkerFaceColor', cmap(qq, :), 'MarkerEdgeColor', cmap(qq, :));
%         legend_labels{2 * qq} = [this_subject_ID, ' LR'];
%         p.Color(4) = alpha;
%     end

%     xlabel(ax(end), 'number of trials')

%     % legend(ax(ii), [{'g.t.'}; legend_labels; {'baseline'}; {'synthetic'}], 'Location', 'eastoutside')
%     legend(ax(ii), [{'synthetic'}; legend_labels], 'Location', 'eastoutside')
% end

% if PUBLISH
%     figlib.pretty('PlotLineWidth', 3, 'EqualiseX', true, 'EqualiseY', true, 'FontSize', 36, 'PlotBuffer', 0.02)
%     figlib.tight();
%     figlib.label('XOffset', 0, 'YOffset', 0, 'FontSize', 36);
% else
%     figlib.pretty()
% end

function fig = plot_reconstructions(fig, T2, binned_target_signal, data_names, PUBLISH, alpha)

    % Colormap for plotting
    % cmap = colormaps.linspecer(2 * height(T2) + 2);
    cmap = parula(2 * height(T2) + 2);

    subplot_labels = unique(T2.target_signal_name)';

    for ii = length(subplot_labels):-1:1
        ax(ii) = subplot(2, 1, ii, 'Parent', fig);
        hold on
    end

    title(ax(1), 'Vanilla')

    for ii = 1:length(subplot_labels)

        ylabel(ax(ii), 'norm. bin ampl. (a.u.)')

        % Target signal (ground truth)
        p = plot(ax(ii), normalize(binned_target_signal(:, strcmp(data_names, subplot_labels{ii}))), '-ok');
        % p.Color(4) = alpha;

        % Reconstructions from subjects
        T3 = T2(strcmp(T2.target_signal_name, subplot_labels{ii}), :);


        legend_labels = cell(2 * height(T3), 1);
        for qq = 1:height(T3)
            if PUBLISH
                this_subject_ID = ['subject #', num2str(qq)];
            else
                this_subject_ID = T3.subject_ID{qq};
            end

            p = plot(ax(ii), normalize(T3.reconstructions_cs_1{qq}), '-o', 'Color', cmap(qq, :));
            legend_labels{2 * qq - 1} = [this_subject_ID, ' CS'];
            p.Color(4) = alpha;
            p = plot(ax(ii), normalize(T3.reconstructions_lr_1{qq}), '-o', 'Color', cmap(2 * qq, :));
            legend_labels{2 * qq} = [this_subject_ID, ' LR'];
            p.Color(4) = alpha;
        end

        % Random (baseline) reconstruction (using linear regression)
        % p = plot(ax(ii), normalize(T3.reconstructions_rand{1}), '-o', 'Color', cmap(2 * qq + 1, :));
        % p.Color(4) = alpha;

        % Synthetic reconstruction (using compressed sensing)
        p = plot(ax(ii), normalize(T3.reconstructions_synth{1}), '-o', 'Color', cmap(2 * qq + 2, :));
        p.Color(4) = alpha;

        % legend(ax(ii), [{'g.t.'}; legend_labels; {'baseline'}; {'synthetic'}], 'Location', 'eastoutside')
        legend(ax(ii), [{'g.t.'}; legend_labels; {'synthetic'}], 'Location', 'eastoutside')
            
        if ~PUBLISH
            title(ax(ii), ['bin reconstructions, ', subplot_labels{ii}])
        end
    end

    xlabel(ax(2), 'bins')

    if PUBLISH
        figlib.pretty('PlotLineWidth', 3, 'EqualiseX', true, 'EqualiseY', true, 'FontSize', 36, 'PlotBuffer', 0.1)
        figlib.tight();
        figlib.label('XOffset', 0, 'YOffset', 0, 'FontSize', 36);
        for ii = 1:length(ax)
            axlib.separate(ax(ii), 'MaskX', true, 'MaskY', true, 'Offset', 0.02);
        end
    else
        figlib.pretty()
    end
end % function

function fig = plot_reconstructions_resynth(fig, T2, binned_target_signal, PUBLISH, alpha)

    % Colormap for plotting
    % cmap = colormaps.linspecer(2 * height(T2) + 2);
    cmap = parula(2 * height(T2) + 2);

    subplot_labels = unique(T2.target_signal_name)';

    for ii = length(subplot_labels):-1:1
        ax(ii) = subplot(2, 1, ii, 'Parent', fig);
        hold on
    end

    title(ax(1), 'Vanilla')

    for ii = 1:length(subplot_labels)

        ylabel(ax(ii), 'norm. bin ampl. (a.u.)')

        % Target signal (ground truth)
        p = plot(ax(ii), normalize(binned_target_signal(:, strcmp(data_names, subplot_labels{ii}))), '-ok');
        % p.Color(4) = alpha;

        % Reconstructions from subjects
        T3 = T2(strcmp(T2.target_signal_name, subplot_labels{ii}), :);


        legend_labels = cell(2 * height(T3), 1);
        for qq = 1:height(T3)
            if PUBLISH
                this_subject_ID = ['subject #', num2str(qq)];
            else
                this_subject_ID = T3.subject_ID{qq};
            end

            p = plot(ax(ii), normalize(T3.reconstructions_cs_1{qq}), '-o', 'Color', cmap(qq, :));
            legend_labels{2 * qq - 1} = [this_subject_ID, ' CS'];
            p.Color(4) = alpha;
            p = plot(ax(ii), normalize(T3.reconstructions_lr_1{qq}), '-o', 'Color', cmap(2 * qq, :));
            legend_labels{2 * qq} = [this_subject_ID, ' LR'];
            p.Color(4) = alpha;
        end

        % Random (baseline) reconstruction (using linear regression)
        % p = plot(ax(ii), normalize(T3.reconstructions_rand{1}), '-o', 'Color', cmap(2 * qq + 1, :));
        % p.Color(4) = alpha;

        % Synthetic reconstruction (using compressed sensing)
        p = plot(ax(ii), normalize(T3.reconstructions_synth{1}), '-o', 'Color', cmap(2 * qq + 2, :));
        p.Color(4) = alpha;

        % legend(ax(ii), [{'g.t.'}; legend_labels; {'baseline'}; {'synthetic'}], 'Location', 'eastoutside')
        legend(ax(ii), [{'g.t.'}; legend_labels; {'synthetic'}], 'Location', 'eastoutside')
            
        if ~PUBLISH
            title(ax(ii), ['bin reconstructions, ', subplot_labels{ii}])
        end
    end

    xlabel(ax(2), 'bins')

    if PUBLISH
        figlib.pretty('PlotLineWidth', 3, 'EqualiseX', true, 'EqualiseY', true, 'FontSize', 36, 'PlotBuffer', 0.1)
        figlib.tight();
        figlib.label('XOffset', 0, 'YOffset', 0, 'FontSize', 36);
        for ii = 1:length(ax)
            axlib.separate(ax(ii), 'MaskX', true, 'MaskY', true, 'Offset', 0.02);
        end
    else
        figlib.pretty()
    end
end % function
