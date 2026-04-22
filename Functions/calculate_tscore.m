function tscore_table = calculate_tscore(dataTable_HC, dataTable_SZ)
tscore_table = zeros(sum(~any(isnan(dataTable_HC), 2)), 2);

for ii = 1:height(dataTable_HC)
    m = 2;
    tscore_table(ii, 1) = dataTable_HC(ii, 1);
    if (dataTable_HC(ii, 2) == 0)
        tscore_table(ii, m) = 0;
    else

        n_hc = dataTable_HC(ii, 2);
        n_sz = dataTable_SZ(ii, 2);

        hc_layer_mean = dataTable_HC(ii, 3);
        sz_layer_mean = dataTable_SZ(ii, 3);

        hc_layer_sem = dataTable_HC(ii, 4);
        sz_layer_sem = dataTable_SZ(ii, 4);

        hc_layer_sd = hc_layer_sem * sqrt(n_hc);
        sz_layer_sd = sz_layer_sem * sqrt(n_sz);

        sz_term = (n_sz - 1) .* (sz_layer_sd^2);
        hc_term = (n_hc - 1) .* (hc_layer_sd^2);

        s_pooled = sqrt( (sz_term + hc_term) / (n_hc + n_sz - 2) );
        j_factor = 1 - (3 ./ (4 * (n_hc + n_sz - 2) - 1)); %small-sample correction factor
        d_term = (sz_layer_mean - hc_layer_mean) / s_pooled;

        hedges_g = j_factor .* d_term;

        tscore_table(ii, m) = hedges_g;
        
        % tscore_table(ii, m) = (dataTable_SZ(ii, 2) - dataTable_HC(ii, 2)) / sqrt((dataTable_HC(ii, 3))^2 + (dataTable_SZ(ii, 3))^2);
    end
    m = m + 1;
end

end