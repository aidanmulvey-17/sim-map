function [wholeArea_hedges, HC_meansG, SZ_meansG] = group_layers_hedges(HC_table, SZ_table)
% Outputs Hedges' g for multi-layer studies
% Pools layers within each subject group using proper pooled SD

HC_meansG = zeros(height(HC_table), 3);  % Col1: SubjectID, Col2: mean density, Col3: SD
SZ_meansG = zeros(height(SZ_table), 3);

%% Step 1: Pool layers within HC and SZ groups (per subject)
for j = 1:height(HC_table)
    densities = HC_table(j, [3,5,7,9,11,13]);   % layer means
    ns        = HC_table(j, [2,4,6,8,10,12]);   % n per layer (usually same)
    valid     = ~isnan(densities) & ~isnan(ns);
    
    if ~any(valid)
        HC_meansG(j,:) = [HC_table(j,1), NaN, NaN];
        continue;
    end
    
    densities = densities(valid);
    n_layer   = ns(valid(1));  % assume same n across layers
    
    % Weighted mean across layers
    mean_val = mean(densities, 'omitnan');
    
    % Pooled SD across layers (correct degrees of freedom)
    variances = var(densities, 0, 'omitnan');  % sample variance per layer
    pooled_var = sum((n_layer-1) * variances) / (sum(valid)*(n_layer-1));
    pooled_sd  = sqrt(pooled_var);
    
    HC_meansG(j,:) = [HC_table(j,1), mean_val, pooled_sd];
end

% Same for SZ
for j = 1:height(SZ_table)
    densities = SZ_table(j, [3,5,7,9,11,13]);
    ns        = SZ_table(j, [2,4,6,8,10,12]);
    valid     = ~isnan(densities) & ~isnan(ns);
    
    if ~any(valid)
        SZ_meansG(j,:) = [SZ_table(j,1), NaN, NaN];
        continue;
    end
    
    densities = densities(valid);
    n_layer   = ns(valid(1));
    
    mean_val = mean(densities, 'omitnan');
    variances = var(densities, 0, 'omitnan');
    pooled_var = sum((n_layer-1) * variances) / (sum(valid)*(n_layer-1));
    pooled_sd  = sqrt(pooled_var);
    
    SZ_meansG(j,:) = [SZ_table(j,1), mean_val, pooled_sd];
end

%% Compute Hedges' g across all subjects
valid = ~isnan(HC_meansG(:,2)) & ~isnan(SZ_meansG(:,2));
HC = HC_meansG(valid, 2:3);
SZ = SZ_meansG(valid, 2:3);

if isempty(HC) || height(HC) < 2
    wholeArea_hedges = table(NaN, NaN, NaN, 'VariableNames',{'g','var_g','n_total'});
    return;
end

mean_HC = HC(:,1);  sd_HC = HC(:,2);
mean_SZ = SZ(:,1);  sd_SZ = SZ(:,2);
n_HC = height(HC);  n_SZ = height(SZ);

% Pooled SD (correct formula)
pooled_sd = sqrt( ((n_HC-1)*sd_HC.^2 + (n_SZ-1)*sd_SZ.^2) / (n_HC + n_SZ - 2) );

% Cohen's d
d = (mean_SZ - mean_HC) ./ pooled_sd;

% Hedges' g correction
df = n_HC + n_SZ - 2;
J  = 1 - 3/(4*df - 1);
g  = J * d;

% Sampling variance of Hedges' g
var_g = J.^2 * ( (n_HC + n_SZ)/(n_HC*n_SZ) + d.^2/(2*(n_HC + n_SZ)) );

% Output as table
wholeArea_hedges = table(g, var_g, n_HC + n_SZ, 'VariableNames', {'g', 'var_g', 'n_total'});

end