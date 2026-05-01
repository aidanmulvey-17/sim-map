function info_table_output = get_info_cross_laminar(info_table_hc, info_table_sz, area_designations)
% Computes ONE Hedges' g per study by correctly pooling across cortical layers
% Requires >=4 layers with non-missing/non-zero data

info_table_output = table();

layer_names = {'L1_Mean','L2_Mean','L3_Mean','L4_Mean','L5_Mean','L6_Mean'};
sem_names   = {'L1_SEM', 'L2_SEM', 'L3_SEM', 'L4_SEM', 'L5_SEM', 'L6_SEM'};

for ii = 1:height(info_table_hc)
    if isnan(info_table_hc.Area(ii)) || isempty(info_table_hc.Author{ii})
        continue;
    end
    
    % Basic info
    info_table_output.Author(ii) = info_table_hc.Author(ii);
    info_table_output.Area(ii) = info_table_hc.Area(ii);

    number_indx = find(info_table_output.Area(ii) == area_designations.Number);
    info_table_output.Abbv(ii) = area_designations.Abbreviation(number_indx);
    info_table_output.Structure(ii) = area_designations.Structure(number_indx);
    info_table_output.Group(ii) = area_designations.Group(number_indx);
    
    n_hc = info_table_hc.N(ii);
    n_sz = info_table_sz.N(ii);
    info_table_output.N_HC(ii) = n_hc;
    info_table_output.N_SZ(ii) = n_sz;
    
    % Extract all layer means and SEMs
    hc_means = cellfun(@(c) info_table_hc.(c)(ii), layer_names, 'UniformOutput', false);
    sz_means = cellfun(@(c) info_table_sz.(c)(ii), layer_names, 'UniformOutput', false);
    hc_sems  = cellfun(@(c) info_table_hc.(c)(ii), sem_names,   'UniformOutput', false);
    sz_sems  = cellfun(@(c) info_table_sz.(c)(ii), sem_names,   'UniformOutput', false);
    
    hc_means = [hc_means{:}];
    sz_means = [sz_means{:}];
    hc_sems  = [hc_sems{:}];
    sz_sems  = [sz_sems{:}];
    
    % Keep only layers where BOTH groups have data (and not zero/NaN)
    valid = ~isnan(hc_means) & ~isnan(sz_means) & ~isnan(hc_sems) & ~isnan(sz_sems) & hc_means > 0 & sz_means > 0;
    n_layers = sum(valid);
    
    if n_layers < 4
        info_table_output.g(ii) = NaN;
        info_table_output.var_g(ii) = NaN;
        % info_table_output.n_layers_used(ii) = n_layers;
        continue;  % skip to next study
    end
    
    % Overall mean = arithmetic mean of valid layer means
    mean_HC = mean(hc_means(valid));
    mean_SZ = mean(sz_means(valid));
    
    % Convert SEM → SD, then pooled SD across valid layers
    sd_HC_layers = hc_sems(valid) .* sqrt(n_hc);
    sd_SZ_layers = sz_sems(valid) .* sqrt(n_sz);
    
    var_HC_pooled = sum((n_hc-1) .* sd_HC_layers.^2) / (n_layers*(n_hc-1));
    var_SZ_pooled = sum((n_sz-1) .* sd_SZ_layers.^2) / (n_layers*(n_sz-1));
    
    sd_HC = sqrt(var_HC_pooled);
    sd_SZ = sqrt(var_SZ_pooled);
    
    % Now compute Hedges' g across groups
    s_pooled = sqrt( ((n_hc-1)*var_HC_pooled + (n_sz-1)*var_SZ_pooled) / (n_hc + n_sz - 2) );
    d = (mean_SZ - mean_HC) / s_pooled;
    
    J = 1 - 3/(4*(n_hc + n_sz - 2) - 1);
    g = J * d;
    
    % Exact sampling variance of g
    var_g = J^2 * ( (n_hc + n_sz)/(n_hc*n_sz) + d^2/(2*(n_hc + n_sz)) );
    
    % Store results
    info_table_output.g(ii) = g;
    info_table_output.var_g(ii) = var_g;
    % info_table_output.n_layers_used(ii) = n_layers;
end

% Clean up rows with no data
info_table_output(isnan(info_table_output.g), :) = [];

end