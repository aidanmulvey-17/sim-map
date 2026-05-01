function plotForest(ref_table, titleStr, removeOutlier, effect_name)
effect = ref_table.(effect_name);
if strcmp(removeOutlier, 'remove')
    outlier_indx = find(abs(effect) == max(abs(effect)), 1); % Ensure single index
    reference_table = ref_table([1:(outlier_indx-1), (outlier_indx+1):end], :);
else
    reference_table = ref_table;
end

groups = unique(reference_table.Group);
mean_g_vals = zeros(size(groups, 1), 2);

for jj = 1:length(groups)
    current_group = groups{jj};
    g_vals = reference_table.(effect_name)(ismember(reference_table.Group, current_group));
    
    n_g = length(g_vals);
    g_se = std(g_vals, 'omitnan') / sqrt(n_g);
    t_crit_group = tinv(1 - 0.05/2, n_g - 1); % t-distribution for group n
    
    mean_g_vals(jj, 1) = mean(g_vals, 'omitnan');
    mean_g_vals(jj, 2) = t_crit_group * g_se; % 95% CI Margin
end

degrees_of_freedom = reference_table.N_HC + reference_table.N_SZ - 2;
critical_t_value = tinv(1 - 0.05/2, degrees_of_freedom);
margin_of_error = critical_t_value .* sqrt(reference_table.var_g); 

lower_bound = reference_table.(effect_name) - margin_of_error;
upper_bound = reference_table.(effect_name) + margin_of_error;

num_studies = height(reference_table);
y_positions = 1:1:num_studies;

n_total = length(reference_table.(effect_name));
se_total = std(reference_table.(effect_name), 'omitnan') / sqrt(n_total);
t_crit_total = tinv(1 - 0.05/2, n_total - 1);

mean_g = mean(reference_table.(effect_name), 'omitnan');
SE_mean = t_crit_total * se_total; % Standardized to 95% CI
mean_y_position = 0;

figure;
hold on;
plot(reference_table.(effect_name), y_positions, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8); 
for i = 1:num_studies
    line([lower_bound(i), upper_bound(i)], [y_positions(i), y_positions(i)], 'Color', 'k', 'LineWidth', 1.5);
    line([lower_bound(i), lower_bound(i)], [y_positions(i) - 0.2, y_positions(i) + 0.2], 'Color', 'k', 'LineWidth', 1.5); % Top tick
    line([upper_bound(i), upper_bound(i)], [y_positions(i) - 0.2, y_positions(i) + 0.2], 'Color', 'k', 'LineWidth', 1.5); % Bottom tick
end

diamond_x = [mean_g - SE_mean, mean_g, mean_g + SE_mean, mean_g];
diamond_y = [mean_y_position, mean_y_position - 0.35, mean_y_position, mean_y_position + 0.35];
patch(diamond_x, diamond_y, 'r', 'EdgeColor', 'r', 'LineWidth', 1.5);

group_ys = -1:-1:-(size(mean_g_vals, 1));
for jj = 1:size(mean_g_vals, 1)
    g_m = mean_g_vals(jj, 1);
    g_e = mean_g_vals(jj, 2);
    group_y_pos = group_ys(jj);
    
    diamond_x = [g_m - g_e, g_m, g_m + g_e, g_m];
    diamond_y = [group_y_pos, group_y_pos - 0.35, group_y_pos, group_y_pos + 0.35];
    patch(diamond_x, diamond_y, 'b', 'EdgeColor', 'b', 'LineWidth', 1.5);
end

if any(ismember('Area', reference_table.Properties.VariableNames))
    area_label = num2str(reference_table.Area);
else
    area_label = reference_table.Group;
end

yticks([-(size(mean_g_vals, 1)):1:-1 mean_y_position y_positions]);
author_labels = append(cellstr(reference_table.Author), ' (', cellstr(reference_table.Abbv), '; ', cellstr(area_label), ')');
y_labels = [flipud(groups); 'Overall Mean'; author_labels];
yticklabels(y_labels);

xline(0, 'k--');
xlabel('Hedge''s g (with 95% CI)'); % Simplified to reflect consistent application
ylabel('Study / Mean');
title(['Forest Plot of Hedges g with Regional Means: ', titleStr]);

lims = 5;
xlim([-lims lims]);
ylim([-(size(mean_g_vals, 1)) - 1, num_studies + 2]);
grid on;
end