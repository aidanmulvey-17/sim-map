function info_table_output = get_nonlaminar_info(info_table, area_designations)

info_table_output = table();

for ii = 1:height(info_table(~isnan(info_table.Area), :))
    info_table_output.Author(ii) = info_table.Author(ii);
    info_table_output.Area(ii) = info_table.Area(ii);

    number_indx = find(info_table_output.Area(ii) == area_designations.Number);
    info_table_output.Abbv(ii) = area_designations.Abbreviation(number_indx);
    info_table_output.Structure(ii) = area_designations.Structure(number_indx);
    info_table_output.Group(ii) = area_designations.Group(number_indx);

    n_hc = info_table.N_HC(ii);
    n_sz = info_table.N_HC(ii);

    info_table_output.N_HC(ii) = n_hc;
    info_table_output.N_SZ(ii) = n_sz;

    hc_layer_mean = info_table.HC_Mean(ii);
    sz_layer_mean = info_table.SZ_Mean(ii);

    hc_layer_sem = info_table.HC_SEM(ii);
    sz_layer_sem = info_table.SZ_SEM(ii);

    hc_layer_sd = hc_layer_sem * sqrt(n_hc);
    sz_layer_sd = sz_layer_sem * sqrt(n_sz);

    sz_term = (n_sz - 1) .* (sz_layer_sd^2);
    hc_term = (n_hc - 1) .* (hc_layer_sd^2);

    s_pooled = sqrt( (sz_term + hc_term) / (n_hc + n_sz - 2) );
    j_factor = 1 - (3 ./ (4 * (n_hc + n_sz - 2) - 1)); %small-sample correction factor
    d_term = (sz_layer_mean - hc_layer_mean) / s_pooled;

    hedges_g = j_factor .* d_term;
    var_g = j_factor^2 * ( (n_hc + n_sz)/(n_hc*n_sz) + d_term^2/(2*(n_hc + n_sz)) );

    info_table_output.g(ii) = hedges_g;
    info_table_output.var_g(ii) = var_g;

end
end