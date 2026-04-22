function [wholeArea_hedges, HC_summary_output, SZ_summary_output] = calcArea_tscore(HC_table,SZ_table)
%calcArea_tscore calculates the tscore for an area based on the laminar data

HC_summary = zeros(height(HC_table), 3);   % [ID, mean, SD]
SZ_summary = zeros(height(SZ_table), 3);

% Columns in table: 1=ID, 2=n, 3/5/7/9/11/13 = layer means, 4/6/8/10/12/14 = layer SEMs

for j = 1:height(HC_table)
    layer_means = HC_table(j, [3,5,7,9,11,13]);
    layer_sems  = HC_table(j, [4,6,8,10,12,14]);
    n_subj = HC_table(j,2);
    valid = ~isnan(layer_means);
    
    if sum(valid) < 4
        continue; % skip: <4 layers
    end
    
    % Overall mean = arithmetic mean of reported layers
    overall_mean = mean(layer_means(valid));
    
    % Convert SEM → SD, then pooled SD across layers
    layer_sds = layer_sems(valid) .* sqrt(n_subj);
    pooled_var = sum((n_subj-1) * layer_sds.^2) / (sum(valid) * (n_subj-1));
    overall_sd = sqrt(pooled_var);
    
    HC_summary(j,:) = [HC_table(j,1), overall_mean, overall_sd];
end

% Same for SZ group
for j = 1:height(SZ_table)
    layer_means = SZ_table(j, [3,5,7,9,11,13]);
    layer_sems = SZ_table(j, [4,6,8,10,12,14]);
    n_subj = SZ_table(j,2);
    valid = ~isnan(layer_means);
    
    if sum(valid) < 4
        continue;
    end
    
    overall_mean = mean(layer_means(valid));
    layer_sds = layer_sems(valid) .* sqrt(n_subj);
    pooled_var = sum((n_subj-1) * layer_sds.^2) / (sum(valid)*(n_subj-1));
    overall_sd = sqrt(pooled_var);
    
    SZ_summary(j,:) = [SZ_table(j,1), overall_mean, overall_sd];
end

% Now compute Hedges' g only for studies present in BOTH groups
valid_rows = HC_summary(:,1) > 0 & SZ_summary(:,1) > 0;
if ~any(valid_rows)
    wholeArea_hedges = table(NaN, NaN, 'VariableNames',{'g','var_g'});
    return;
end

HC_summary_output = HC_summary(valid_rows, :);
SZ_summary_output = SZ_summary(valid_rows, :);

mean_HC = HC_summary(valid_rows,2);
mean_SZ = SZ_summary(valid_rows,2);
sd_HC = HC_summary(valid_rows,3);
sd_SZ = SZ_summary(valid_rows,3);
n_HC = HC_table(valid_rows,2);
n_SZ = SZ_table(valid_rows,2);

% Pooled SD across groups (HC/SZ)
pooled_sd = sqrt( ((n_HC-1).*sd_HC.^2 + (n_SZ-1).*sd_SZ.^2) ./ (n_HC + n_SZ - 2) );

% Cohen's d
d = (mean_SZ - mean_HC) ./ pooled_sd;

% Hedges' g correction
df = n_HC + n_SZ - 2;
J = 1 - 3./(4*df - 1);
g = J .* d;

% Sampling variance of g
var_g = J.^2 .* ( (n_HC + n_SZ)./(n_HC.*n_SZ) + d.^2 ./ (2*(n_HC + n_SZ)) );

% Output as table (ready for metafor or your random-effects model)
wholeArea_hedges(:, 1) = HC_summary(valid_rows, 1);
wholeArea_hedges(:, 2) = g;

end