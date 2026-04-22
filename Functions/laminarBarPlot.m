function [meansTable, statsResults] = laminarBarPlot(varargin)
% LAMINARBARPLOT Plot laminar effects and return statistical tables
% [meansTable, statsResults] = laminarBarPlot(data1, data2, ...)

% Initialize stats collection
statsData = struct('Comparison', {}, 'Layer', {}, 'Cohens_d', {}, 'CI_Lower', {}, 'CI_Upper', {}, 'pVal', {});
statsIdx = 1;

% Pre-calculate Mean and SEM
for j = 1:length(varargin)
    meanVals(j, :) = mean(varargin{j}, 1, 'omitnan');
    semVals(j, :) = 2*(std(varargin{j}, [], 1, 'omitnan') ./ sqrt(sum(~isnan(varargin{j}), 1)));
end

% Extract Variable Names for Labels
labels = cell(1, nargin);
for j = 1:nargin
    varName = inputname(j);
    if isempty(varName), varName = sprintf('Input%d', j); end
    labels{j} = varName; 
end

num_colors = length(varargin);
rgb_colors = rand(num_colors, 3);

figure; hold on;
set(gca, 'YDir', 'reverse');

for i = 1:6 % Iterate through Layers
    b = barh(i, meanVals(:, i));
    for ii = 1:length(varargin)
        color = rgb_colors(ii, :);
        b(ii).FaceColor = color; b(ii).FaceAlpha = 0.3; b(ii).EdgeColor = color;
        yPos = b(ii).XEndPoints;
        
        % Scatter individual data points
        scatter(varargin{ii}(:,i), yPos, 250, '.', 'MarkerEdgeColor', color)
        % Error bars
        errorbar(meanVals(ii, i), yPos, semVals(ii, i), 'horizontal', 'LineStyle', 'none', 'Color', color)
        
        % One-sample t-test (vs 0) for Stars
        [~, p_one] = ttest(varargin{ii}(:,i));
        if p_one < 0.001
            text(-2.7, yPos, '***', 'Color', color, 'FontWeight', 'bold', 'FontSize', 20)
        elseif p_one < 0.01
            text(-2.7, yPos, '**', 'Color', color, 'FontWeight', 'bold', 'FontSize', 20)
        elseif p_one < 0.05
            text(-2.7, yPos, '*', 'Color', color, 'FontWeight', 'bold', 'FontSize', 20)
        end

        % Group vs Group comparisons
        for jj = ii+1:length(varargin)
            x = varargin{ii}(:,i); y = varargin{jj}(:,i);
            [~, p_two] = ttest2(x, y);
            yPos1 = b(ii).XEndPoints; yPos2 = b(jj).XEndPoints;
            
            % Effect Size Calculation
            effect = meanEffectSize(x, y, 'Effect', "cohen");
            
            % Record stats for Table output
            statsData(statsIdx).Comparison = sprintf('%s vs %s', labels{ii}, labels{jj});
            statsData(statsIdx).Layer = i;
            statsData(statsIdx).Cohens_d = effect.Effect;
            statsData(statsIdx).CI_Lower = effect.ConfidenceIntervals(1);
            statsData(statsIdx).CI_Upper = effect.ConfidenceIntervals(2);
            statsData(statsIdx).pVal = p_two;
            statsIdx = statsIdx + 1;

            % Overlay text on plot
            text(1, (yPos1+yPos2)/2, [num2str(effect.Effect, 2), ' [', num2str(effect.ConfidenceIntervals(1), 2), ', ', num2str(effect.ConfidenceIntervals(2), 2), ']'], 'HorizontalAlignment', 'left', 'FontSize', 8);
            text(0.5, yPos1, ['n = ', num2str(sum(~isnan(x)))], 'HorizontalAlignment', 'left', 'FontSize', 8);
            
            if p_two < 0.05
                line([-2.8 -2.8], [yPos1 yPos2], 'Color', 'k', 'LineWidth', 2)
                if p_two < 0.001
                    text(-2.8, (yPos1+yPos2)/2, '***', 'Rotation', 90, 'FontWeight', 'bold', 'FontSize', 20, 'HorizontalAlignment', 'center')
                elseif p_two < 0.01
                    text(-2.8, (yPos1+yPos2)/2, '**', 'Rotation', 90, 'FontWeight', 'bold', 'FontSize', 20, 'HorizontalAlignment', 'center')
                else
                    text(-2.8, (yPos1+yPos2)/2, '*', 'Rotation', 90, 'FontWeight', 'bold', 'FontSize', 20, 'HorizontalAlignment', 'center')
                end
            end
        end
    end
end

% Plot Aesthetics
xlim([-3 3]); yticks(1:6);
text(1, 0.5, 'Cohen''s d [95% CI]', 'HorizontalAlignment', 'center');
text(0.5, 0.5, 'n', 'HorizontalAlignment', 'center');
xlabel('Effect Size'); ylabel('Cortical Layer');
legend(labels, 'Location','bestoutside');

% Format Output Tables
statsResults = struct2table(statsData);
meansTable = array2table(meanVals, 'RowNames', labels, 'VariableNames', compose('Layer_%d', 1:6));
end