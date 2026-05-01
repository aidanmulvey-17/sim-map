function output_table = combine_studies_multi_layer(input_table)
    % Define the grouping columns
    group_cols = {'Author', 'Structure', 'Group', 'CellType', 'MethodType'};
    [unique_combos, ~, group_idx] = unique(input_table(:, group_cols), 'rows', 'stable');
    
    num_groups = size(unique_combos, 1);
    output_table = table();
    assumed_r = 0.75; % The assumed correlation between combined areas
    
    % Define the layers we are processing
    num_layers = 6; 

    for jj = 1:num_groups
        study_indices = find(group_idx == jj);
        first_idx = study_indices(1);
        
        % Assign Metadata (Static info from the first entry of the group)
        output_table.Author(jj, 1)    = unique_combos.Author(jj);        
        output_table.Abbv(jj)         = {strjoin(input_table.Abbv(study_indices), ', ')};
        output_table.Structure(jj, 1) = unique_combos.Structure(jj);
        output_table.Group(jj, 1)     = unique_combos.Group(jj);
        output_table.Area(jj, 1)      = input_table.Area(first_idx);
        output_table.CellType(jj, 1)  = input_table.CellType(first_idx);
        output_table.MethodType(jj, 1)= input_table.MethodType(first_idx);
        output_table.N_HC(jj, 1)      = input_table.N_HC(first_idx);
        output_table.N_SZ(jj, 1)      = input_table.N_SZ(first_idx);
        output_table.TissueBank(jj, 1)= input_table.TissueBank(first_idx);
        output_table.FixMethod(jj, 1) = input_table.FixMethod(first_idx);
        
        % Loop through each Layer (L1 to L6)
        n_obs = numel(study_indices);
        
        for L = 1:num_layers
            g_col = sprintf('L%d_g', L);
            var_col = sprintf('L%d_var_g', L);
            
            % Extract g and variance for this specific layer across the grouped studies
            effect_sizes = input_table.(g_col)(study_indices);
            variance_g = input_table.(var_col)(study_indices);
            
            % Calculate combined Mean Effect Size
            output_table.(g_col)(jj, 1) = mean(effect_sizes);
            
            % Calculate Pooled Variance using the correlation formula
            sum_var = sum(variance_g);
            sd_var = sqrt(variance_g);
            sum_var_products = (sum(sd_var)^2) - sum(sd_var.^2);
            
            var_pooled = (1/n_obs^2) * (sum_var + (assumed_r * sum_var_products));
            output_table.(var_col)(jj, 1) = var_pooled;
        end
    end
end