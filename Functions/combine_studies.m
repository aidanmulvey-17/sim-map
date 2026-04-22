function output_table = combine_studies(input_table)

    [unique_combos, ~, group_idx] = unique(input_table(:, {'Author', 'Structure', 'Group'}), 'rows', 'stable');
    
    num_groups = size(unique_combos, 1);
    output_table = table();
    assumed_r = 0.75; % the assumed correlation btw combined areas

    for jj = 1:num_groups

        study_indices = find(group_idx == jj);
        first_idx = study_indices(1);
        
        output_table.Author(jj, 1) = unique_combos.Author(jj);        
        output_table.Abbv(jj) = {strjoin(input_table.Abbv(study_indices), ', ')};
        output_table.Structure(jj, 1) = unique_combos.Structure(jj);
        output_table.Group(jj, 1) = unique_combos.Group(jj);
        
        effect_sizes = input_table.g(study_indices);
        variance_g = input_table.var_g(study_indices);
        n_obs = numel(study_indices);
        
        % Math for mean effect size and pooled variance
        output_table.g(jj) = mean(effect_sizes);
        
        sum_var = sum(variance_g);
        sd_var = sqrt(variance_g);
        sum_var_products = (sum(sd_var)^2) - sum(sd_var.^2);
        
        var_pooled = (1/n_obs^2) * (sum_var + (assumed_r * sum_var_products));
        output_table.var_g(jj) = var_pooled;

        output_table.N_HC(jj) = input_table.N_HC(first_idx);
        output_table.N_SZ(jj) = input_table.N_SZ(first_idx);
        output_table.Method(jj) = input_table.Method(first_idx);
        output_table.TissueBank(jj) = input_table.TissueBank(first_idx);
        output_table.FixMethod(jj) = input_table.FixMethod(first_idx);
        output_table.TissueBankCode(jj) = input_table.TissueBankCode(first_idx);
        output_table.FixMethodCode(jj) = input_table.FixMethodCode(first_idx);
        output_table.HC_ages(jj) = input_table.HC_ages(first_idx);
        output_table.SZ_ages(jj) = input_table.SZ_ages(first_idx);
        output_table.HC_sex_ratio(jj) = input_table.HC_sex_ratio(first_idx);
        output_table.SZ_sex_ratio(jj) = input_table.SZ_sex_ratio(first_idx);
        output_table.HC_PH(jj) = input_table.HC_PH(first_idx);
        output_table.SZ_PH(jj) = input_table.SZ_PH(first_idx);
        output_table.HC_PMI(jj) = input_table.HC_PMI(first_idx);
        output_table.SZ_PMI(jj) = input_table.SZ_PMI(first_idx);
        output_table.CellType(jj) = input_table.CellType(first_idx);
        output_table.MethodType(jj) = input_table.MethodType(first_idx);
    end
end