<<<<<<< HEAD
function plot_violin(T, options)
=======
function [ax, data_container] = plot_violin(T, options)
>>>>>>> main

    arguments
        T table
        options.figure = []
<<<<<<< HEAD
        options.cs = true
        options.lr = false
        options.colormap = @colormaps.linspecer
        options.baseline = false
        options.synthetic = false
        options.publish = false
=======
        options.data_dir = '/home/alec/code/tinnitus-project/code/experiment/Data/data-paper'
        options.N = 100
        options.parallel = true
>>>>>>> main
    end

    if isempty(options.figure)
        options.figure = new_figure();
    end

    % Set current figure
    figure(options.figure);

<<<<<<< HEAD
    % Colormap for plotting
    cmap = options.colormap();
=======
    % % Colormap for plotting
    % cmap = options.colormap();
>>>>>>> main

    % How many different target signals are there?
    subplot_labels = unique(T.target_signal_name);
    assert(~isempty(subplot_labels), 'couldn''t find any data to plot')
 
    % Generate one subplot for each unique target signal
<<<<<<< HEAD
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
=======
    m = length(subplot_labels) + 1;
    n = 3;

    % ax = figlib.tightSubplots(m, n, 'ShareX', false, 'ShareY', false, 'padding', 0.05);
    for ii = (m*n):-1:1
        ax(ii) = subplot(m, n, ii);
    end

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
            violinplot(data_to_plot{qq}, {''}, 'ViolinAlpha', 0.3, 'ShowBox', true);
            
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
>>>>>>> main
