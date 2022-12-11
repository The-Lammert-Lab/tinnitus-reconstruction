function ax = plot_violin(T, options)

    arguments
        T table
        options.figure = []
        options.data_dir = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper'
        options.N = 100
        options.parallel = true
    end

    if isempty(options.figure)
        options.figure = new_figure();
    end

    % Set current figure
    figure(options.figure);

    % % Colormap for plotting
    % cmap = options.colormap();

    % How many different target signals are there?
    subplot_labels = unique(T.target_signal_name);
    assert(~isempty(subplot_labels), 'couldn''t find any data to plot')
 
    % Generate one subplot for each unique target signal
    m = length(subplot_labels) + 1;
    n = 3;

    ax = figlib.tightSubplots(m, n, 'ShareX', false, 'ShareY', false);

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
            'N', options.N, ...
            'parallel', options.parallel);
        data_to_plot{3} = bootstrap_reconstruction_synth(...
            'config_file', pathlib.join(options.data_dir, config_filename), ...
            'method', 'linear', ...
            'strategy', 'rand', ...
            'N', options.N, ...
            'parallel', false);

        for qq = 1:n
            counter = counter + 1;
            % ax(ii, qq) = subplot(m, n, counter);
            axes(ax(sub2ind([m, n], qq, ii)));
            violinplot(data_to_plot{qq}, categories(qq), 'ViolinAlpha', 0.3, 'ShowBox', true);
            
            if qq == 1
                ylabel(ax(sub2ind([m, n], qq, ii)), 'Pearson''s r');
            end

            % title(ax(sub2ind([m, n], qq, ii)), subplot_labels{ii});
            
        end
        
        data_container{ii} = data_to_plot;
    end
    
    for qq = 1:n
        counter = counter + 1;
        % ax(m, qq) = subplot(m, n, counter);
        axes(ax(sub2ind([m, n], qq, m)));
        data_to_plot = [];
        for ii = 1:length(data_container)
            data_to_plot = [data_to_plot; data_container{ii}{qq}];
        end
        violinplot(data_to_plot, categories(qq), 'ViolinAlpha', 0.3, 'ShowBox', true);
        
        if qq == 1
            ylabel(ax(sub2ind([m, n], qq, m)), 'Pearson''s r');
        end

        % title(ax(sub2ind([m, n], qq, m)), 'combined');
    end

end % function
