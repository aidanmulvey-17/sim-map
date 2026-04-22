function [estimates, p_values, n] = mediatingFactors(reference_table, titleStr, plotModel)

p_values = zeros(1, 4); 
estimates = zeros(1, 4);
n = zeros(1, 4);
  
disp(['------ ', titleStr, ' ------']);

change_age = reference_table.SZ_ages - reference_table.HC_ages;
dataTab = table(reference_table.t_score(~isnan(change_age)), change_age(~isnan(change_age)), 'VariableNames', {'Tscore', 'Age'});
model = fitlm(dataTab, 'Tscore ~ Age');
p_values(1) = model.Coefficients.pValue(end);
estimates(1) = model.Coefficients.Estimate(2);
n(1) = model.NumObservations;
disp(model);
disp(['Age: p = ', num2str(model.Coefficients.pValue(end))]);
if strcmp(plotModel, 'plotmodel')
    figure;
    plot(model);
    hold on; xlabel(titleStr);
    saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis/Figures/MediatingFactors', append(titleStr, '_Age'))

end

change_sex_ratio = reference_table.SZ_sex_ratio - reference_table.HC_sex_ratio;
% [rho_sex, p_sex] = corr(reference_table.t_score, weighted_sex_ratio, 'Type', 'Spearman', 'rows', 'complete');
dataTab = table(reference_table.t_score(~isnan(change_sex_ratio)), change_sex_ratio(~isnan(change_sex_ratio)), 'VariableNames', {'Tscore', 'Sex'});
model = fitlm(dataTab, 'Tscore ~ Sex');
disp(model);
p_values(2) = model.Coefficients.pValue(end);
estimates(2) = model.Coefficients.Estimate(2);
n(2) = model.NumObservations;
disp(['Sex: p = ', num2str(model.Coefficients.pValue(end))]);
if strcmp(plotModel, 'plotmodel')
    figure;
    plot(model);
    hold on; xlabel(titleStr);
    xticks(0:2);
    xlim([0 2])
    text(0.8, -5, '<-- More Male', 'HorizontalAlignment','right', 'VerticalAlignment','bottom');
    text(1.2, -5, 'More Female -->', 'HorizontalAlignment','left', 'VerticalAlignment','bottom');
    saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis/Figures/MediatingFactors', append(titleStr, '_Sex'))
end

change_pH = reference_table.SZ_PH - reference_table.HC_PH;
% [rho_pH, p_pH] = corr(reference_table.t_score, weighted_pH, 'Type', 'Spearman', 'rows', 'complete');
dataTab = table(reference_table.t_score(~isnan(change_pH)), change_pH(~isnan(change_pH)), 'VariableNames', {'Tscore', 'pH'});
model = fitlm(dataTab, 'Tscore ~ pH');
disp(model);
p_values(3) = model.Coefficients.pValue(end);
estimates(3) = model.Coefficients.Estimate(2);
n(3) = model.NumObservations;
disp(['pH: p = ', num2str(model.Coefficients.pValue(end))]);
if strcmp(plotModel, 'plotmodel')
    figure;
    plot(model);
    hold on; xlabel(titleStr);
    saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis/Figures/MediatingFactors', append(titleStr, '_pH'))
end

change_PMI = reference_table.SZ_PMI - reference_table.HC_PMI;
% [rho_PMI, p_pmi] = corr(reference_table.t_score, weighted_PMI, 'Type', 'Spearman', 'rows', 'complete');
dataTab = table(reference_table.t_score(~isnan(change_PMI)), change_PMI(~isnan(change_PMI)), 'VariableNames', {'Tscore', 'PMI'});
model = fitlm(dataTab, 'Tscore ~ PMI');
disp(model);
p_values(4) = model.Coefficients.pValue(end);
estimates(4) = model.Coefficients.Estimate(2);
n(4) = model.NumObservations;
disp(['PMI: p = ', num2str(model.Coefficients.pValue(end))]);
if strcmp(plotModel, 'plotmodel')
    figure;
    plot(model);
    hold on; xlabel(titleStr);
    saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis/Figures/MediatingFactors', append(titleStr, '_PMI'))
end

% dataTab = table(reference_table.t_score, weighted_age, weighted_sex_ratio, weighted_pH, weighted_PMI, 'VariableNames', {'Tscore', 'Age', 'Sex', 'pH', 'PMI'});
% model = fitlm(dataTab, 'Tscore ~ Age + Sex + pH + PMI');
% disp(model);

x_age = change_age ./ max(change_age);
x_sex = change_sex_ratio ./ max(change_sex_ratio);
x_ph = change_pH ./ max(change_pH);
x_pmi = change_PMI ./ max(change_PMI);
y = reference_table.t_score;

% figure;
% scatter(x_age, y, 'r', 'filled', 'DisplayName', append('Age: rho = ', num2str(rho_age), ', p = ', num2str(p_age)));
% hold on;
% % p_age = polyfit(x_age, y, 1);
% % plot(x_age, polyval(p_age, x_age), 'r', 'LineWidth', 2);
% 
% scatter(x_sex, y, 'm', 'filled', 'DisplayName', append('Sex: rho = ', num2str(rho_sex), ', p = ', num2str(p_sex)));
% % p_sex = polyfit(x_sex, y, 1);
% % plot(x_sex, polyval(p_sex, x_sex), 'm', 'LineWidth', 2);
% 
% scatter(x_ph, y, 'b', 'filled', 'DisplayName', append('pH: rho = ', num2str(rho_pH), ', p = ', num2str(p_pH)));
% % p_ph = polyfit(x_ph, y, 1);
% % plot(x_ph, polyval(p_ph, x_ph), 'b', 'LineWidth', 2);
% 
% scatter(x_pmi, y, 'g', 'filled', 'DisplayName', append('PMI: rho = ', num2str(rho_PMI), ', p = ', num2str(p_pmi)));
% % p_pmi = polyfit(x_pmi, y, 1);
% % plot(x_pmi, polyval(p_pmi, x_pmi), 'g', 'LineWidth', 2);
% 
% legend('Location', 'best')
% xlabel('Normalized Factor')
% ylabel('t-score')
% title(titleStr);
% hold off;

end