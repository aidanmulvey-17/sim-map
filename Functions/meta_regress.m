function mdl = meta_regress(reference_table)

g  = reference_table.g;
se = reference_table.var_g;
dAge = reference_table.SZ_ages - reference_table.HC_ages;
dSex = reference_table.SZ_sex_ratio - reference_table.HC_sex_ratio;
dPMI = reference_table.SZ_PMI - reference_table.HC_PMI;
Bank = reference_table.TissueBank;
Fixation = reference_table.FixMethod;

tbl = table(g, se, dAge, dSex, dPMI, Bank, Fixation,'VariableNames',{'g','SE','dAge','dSex','dPMI', 'Bank', 'Fixation'});
tbl = rmmissing(tbl);
tbl.Bank = categorical(tbl.Bank);
tbl.Fixation = categorical(tbl.Fixation);

w = 1 ./ tbl.SE.^2; % inverse-variance weights
X = [ones(height(tbl),1) tbl.dAge tbl.dSex tbl.dPMI, tbl.Bank, tbl.Fixation];
y = tbl.g;

% fitlm just for nice coefficient table
mdl = fitlm(tbl, 'g ~ dAge + dSex + dPMI + Bank + Fixation', 'Weights', w);
disp(mdl)

% Full model
beta_full = (X'*diag(w)*X) \ (X'*diag(w)*y);
SSE_full  = sum(w .* (y - X*beta_full).^2);

% Null model (intercept only)
X0 = ones(height(tbl),1);
beta0 = (X0'*diag(w)*X0) \ (X0'*diag(w)*y);
SSE_null = sum(w .* (y - X0*beta0).^2);

% Omnibus test (correct for weighted regression)
df_model = size(tbl, 2) - 2;
df_error = height(tbl) - (df_model + 1);
F_stat   = ((SSE_null - SSE_full)/df_model) / (SSE_full/df_error);
omnibus_p = 1 - fcdf(F_stat, df_model, df_error);

% Store everything
results = struct();
results.Coefficients = mdl.Coefficients;
results.k = height(tbl);
results.Adjusted_t_prime = mdl.Coefficients.Estimate(1);
results.Adjusted_SE      = mdl.Coefficients.SE(1);
results.Omnibus_F   = F_stat;
results.Omnibus_df1 = df_model;
results.Omnibus_df2 = df_error;
results.Omnibus_p   = omnibus_p;

% Display
disp(mdl);
fprintf('k = %d studies with complete data\n', height(tbl));
fprintf('Adjusted effect size: g = %.3f ± %.3f\n', results.Adjusted_t_prime, results.Adjusted_SE);
fprintf('Omnibus test of moderators: F(3,%d) = %.2f, p = %.3f\n', df_error, F_stat, omnibus_p);

fprintf('\n=== SUBGROUP ANALYSES ===\n');

g = reference_table.g;
se = reference_table.var_g;
w  = 1 ./ se.^2;

fix_code = reference_table.FixMethodCode;
bank_code = reference_table.TissueBankCode;

fix_levels = [1 2 3];  % 1=formalin, 2=PFA, 3=fresh-frozen
fix_names  = {'Formalin','PFA','Frozen'};

results.Fixation = struct();
for i = 1:length(fix_levels)
    idx = fix_code == fix_levels(i) & ~isnan(g) & ~isnan(se);
    if sum(idx) < 3
        continue;
    end

    eff = sum(g(idx).*w(idx)) / sum(w(idx)); % weighted mean of the g values
    se_eff = sqrt(1/sum(w(idx))); % standard error of the weighted mean

    results.Fixation.(fix_names{i}) = struct('k',sum(idx),'g',eff,'SE',se_eff, 'CI_low',eff-1.96*se_eff,'CI_high',eff+1.96*se_eff);

    fprintf('Fixation %-12s k = %2d   g = %.3f  (95%% CI %.3f to %.3f)\n', fix_names{i}, sum(idx), eff, eff-1.96*se_eff, eff+1.96*se_eff);
end

bank_levels = [5 7 3 2];  % 5=Allegheny, 7=Harvard, 3=Stanley, 2=NSW
bank_names  = {'Allegheny','Harvard','Stanley','NSW'};

results.Bank = struct();
for i = 1:length(bank_levels)
    idx = bank_code == bank_levels(i) & ~isnan(g) & ~isnan(se);
    if sum(idx) < 3
        continue;
    end

    eff = sum(g(idx).*w(idx)) / sum(w(idx)); % weighted mean of the g values
    se_eff = sqrt(1/sum(w(idx))); % standard error of the weighted mean

    results.Bank.(bank_names{i}) = struct('k',sum(idx),'g',eff,'SE',se_eff, 'CI_low',eff-1.96*se_eff,'CI_high',eff+1.96*se_eff);

    fprintf('Bank %-14s k = %2d   g = %.3f   (95%% CI %.3f to %.3f)\n', bank_names{i}, sum(idx), eff, eff-1.96*se_eff, eff+1.96*se_eff);
end

end