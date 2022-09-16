function fig = plot_reconstructions_resynth(fig, T2, binned_target_signal, PUBLISH, alpha)

    % Colormap for plotting
    cmap = colormaps.linspecer(height(T2) + 2);

    subplot_labels = unique(T2.target_signal_name)';

    assert(~isempty(subplot_labels), 'couldn''t find any data to plot')

    for ii = length(subplot_labels):-1:1
        ax(ii) = subplot(2, 1, ii, 'Parent', fig);
        hold on
    end

    title(ax(1), 'Vanilla')

    for ii = 1:length(subplot_labels)
        ylabel(ax(ii), 'norm. bin ampl. (a.u.)')

        % Reconstructions from subjects
        T3 = T2(strcmp(T2.target_signal_name, subplot_labels{ii}), :);

        legend_labels = cell(2 * height(T3), 1);
        for qq = 1:height(T3)
            if PUBLISH
                this_subject_ID = ['subject #', num2str(qq)];
            else
                this_subject_ID = T3.subject_ID{qq};
            end

            p = plot(ax(ii), normalize(T3.reconstructions_cs_1{qq}), '-', 'Color', cmap(qq, :), 'MarkerEdgeColor', cmap(qq, :));
            p.Color(4) = alpha;
            scatter(ax(ii), 1:100, normalize(T3.reconstructions_cs_1{qq}), 'o', 'MarkerEdgeColor', cmap(qq, :), 'MarkerEdgeAlpha', alpha);
            legend_labels{2 * qq - 1} = [this_subject_ID, ' CS'];
            
            p = plot(ax(ii), normalize(T3.reconstructions_lr_1{qq}), '--', 'Color', cmap(qq, :), 'MarkerEdgeColor', cmap(qq, :));
            p.Color(4) = alpha;
            scatter(ax(ii), 1:100, normalize(T3.reconstructions_lr_1{qq}), '+', 'MarkerEdgeColor', cmap(qq, :), 'MarkerEdgeAlpha', alpha);
            legend_labels{2 * qq} = [this_subject_ID, ' LR'];
            
        end
        
        % Random (baseline) reconstruction (using linear regression)
        % p = plot(ax(ii), normalize(T3.reconstructions_rand{1}), '-o', 'Color', cmap(2 * qq + 1, :));
        % p.Color(4) = alpha;

        % Synthetic reconstruction (using compressed sensing)
        p = plot(ax(ii), normalize(T3.reconstructions_synth{1}), '-', 'Color', cmap(qq + 2, :), 'MarkerEdgeColor', cmap(qq, :));
        p.Color(4) = alpha;
        scatter(ax(ii), 1:100, normalize(T3.reconstructions_synth{1}), 'o', 'MarkerEdgeColor', cmap(qq + 2, :), 'MarkerEdgeAlpha', alpha);

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