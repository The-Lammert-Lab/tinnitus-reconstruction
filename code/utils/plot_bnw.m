function plot_bnw(T, options)

    arguments
        T table
        options.figure = []
        options.cs = true
        options.lr = false
        options.colormap = @colormaps.linspecer
        options.baseline = false
        options.synthetic = false
        options.publish = false
    end

    if isempty(options.figure)
        options.figure = new_figure();
    end

    % Set current figure
    figure(options.figure);

    % Colormap for plotting
    cmap = options.colormap();

    % How many different target signals are there?
    subplot_labels = unique(T.target_signal_name);
    assert(~isempty(subplot_labels), 'couldn''t find any data to plot')
 
    % Generate one subplot for each unique target signal
    for ii = length(subplot_labels):-1:1
        ax(ii) = subplot(length(subplot_labels), 1, ii, 'Parent', options.figure);
        hold on
    end

    % Plot on each subplot
    for ii = 1:length(subplot_labels)
        filtered_table = T(strcmp(T.target_signal_name, subplot_labels{ii}), :);

        h = height(filtered_table);
        ydata = [filtered_table.r_lr_bins_1; filtered_table.r_cs_bins_1];
        xdata = categorical([repmat({'LR'}, h, 1); repmat({'CS'}, h, 1)]);

        if options.lr && options.cs
            boxchart(ax(ii), xdata, ydata);
            % scatter(categorical({'LR', 'CS'}))
        elseif options.lr
            boxchart(ax(ii), xdata(xdata == 'LR'), ydata);
        elseif options.cs
            boxchart(ax(ii), xdata(xdata == 'CS'), ydata);
        else
            error("No reconstruction method set to 'true'")
        end

        xlabel(ax(ii), 'reconstruction method')
        ylabel(ax(ii), 'correlation')
        title(ax(ii), ['target signal: ', subplot_labels{ii}]);


    end

end % function