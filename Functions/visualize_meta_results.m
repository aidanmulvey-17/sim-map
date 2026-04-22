function visualize_meta_results(statsTable, comparisonInfo, title_str, mode)
    if nargin < 4
        mode = 'Observed';
    end
    hasBootstrap = ismember('BootLowerCI', statsTable.Properties.VariableNames);
    
    if strcmpi(mode, 'Both') && hasBootstrap
        figure;
        subplot(1, 2, 1);
        render_plot(statsTable, comparisonInfo, [title_str ' (Observed)'], 'Observed');
        subplot(1, 2, 2);
        render_plot(statsTable, comparisonInfo, [title_str ' (Bootstrap)'], 'Bootstrap');
    else
        figure;
        render_plot(statsTable, comparisonInfo, title_str, mode);
    end
end

function render_plot(statsTable, comparisonInfo, title_str, mode)
    numGroups = size(statsTable, 1);
    hold on;
    hasBootstrap = ismember('BootLowerCI', statsTable.Properties.VariableNames);
    isBootMode = strcmpi(mode, 'Bootstrap') && hasBootstrap;
    
    % 1. Extract Group Data
    names = statsTable.Names;
    group_ns = statsTable.N; % <--- NEW: Extract N from table
    
    if isBootMode
        means = statsTable.BootMean;
        lowers = statsTable.BootLowerCI;
        uppers = statsTable.BootUpperCI;
        raw_cell = statsTable.BootDistributions;
        p_matrix = comparisonInfo.pairwise_p_boot;
    else
        means = statsTable.WeightedMean;
        lowers = statsTable.LowerCI;
        uppers = statsTable.UpperCI;
        raw_cell = statsTable.RawData;
        p_matrix = comparisonInfo.pairwise_p_obs;
    end
    
    % 2. Generate Pairwise Comparison Bars (Calculated exactly as before)
    compMeans = []; compLow = []; compHigh = []; compNames = {}; compRaw = {}; compP = [];
    for i = 1:numGroups
        for j = i+1:numGroups
            pairName = sprintf('%s vs %s', names{i}, names{j});
            compNames{end+1} = pairName;
            diff_val = means(i) - means(j);
            compMeans(end+1) = diff_val;
            compP(end+1) = p_matrix(i,j);
            if isBootMode
                diff_dist = comparisonInfo.pairwise_diff_boot{i,j};
                compRaw{end+1} = diff_dist;
                compLow(end+1) = prctile(diff_dist, 2.5);
                compHigh(end+1) = prctile(diff_dist, 97.5);
            else
                se_diff = sqrt(statsTable.StdError(i)^2 + statsTable.StdError(j)^2);
                compRaw{end+1} = [];
                compLow(end+1) = diff_val - 1.96*se_diff;
                compHigh(end+1) = diff_val + 1.96*se_diff;
            end
        end
    end

    % 3. Combine Data
    all_means = [means; compMeans'];
    all_low = [lowers; compLow'];
    all_high = [uppers; compHigh'];
    all_names = [names; compNames'];
    all_raw = [raw_cell; compRaw'];
    nTotal = length(all_means);

    % 4. Render Bars
    hBar = bar(1:nTotal, all_means, 'FaceAlpha', 0.5, 'BarWidth', 0.7, 'EdgeColor', 'k');
    hBar.FaceColor = 'flat';
    colors = [lines(numGroups); repmat([0.5 0.5 0.5], length(compMeans), 1)];

    for i = 1:nTotal
        hBar.CData(i,:) = colors(i,:);
        
        % --- NEW: ADD N LABELS TO PRIMARY GROUPS ---
        if i <= numGroups
            % Place 'n=XX' just above or on the zero line
            text(i, 0.05, sprintf('n=%d', group_ns(i)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 9, ...
                'FontWeight', 'bold', ...
                'Color', [0.2 0.2 0.2]); 
        end
        % -------------------------------------------

        if ~isempty(all_raw{i})
            jitter = (rand(size(all_raw{i})) - 0.5) * 0.2;
            scatter(i + jitter, all_raw{i}, 20, colors(i,:), 'filled', 'MarkerFaceAlpha', 0.45);
        end
        
        errorbar(i, all_means(i), all_means(i)-all_low(i), all_high(i)-all_means(i), ...
            'k', 'LineWidth', 1.5, 'CapSize', 8);
        
        if (all_low(i) > 0 || all_high(i) < 0)
            plot(i, all_means(i), 'r*', 'MarkerSize', 10);
        end
        
        if i > numGroups
            p_val = compP(i - numGroups);
            text(i, all_high(i), sprintf('p=%.3f', p_val), ...
                'Color', repmat(p_val < 0.05, 1, 3) .* [1 0 0], ... % Red if p < 0.05
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontSize', 8, 'FontWeight', 'bold');
        end
    end
    
    % Final Chart Styling
    ylabel('Hedges'' g');
    ylim([-2.5 2.5])
    set(gca, 'XTick', 1:nTotal, 'XTickLabel', all_names, 'TickLabelInterpreter', 'none', 'XTickLabelRotation', 45);
    line([numGroups + 0.5, numGroups + 0.5], ylim, 'Color', 'k', 'LineStyle', '--');
    line(xlim, [0 0], 'Color', 'k', 'LineWidth', 1);
    
    % Title Logic (Condensed)
    if isBootMode
        title(sprintf('%s\n(Q_b(boot) = %.2f, p_{boot} = %.3f)', ...
            title_str, mean(comparisonInfo.boot_raw_Qb, 'omitnan'), comparisonInfo.boot_p));
    else
        title({title_str, ...
               sprintf('Q_b = %.2f, p_{obs} = %.3f', comparisonInfo.Qb, comparisonInfo.p), ...
               sprintf('ANOVA: F(%d, %d) = %.2f, p = %.3f', ...
               comparisonInfo.anova_df(1), comparisonInfo.anova_df(2), ...
               comparisonInfo.anova_F, comparisonInfo.anova_p)});
    end
end