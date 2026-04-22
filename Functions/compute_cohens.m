function effects_table = compute_cohens(input1, input2, comparison_label)

effects_table = table();

effect = meanEffectSize(input1, input2, Effect="cohen");
[~, p] = ttest2(input1, input2);

mean_a = mean(input1, 'omitnan');
mean_b = mean(input2, 'omitnan');

effects_table.Comparison = comparison_label;
effects_table.mean1 = mean_a;
effects_table.n1 = size(input1, 1);
effects_table.mean2 = mean_b;
effects_table.n2 = size(input2, 1);
effects_table.cohens_d = effect.Effect;
effects_table.CI = effect.ConfidenceIntervals;
effects_table.p_value = p;

end