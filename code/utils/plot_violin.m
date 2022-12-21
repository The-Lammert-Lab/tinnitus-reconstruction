function [ax, data_container] = plot_violin(T, options)

    arguments
        T table
        options.figure = []
        options.data_dir = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper'
        options.N = 100
        options.parallel = true
        options.data_container = {}
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
    
    % Whether to rerun the synthetic experiments or not
    if isempty(options.data_container)
        generate_results = true;
        data_container = cell(length(subplot_labels), 1);
    else
        generate_results = false;
        data_container = options.data_container;
    end

    % Generate one subplot for each unique target signal
    m = length(subplot_labels) + 1;
    n = 3;

    for ii = (m*n):-1:1
        % ax(ii) = subplot(m, n, ii);
        ax(ii) = subaxis.subaxis(m, n, ii, 'Spacing', 0.00, 'Padding', 0.00, 'Margin', 0.1);
        axis tight
        [qq, ~] = ind2sub([m, n], ii);
        if qq ~= 1
            ax(ii).YAxis.Visible = 'off';
        end
        % ax(ii).XAxis.Visible = 'off';
    end

    % Plot the 1 to m-1 subplots
    % categories = {'subject', 'synthetic', 'random'};
    categories = {{'Random'; 'Subject'}, {'Human'; 'Subject'}, {'Ideal'; 'Subject'}};
    counter = 0;

    for ii = 1:(m-1)
        % Get the config filepath
        subset = T(strcmp(T.target_signal_name, subplot_labels{ii}) & contains(T.config_filename, 'AH'), :);
        config_filename = char(subset(1, :).config_filename);
        % Get the data to plot

        if generate_results
            data_to_plot = cell(3, 1);
            data_to_plot{2} = table2array(T(strcmp(T.target_signal_name, subplot_labels{ii}), "r_lr_bins_1"));
            data_to_plot{3} = bootstrap_reconstruction_synth(...
                'config_file', pathlib.join(options.data_dir, config_filename), ...
                'method', 'linear', ...
                'strategy', 'synth', ...
                'N', options.N, ...
                'parallel', options.parallel);
            data_to_plot{1} = bootstrap_reconstruction_synth(...
                'config_file', pathlib.join(options.data_dir, config_filename), ...
                'method', 'linear', ...
                'strategy', 'rand', ...
                'N', options.N, ...
                'parallel', false);
        else
            data_to_plot = data_container{ii};
        end

        for qq = 1:n
            counter = counter + 1;
            % ax(ii, qq) = subplot(m, n, counter);
            axes(ax(sub2ind([m, n], qq, ii)));
            violinplot(data_to_plot{qq}, {''}, 'ViolinAlpha', 0.3, 'ShowBox', true);
            hold on
            p = plot(xlim, [1, 1], '--k');
            p.Color(4) = 0.3;
            p = plot(xlim, [0, 0], '--k');
            p.Color(4) = 0.3;
            p = plot(xlim, [-1, -1], '--k');
            p.Color(4) = 0.3;
            
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
        violinplot(data_to_plot, {''}, 'ViolinAlpha', 0.3, 'ShowBox', true);
        hold on
        p = plot(xlim, [1, 1], '--k');
        p.Color(4) = 0.3;
        p = plot(xlim, [0, 0], '--k');
        p.Color(4) = 0.3;
        p = plot(xlim, [-1, -1], '--k');
        p.Color(4) = 0.3;
        
        if qq == 1
            ylabel(ax(sub2ind([m, n], qq, m)), 'Pearson''s r');
        end

        xlabel(categories{qq});

        % title(ax(sub2ind([m, n], qq, m)), 'combined');
    end

    for ii = 1:length(ax)
        ax(ii).XRuler.Axle.Visible = 'off';
        ax(ii).XTick = [];
    end

end % function
