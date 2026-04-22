function info_table_output = get_laminar_info(info_table_hc,info_table_sz, area_designations, cellType, methodType)
% obtain the necessary information and calculate hedges g effect size on
% laminar data given tabular inputs.

info_table_output = table();

layer_names = {'L1_Mean','L2_Mean','L3_Mean','L4_Mean','L5_Mean','L6_Mean'};
sem_names = {'L1_SEM','L2_SEM','L3_SEM','L4_SEM','L5_SEM','L6_SEM'};

table_layer_names = {'L1_g','L2_g','L3_g','L4_g','L5_g','L6_g'};
table_variance_names = {'L1_var_g','L2_var_g','L3_var_g','L4_var_g','L5_var_g','L6_var_g'};

for ii = 1:height(info_table_hc(~isnan(info_table_hc.Area), :))
    info_table_output.Author(ii) = info_table_hc.Author(ii);
    info_table_output.Area(ii) = info_table_hc.Area(ii);

    number_indx = find(info_table_output.Area(ii) == area_designations.Number);
    info_table_output.Abbv(ii) = area_designations.Abbreviation(number_indx);
    info_table_output.Structure(ii) = area_designations.Structure(number_indx);
    info_table_output.Group(ii) = area_designations.Group(number_indx);
    info_table_output.CellType(ii) = cellType;
    info_table_output.MethodType(ii) = methodType;
    
    n_hc = info_table_hc.N(ii);
    n_sz = info_table_sz.N(ii);

    info_table_output.N_HC(ii) = n_hc;
    info_table_output.N_SZ(ii) = n_sz;
    
    for jj = 1:size(layer_names, 2)
        layer = layer_names{jj};
        sem = sem_names{jj};

        table_layer = table_layer_names{jj};
        table_var = table_variance_names{jj};

        if (info_table_hc.(layer)(ii) == 0)
            info_table_output.(table_layer)(ii) = 0;
        else
            hc_layer_mean = info_table_hc.(layer)(ii);
            sz_layer_mean = info_table_sz.(layer)(ii);

            hc_layer_sem = info_table_hc.(sem)(ii);
            sz_layer_sem = info_table_sz.(sem)(ii);

            hc_layer_sd = hc_layer_sem * sqrt(n_hc);
            sz_layer_sd = sz_layer_sem * sqrt(n_sz);

            sz_term = (n_sz - 1) .* (sz_layer_sd^2);
            hc_term = (n_hc - 1) .* (hc_layer_sd^2);

            s_pooled = sqrt( (sz_term + hc_term) / (n_hc + n_sz - 2) );
            j_factor = 1 - (3 ./ (4 * (n_hc + n_sz - 2) - 1)); %small-sample correction factor
            d_term = (sz_layer_mean - hc_layer_mean) / s_pooled;

            hedges_g = j_factor .* d_term;
            var_g = j_factor^2 * ( (n_hc + n_sz)/(n_hc*n_sz) + d_term^2/(2*(n_hc + n_sz)) );

            info_table_output.(table_layer)(ii) = hedges_g;
            info_table_output.(table_var)(ii) = var_g;
        end

    end

end

end