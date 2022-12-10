function plot_violin(T, options)

    arguments
        T table
        options.figure = []
        options.cs = false
        options.lr = true
        options.colormap = @colormaps.linspecer
        options.baseline = false
        options.synthetic = false
        options.publish = false
        options.data_dir = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper'
    end

    if isempty(options.figure)
        options.figure = new_figure();
    end

    if options.cs
        error('not currently supported')
    end

    % Set current figure
    figure(options.figure);

    % Colormap for plotting
    cmap = options.colormap();

    % How many different target signals are there?
    subplot_labels = unique(T.target_signal_name);
    assert(~isempty(subplot_labels), 'couldn''t find any data to plot')
 
    % Generate one subplot for each unique target signal
    m = length(subplot_labels) + 1;
    n = 3;

    % Plot the 1 to m-1 subplots
    categories = {'subject', 'synthetic', 'random'};
    counter = 0;
    data_container = cell(length(subplot_labels), 1);
    for ii = 1:(m-1)
        % Get the config filepath
        subset = T(strcmp(T.target_signal_name, subplot_labels{ii}) & contains(T.config_filename, 'AH'), :);
        config_filename = char(subset(1, :).config_filename);
        % Get the data to plot
        data_to_plot = cell(3, 1);
        data_to_plot{1} = table2array(T(strcmp(T.target_signal_name, subplot_labels{ii}), "r_lr_bins_1"));
        data_to_plot{2} = bootstrap_reconstruction_synth(...
            'config_file', pathlib.join(options.data_dir, config_filename), ...
            'method', 'linear', ...
            'strategy', 'synth', ...
            'N', 100);
        data_to_plot{3} = bootstrap_reconstruction_synth(...
            'config_file', pathlib.join(options.data_dir, config_filename), ...
            'method', 'linear', ...
            'strategy', 'rand', ...
            'N', 100);

        for qq = 1:n
            counter = counter + 1;
            ax(ii, qq) = subplot(m, n, counter);
            violinplot(data_to_plot{qq}, categories(qq), 'ViolinAlpha', 0.3, 'ShowBox', true);
            
            if qq == 1
                ylabel(ax(ii, qq), 'Pearson''s r');
            end

            title(ax(ii, qq), subplot_labels{ii});
            
        end
        
        data_container{ii} = data_to_plot;
    end
    
    for qq = 1:n
        counter = counter + 1;
        ax(m, qq) = subplot(m, n, counter);
        data_to_plot = [];
        for ii = 1:length(data_container)
            data_to_plot = [data_to_plot; data_container{ii}{qq}];
        end
        violinplot(data_to_plot, categories(qq), 'ViolinAlpha', 0.3, 'ShowBox', true);
        
        if qq == 1
            ylabel(ax(m, qq), 'Pearson''s r');
        end

        title(ax(m, qq), 'combined');
    end
    figlib.pretty('FontSize', 18, 'PlotBuffer', 0.2);
    axlib.equalize(ax(:), 'x', 'y');
    figlib.label();


end % function
