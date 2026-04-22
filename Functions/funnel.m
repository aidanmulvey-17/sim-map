function [tscore_se, intercept, p_value_intercept, txtStr] = funnel(effect_size, N_A, N_B, titleLabel)

%Calculate variance of standard mean difference (SMD=hedge's g in our study) (Cochrane Handbook) 
variance = ((N_A + N_B) ./ (N_A .* N_B)) + ((effect_size.^2) ./ (2 .* (N_A + N_B)));

%Calculate the standard error of SMD, which is t-score (Cochrane Handbook)
tscore_se = sqrt(variance);

%standard_SE = tscore_se ./ max(tscore_se);
figure;
subplot(4, 1, 1:2)
scatter(effect_size, tscore_se, 'filled');
hold on;
xlabel('t-score');
ylabel('Standard Error');
% legend('Location', 'best');
ylim([0, 1]);
set(gca, 'yDir', 'reverse');
grid on;
xline(0, 'k--');
mean_tscore = mean(effect_size);
xline(mean_tscore, 'r', 'LineWidth', 2, 'DisplayName', 'Mean');
STD=std(effect_size);
%SEM = (std(tscore) / (sqrt(length(tscore))));
xlim([(mean_tscore - 2*STD)-0.2, (mean_tscore + 2*STD)+0.2]); 
xline(mean_tscore + 2*STD, 'r--','DisplayName', 'Mean ± 2*STD');
xline(mean_tscore - 2*STD, 'r--','HandleVisibility', 'off');

%Create manual lines in AI instead - they act as a visual aid 
%instead of linspace, use (mean (x1), max data (y2), mean-1.96*SE (x2),
%min data(y2)
y_top = min(ylim);
y_bottom = max(ylim);

x_left = mean_tscore - (1.96 * STD);
x_right = mean_tscore + (1.96 * STD);

plot([x_left, mean_tscore], [y_bottom, y_top], 'b:', 'LineWidth', 1.5, 'DisplayName', 'Approx. 95% CI Region');
plot([x_right, mean_tscore], [y_bottom, y_top], 'b:', 'LineWidth', 1.5, 'HandleVisibility', 'off');
legend('Location', 'eastoutside');

% se_for_funnel_lines = linspace(min(ylim), max(ylim), 100);
% upper_funnel_line = mean(tscore) + (1.96 * se_for_funnel_lines);
% lower_funnel_line = mean(tscore) - (1.96 * se_for_funnel_lines);
% plot(upper_funnel_line, se_for_funnel_lines, 'b:', 'LineWidth', 1.5, 'DisplayName', '95% CI Limits');
% plot(lower_funnel_line, se_for_funnel_lines, 'b:', 'LineWidth', 1.5, 'HandleVisibility', 'off');

%if sum(tscore < -20) > 0 || sum(tscore > 5) > 0|| sum(tscore_se > 1) > 0
   % hold on;
    %text(5, 1, 'Data point(s) exceeds bounds', 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
%end

standardized_d = effect_size ./ tscore_se;
inverse_se = 1./tscore_se;

tbl = table(inverse_se, standardized_d, 'VariableNames', {'Inverse_StandardError', 'Standardized_d'});
lm = fitlm(tbl, 'Standardized_d ~ Inverse_StandardError');

intercept = table2array(lm.Coefficients('(Intercept)', 'Estimate'));
p_value_intercept = table2array(lm.Coefficients('(Intercept)', 'pValue'));
txtStr = append('Egger''s for the B_0 parameter: ', num2str(intercept), ' p = ', num2str(p_value_intercept));
title(titleLabel, txtStr);

% fprintf('Egger''s Regression Intercept: %.4f\n', intercept);
% fprintf('P-value of the Intercept: %.4f\n', p_value_intercept);
subplot(4, 1, 3:4)
hold on;
plot(lm);
yline(0, 'k--')
ylim([-15, 15])
xlim([0, 8])
% figure;
% scatter(1./tscore_se, standardized_d)
% xlabel('1 / SE')
% ylabel('tscore / SE')
end