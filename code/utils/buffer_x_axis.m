function xlims = buffer_x_axis(vec, buffer)
    diff_scale = max(vec) - min(vec);
    this_min = min(vec) - buffer * diff_scale;
    this_max = max(vec) + buffer * diff_scale;
    xlims = [this_min, this_max];
end