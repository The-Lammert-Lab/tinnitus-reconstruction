
function fig = plot_reconstructions(options)
    % TODO: documentation

    arguments
        options.table
        options.binned_target_signal
        options.data_names
        options.figure = []
        options.publish = false
        options.alpha = 0.5
        options.resynth = false
        options.two_afc = false
        options.colormap = @colormaps.linspecer
        options.cs = true
        options.lr = false
        options.baseline = false
        options.synthetic = false
    end

    if isempty(options.figure)
        options.figure = new_figure();
    end

    if options.resynth || options.two_afc
        error("Not implemented")
    end

    % Set the current figure
    figure(options.figure);

    % Colormap for plotting
    cmap = options.colormap(height(options.table) + 2);

    % How many different target signals are there?
    subplot_labels = unique(options.table.target_signal_name)';
    assert(~isempty(subplot_labels), 'couldn''t find any data to plot')

    % Generate one subplot for each unique target signal
    for ii = length(subplot_labels):-1:1
        ax(ii) = subplot(2, 1, ii, 'Parent', options.figure);
        hold on
    end

    % Plot on each subplot
    for ii = 1:length(subplot_labels)

        ylabel(ax(ii), 'norm. bin ampl. (a.u.)')
        legend_labels = {};

        % Target signal (ground truth)
        plot(ax(ii), normalize(options.binned_target_signal(:, strcmp(data_names, subplot_labels{ii}))), '-ok');
        legend_labels{end + 1} = 'ground truth';

        % Reconstructions from subjects
        filtered_table = options.table(strcmp(options.table.target_signal_name, subplot_labels{ii}), :);

        % For each row in the data table, plot the reconstructions
        for qq = 1:height(filtered_table)
            % Get the subject ID for the legend
            if options.publish
                this_subject_ID = ['subject #', num2str(qq)];
            else
                this_subject_ID = filtered_table.subject_ID{qq};
            end

            % Plot the lines and markers separately because MATLAB doesn't let you change the opacity
            % of markers created by the plot function for some unknown reason.
            % There's a workaround involving MarkerHandle objects, but that's not working for some reason.

            if options.cs
                % Line plot, CS
                p = plot(ax(ii), normalize(filtered_table.reconstructions_cs_1{qq}), '-', 'Color', cmap(qq, :));
                p.Color(4) = alpha; % set the alpha separately
                legend_labels{end + 1} = '';

                % Scatter plot, CS
                scatter(ax(ii), 1:100, normalize(filtered_table.reconstructions_cs_1{qq}), 'MarkerEdgeColor', cmap(qq, :), 'MarkerEdgeAlpha', alpha)
                legend_labels{end + 1} = '';

                % Empty plot purely for the legend
                plot(ax(ii), NaN, NaN, '-o', 'Color', cmap(qq, :))
                legend_labels{end + 1} = [this_subject_ID, ' CS'];
            end

            if options.lr
                % Line plot, LR
                p = plot(ax(ii), normalize(filtered_table.reconstructions_lr_1{qq}), '--', 'Color', cmap(qq, :), 'MarkerEdgeColor', cmap(qq, :));
                p.Color(4) = alpha;
                legend_labels{end + 1} = '';

                % Scatter plot, LR
                scatter(ax(ii), 1:100, normalize(filtered_table.reconstructions_cs_1{qq}), '+', 'MarkerEdgeColor', cmap(qq, :), 'MarkerEdgeAlpha', alpha)
                legend_labels{end + 1} = '';

                % Empty plot for the legend
                plot(ax(ii), NaN, NaN, '--+', 'Color', cmap(qq, :))
                legend_labels{end + 1} = [this_subject_ID, ' LR'];
            end
        end

        if options.baseline
            % Random (baseline) reconstruction (using linear regression)

            % Line plot, CS
            p = plot(ax(ii), normalize(filtered_table.reconstructions_rand{1}), '-', 'Color', cmap(2 * qq + 1, :));
            p.Color(4) = alpha;

            % Scatter plot, CS
            scatter(ax(ii), 1:100, normalize(filtered_table.reconstructions_rand{1}), 'o', 'MarkerEdgeColor', cmap(qq + 1, :), 'MarkerEdgeAlpha', alpha)

            % Empty
            plot(ax(ii), NaN, NaN, '-o', 'Color', cmap(qq + 1, :))
            legend_labels{end + 1} = 'baseline';
        end

        if options.synthetic
            % Line plot, synthetic reconstruction, CS
            p = plot(ax(ii), normalize(filtered_table.reconstructions_synth{1}), '-', 'Color', cmap(qq + 2, :), 'MarkerEdgeColor', cmap(qq + 2, :));
            p.Color(4) = alpha;
            legend_labels{end + 1} = '';

            % Scatter plot, synthetic, CS
            scatter(ax(ii), 1:100, normalize(filtered_table.reconstructions_synth{1}), 'o', 'MarkerEdgeColor', cmap(qq + 2, :), 'MarkerEdgeAlpha', alpha);
            legend_labels{end + 1} = '';

            % Empty
            plot(ax(ii), NaN, NaN, '-o', 'Color', cmap(qq + 2, :))
            legend_labels{end + 1} = 'synthetic';
        end

        % Create the legend
        legend(ax(ii), legend_labels, 'Location', 'eastoutside')
            
        if ~options.publish
            title(ax(ii), ['bin reconstructions, ', subplot_labels{ii}])
        end
    end

    % Add an x-axis label
    xlabel(ax(end), 'bins')

    % Postprocessing
    if options.publish
        figlib.pretty('PlotLineWidth', 3, 'EqualiseX', true, 'EqualiseY', true, 'FontSize', 36, 'PlotBuffer', 0.1)
        figlib.tight();
        figlib.label('XOffset', 0, 'YOffset', 0, 'FontSize', 36);
        for ii = 1:length(ax)
            axlib.separate(ax(ii), 'MaskX', true, 'MaskY', true, 'Offset', 0.02);
        end
    else
        figlib.pretty()
    end

    % Output
    fig = output.figure;
end % function