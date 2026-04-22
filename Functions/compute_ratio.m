function [stats] = compute_ratio(input_table, group)
    num_boots = 1000;
    max_tries = 5000; % Safety break to prevent infinite loops

    user_group = input_table(contains(input_table.Group, group), :);
    layers = [user_group.L1_g, user_group.L2_g, user_group.L3_g, ...
              user_group.L4_g, user_group.L5_g, user_group.L6_g];
    
    n_samples = size(layers, 1);
    
    if n_samples == 0
        stats = struct(); % Return empty or populated with NaNs
        return; 
    end

    boot_total_means = NaN(num_boots, 1);
    boot_reception_means = NaN(num_boots, 1);
    boot_sender_means = NaN(num_boots, 1);
    
    for i = 1:num_boots
        valid = false; count = 0;
        while ~valid && count < max_tries
            count = count + 1;
            idx = randsample(n_samples, n_samples, true);
            td_v = mean(layers(idx, [1, 5, 6]), 2, 'omitnan');
            bu_v = mean(layers(idx, [2, 3, 4]), 2, 'omitnan');
            r = (abs(bu_v) ./ abs(td_v)) - 1;
            r_finite = r(isfinite(r));
            if ~isempty(r_finite)
                boot_total_means(i) = mean(r_finite);
                valid = true;
            end
        end
        
        valid = false; count = 0;
        while ~valid && count < max_tries
            count = count + 1;
            idx = randsample(n_samples, n_samples, true);
            r = (abs(layers(idx, 4)) ./ abs(layers(idx, 1))) - 1;
            r_finite = r(isfinite(r));
            if ~isempty(r_finite)
                boot_reception_means(i) = mean(r_finite);
                valid = true;
            end
        end
        
        valid = false; count = 0;
        while ~valid && count < max_tries
            count = count + 1;
            idx = randsample(n_samples, n_samples, true);
            s_bu_v = mean(layers(idx, [2, 3]), 2, 'omitnan');
            s_td_v = mean(layers(idx, [5, 6]), 2, 'omitnan');
            r = (abs(s_bu_v) ./ abs(s_td_v)) - 1;
            r_finite = r(isfinite(r));
            if ~isempty(r_finite)
                boot_sender_means(i) = mean(r_finite);
                valid = true;
            end
        end
    end

    stats.total_ratio_mean = mean(boot_total_means, 'omitnan');
    stats.total_ratio_var  = var(boot_total_means, 'omitnan');
    stats.total_CI         = prctile(boot_total_means, [2.5, 97.5]);
    
    stats.receivers_ratio_mean = mean(boot_reception_means, 'omitnan');
    stats.receivers_ratio_var  = var(boot_reception_means, 'omitnan');
    stats.receivers_CI         = prctile(boot_reception_means, [2.5, 97.5]);
    
    stats.senders_ratio_mean = mean(boot_sender_means, 'omitnan');
    stats.senders_ratio_var  = var(boot_sender_means, 'omitnan');
    stats.senders_CI         = prctile(boot_sender_means, [2.5, 97.5]);
    
    stats.boot_distributions.total = boot_total_means;
    stats.boot_distributions.receivers = boot_reception_means;
    stats.boot_distributions.senders = boot_sender_means;
end