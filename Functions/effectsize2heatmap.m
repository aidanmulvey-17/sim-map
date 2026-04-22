function info_table = effectsize2heatmap(input_table, input_range, varName)

    individual_structures = unique(input_table.Structure);
    num_areas = height(individual_structures);
    
    info_table = table(individual_structures, zeros(num_areas, 1), zeros(num_areas, 1), ...
        'VariableNames', {'Area', 'EffectSize', 'n'});
    
    for q = 1:num_areas
        area_id = individual_structures{q};
        
        all_effect_size = input_table.g(strcmpi(input_table.Structure, area_id));
        info_table.EffectSize(q) = mean(all_effect_size);
        info_table.n(q) = numel(all_effect_size);
    end

    % --- Plotting Logic ---
    xrange = -input_range; 
    
    x = linspace(xrange, input_range, 100);
    y = [0.5, num_areas + 0.5];
    [X, Y] = meshgrid(x, y);

    figure('Color', 'w');
    colormap(jet);
    h = pcolor(X, Y, X); 
    set(h, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    hold on;
    scatter(info_table.EffectSize, (1:num_areas)', 85, info_table.EffectSize, ...
        'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.1);

    for q = 1:num_areas
        text(info_table.EffectSize(q) + (input_range * 0.02), q, info_table.Area{q}, ...
            'FontSize', 9, 'VerticalAlignment', 'middle', 'FontWeight', 'bold');
    end

    clim([xrange input_range]); 
    xlabel('Effect Size (Hedges'' g)');
    ylabel('Structure Index');
    title(['Affected Brain Areas: ', varName]);
    set(gca, 'YTick', 1:num_areas, 'YGrid', 'on', 'XGrid', 'on', 'Layer', 'top');
    colorbar('Location', 'eastoutside');
    xline(0, 'k-', 'LineWidth', 2);
    xlim([xrange input_range]);
    ylim([0.5, num_areas + 0.5]);

    if any(info_table.EffectSize < xrange) || any(info_table.EffectSize > input_range)
        text(0, num_areas + 0.8, '⚠️ Note: Effect size exceeds bounds', ...
            'Color', 'r', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
end