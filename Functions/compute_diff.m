function [stats] = compute_diff(input_table, group)
    num_boots = 1000;
    user_group = input_table(contains(input_table.Group, group), :);
    
    % Extract layer columns
    layers = [user_group.L1_g, user_group.L2_g, user_group.L3_g, ...
              user_group.L4_g, user_group.L5_g, user_group.L6_g];
    
    n_studies = size(layers, 1);
    if n_studies == 0, stats = struct(); return; end
    
    boot_total_diffs = NaN(num_boots, 1);
    boot_reception_diffs = NaN(num_boots, 1);
    boot_sender_diffs = NaN(num_boots, 1);
    
    for i = 1:num_boots
        % Resample studies with replacement
        idx = randsample(n_studies, n_studies, true);
        curr_boot_layers = layers(idx, :);
        
        % --- Total Difference (Pooled L2/3/4 vs Pooled L1/5/6) ---
        bu_pool = curr_boot_layers(:, [2, 3, 4]);
        td_pool = curr_boot_layers(:, [1, 5, 6]);
        % Calculate absolute means of the entire pools
        m_bu = mean(abs(bu_pool(:)), 'omitnan');
        m_td = mean(abs(td_pool(:)), 'omitnan');
        boot_total_diffs(i) = m_bu - m_td;
        
        % --- Receivers Difference (Pooled L4 vs Pooled L1) ---
        m_l4 = mean(abs(curr_boot_layers(:, 4)), 'omitnan');
        m_l1 = mean(abs(curr_boot_layers(:, 1)), 'omitnan');
        boot_reception_diffs(i) = m_l4 - m_l1;
        
        % --- Senders Difference (Pooled L2/3 vs Pooled L5/6) ---
        s_bu_pool = curr_boot_layers(:, [2, 3]);
        s_td_pool = curr_boot_layers(:, [5, 6]);
        m_s_bu = mean(abs(s_bu_pool(:)), 'omitnan');
        m_s_td = mean(abs(s_td_pool(:)), 'omitnan');
        boot_sender_diffs(i) = m_s_bu - m_s_td;
    end
    
    % Store Results (Using the same structure for compatibility with your plot)
    stats.total_diff_mean = mean(boot_total_diffs, 'omitnan');
    stats.total_diff_var  = var(boot_total_diffs, 'omitnan');
    stats.total_CI        = prctile(boot_total_diffs, [2.5, 97.5]);
    
    stats.receivers_diff_mean = mean(boot_reception_diffs, 'omitnan');
    stats.receivers_diff_var  = var(boot_reception_diffs, 'omitnan');
    stats.receivers_CI        = prctile(boot_reception_diffs, [2.5, 97.5]);
    
    stats.senders_diff_mean = mean(boot_sender_diffs, 'omitnan');
    stats.senders_diff_var  = var(boot_sender_diffs, 'omitnan');
    stats.senders_CI        = prctile(boot_sender_diffs, [2.5, 97.5]);
    
    stats.boot_distributions.total = boot_total_diffs;
    stats.boot_distributions.receivers = boot_reception_diffs;
    stats.boot_distributions.senders = boot_sender_diffs;
end