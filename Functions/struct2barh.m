function statsTable = struct2barh(inputStruct, areaIdentification, titleLabel)
% STRUCT2BARH Bar plot for hierarchical areas with stats table output

fields = fieldnames(inputStruct);
fieldRanks = zeros(length(fields), 1);

% 1. Determine Ranking
for ii = 1:length(fields)
    rankName = fields{ii};
    areaRank = inputStruct.(rankName)(1);
    fieldRanks(ii) = cell2mat(areaIdentification(((cell2mat(areaIdentification(:, 1))) == areaRank), 4));
end
[~, rankIndx] = sort(fieldRanks, 'descend');
ranks = zeros(size(fieldRanks));
ranks(rankIndx) = 1:length(fieldRanks);

% 2. Initialize Stats Collection
statsData = struct('Area', {}, 'Mean', {}, 'n', {}, 'pVal', {});
numSEM = 2;

figure; hold on;
areaLabels = cell(length(fields), 1);

for ar = 1:length(fields)
    fieldName = fields{ar};
    areaNumber = inputStruct.(fieldName)(1, 1);
    fieldValues = inputStruct.(fieldName)(:, 2);
    
    % Clean data (remove NaNs)
    cleanValues = fieldValues(~isnan(fieldValues));
    
    areaMean = mean(cleanValues);
    areaN = numel(cleanValues);
    SEM = numSEM * (std(cleanValues) / sqrt(areaN));
    
    % Plotting
    barh(ranks(ar), areaMean)
    scatter(cleanValues, ranks(ar), 250, '.', 'MarkerEdgeColor', 'k')
    if SEM ~= 0
        errorbar(areaMean, ranks(ar), SEM, 'k', 'horizontal', 'LineStyle', 'none')
    end
    
    % Get area label from ID table
    currentLabel = cell2mat(areaIdentification(((cell2mat(areaIdentification(:, 1))) == areaNumber), 3));
    areaLabels{ar} = currentLabel;
    
    % One-sample t-test
    [~, p] = ttest(cleanValues);
    
    % Log Data for Output Table
    statsData(ar).Area = currentLabel;
    statsData(ar).Mean = areaMean;
    statsData(ar).n    = areaN;
    statsData(ar).pVal = p;
    
    % Plot Stars
    if p < 0.001
        text(3, ranks(ar), '***', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 20, 'Rotation', 90)
    elseif p < 0.01
        text(3, ranks(ar), '**', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 20, 'Rotation', 90)
    elseif p < 0.05
        text(3, ranks(ar), '*', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 20, 'Rotation', 90)
    end
end

% Formatting
yticks(1:length(fields))
yticklabels(areaLabels(rankIndx))
xlim([-5 5])
ylabel('Area')
xlabel('Effect Size')
title(titleLabel)

% Convert results to Table
statsTable = struct2table(statsData);
end