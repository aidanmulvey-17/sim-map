function forestplot2(paperNames, paperYears, paperAreas, cellType, data)
% Outputs a forest plot given the paper titles as a string AND an N-by-N double array

meanValues(:, 1) = mean(data(:, :), 2, 'omitnan');
errorbars = zeros(height(data), 1);
for i = 1:height(data)
    errorbars(i, :) = 2*(std(data(i, :), 'omitnan') ./ sqrt(width(data)));
end

% Sort data based on meanValues
[sortedMeanValues, sortIndex] = sort(meanValues(:, 1));
sortedData = data(sortIndex, :);
sortedPaperNames = paperNames(sortIndex, :);
sortedPaperYears = paperYears(sortIndex, :);
sortedPaperAreas = paperAreas(sortIndex, :);

figure;
scatter(sortedMeanValues, 1:height(data), 80, 'k', 'filled');
%scatter(sortedMeanValues(8, :), 8, 80, 'r', 'filled')
hold on
errorbar(sortedMeanValues, 1:height(data), errorbars(sortIndex, 1), "horizontal", 'LineStyle',"none", "Color", 'k', 'LineWidth',2)
%errorbar(sortedMeanValues, 8, errorbars(sortIndex, 1), "horizontal", 'LineStyle',"none", "Color", 'r', 'LineWidth',2)
xlabel("Mean T-Score (+/- 2 SEM)");
yyaxis left
ylabel("Paper Title (Year)")
yticklabels(append(sortedPaperNames(:, 1), ' (', string(sortedPaperYears), ')'));
yticks(1:height(data));
ylim([0 height(data)+1])
yyaxis right
ylabel("Area")
yticklabels(sortedPaperAreas)
yticks(1:height(data));
ylim([0 height(data)+1])
xline(0, 'r--')
xlim([-5 5])
title(append('Mean t-score of Studies of ', cellType))
%text(meanValues(:,1), 1:height(data), areas, 'VerticalAlignment', 'bottom', 'HorizontalAlignment','center')
end