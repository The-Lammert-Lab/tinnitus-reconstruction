function plot_violin(T, options)

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

    for ii = 1:length(subplot_labels)
        filtered_table = T(strcmp(T.target_signal_name), subplot_labels{ii});

        ydata = [filtered_table.r_lr_bins_1; ...
                filtered_table.r_cs_bins_1; ...
                r_rand_lr; ...
                r_rand_cs; ...
                r_synth_lr; ...
                r_synth_cs];
        
        xdata = [repmat({'Subj. LR'}, length(filtered_table.r_lr_bins_1), 1); ...
                repmat({'Subj. CS'}, length(filtered_table.r_cs_bins_1), 1); ...
                repmat({'Rand LR'}, length(r_rand_lr), 1), ...
                repmat({'Rand CS'}, length(r_rand_cs), 1), ...
                repmat({'Synth LR'}, length(r_synth_lr), 1), ...
                repmat({'Synth CS'}, length(r_synth_cs), 1)];

        violinplot(ax(ii), ydata, xdata);
        
    end