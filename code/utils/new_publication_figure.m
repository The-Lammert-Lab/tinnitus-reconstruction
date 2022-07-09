function fig = new_publication_figure(options)

    arguments
        options.fontsize = 8
        options.width = 8
        options.height = 10
        options.units = 'centimeters'
    end

    fig = figure('Units', options.units, 'Position', [0, 0, options.width, options.height]);
end