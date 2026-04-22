function forestplot(paperNames, paperYears, paperAreas, cellType, data)
%Outputs a forest plot given the paper titles as a string AND an N-by-N double array

meanValues(:, 1) = mean(data(:, :), 2, 'omitnan');

errorbars = zeros(height(data), 1);
for i = 1:height(data)
    errorbars(i, :) = 2*(std(data(i, :), 'omitnan') ./ sqrt(width(data)));
end

figure;
scatter(meanValues(:,1), 1:height(data), 80, 'k', 'filled');
hold on
errorbar(meanValues(:,1), 1:height(data), errorbars(1:end, 1), "horizontal", 'LineStyle',"none", "Color", 'k', 'LineWidth',2)
xlabel("Mean T-Score (+/- 2 SEM)");
yyaxis left
ylabel("Paper Title (Year)")
yticklabels(append(paperNames(:, 1), ' (', string(paperYears), ')'));
yticks(1:height(data));
ylim([0 height(data)+1])

yyaxis right
ylabel("Area")
yticklabels(paperAreas)
yticks(1:height(data));
ylim([0 height(data)+1])

xline(0, 'r--')
xlim([-5 5])
title(append('Mean t-score of Studies of ', cellType))
%text(meanValues(:,1), 1:height(data), areas, 'VerticalAlignment', 'bottom', 'HorizontalAlignment','center')
end