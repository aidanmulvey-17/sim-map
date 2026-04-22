function [statsTable, comparisonInfo] = compute_meta_stats(splitPattern, groupTitles, varargin)
    rng(42, 'twister');
    % Parse Optional Bootstrap Argument
    bootstrapIdx = find(strcmpi(varargin, 'Bootstrap'));
    if ~isempty(bootstrapIdx)
        numIterations = varargin{bootstrapIdx + 1};
        datasets = varargin(1:bootstrapIdx-1);
    else
        numIterations = 0;
        datasets = varargin;
    end
    numGroups = length(groupTitles);
    
    % --- Internal Pooling Helper ---
    function [mu, v_mu, n_total, tau2_avg, all_g, all_v] = pool_subset(data_cells)
        all_g = []; all_v = [];
        for j = 1:length(data_cells)
            data = data_cells{j};
            if istable(data)
                data = table2array(data);
            end
            if isempty(data)
                continue;
            end
            gi = data(:,1); vi = data(:,2);
            idx = ~isnan(gi) & ~isnan(vi);
            gi = gi(idx); vi = vi(idx);
            
            if any(vi == 0)
                medV = median(vi(vi > 0));
                if isnan(medV)
                    medV = 1e-4;
                end
                vi(vi == 0) = medV;
            end
            all_g = [all_g; gi]; all_v = [all_v; vi];
        end
        k = length(all_g);

        if k == 0
            mu = NaN;
            v_mu = NaN;
            n_total = 0;
            tau2_avg = NaN;
            return;
        end

        w_fe = 1 ./ all_v;
        mu_fe = sum(w_fe .* all_g) / sum(w_fe);
        Q = sum(w_fe .* (all_g - mu_fe).^2);
        sum_w = sum(w_fe);
        tau2 = max(0, (Q - (k-1)) / (sum_w - (sum(w_fe.^2)/sum_w)));
        w_rand = 1 ./ (all_v + tau2);
        mu = sum(w_rand .* all_g) / sum(w_rand);
        v_mu = 1 / sum(w_rand);
        n_total = k;
        tau2_avg = tau2;
    end

    % --- 1. Observed Stats ---
    groupResults = struct();
    currentIdx = 1;
    full_g_vec = [];
    full_v_vec = [];
    full_labels = [];
    for i = 1:numGroups
        nIn = splitPattern(i);
        subset = datasets(currentIdx : currentIdx + nIn - 1);
        [mu, v_mu, n, t2, rawG, rawV] = pool_subset(subset);
        groupResults(i).Mean = mu; 
        groupResults(i).Var = v_mu;
        groupResults(i).N = n;
        groupResults(i).Tau2 = t2;
        groupResults(i).RawData = rawG;

        full_g_vec = [full_g_vec; rawG];
        full_v_vec = [full_v_vec; rawV];
        full_labels = [full_labels; repmat(groupTitles(i), length(rawG), 1)];

        currentIdx = currentIdx + nIn;
    end
    
    anova_tbl = table(full_g_vec, categorical(full_labels), 'VariableNames', {'g', 'Group'});
    wls_mdl = fitlm(anova_tbl, 'g ~ Group', 'Weights', 1./full_v_vec);
    atab = anova(wls_mdl);
    
    comparisonInfo.anova_F = atab.F(1);
    comparisonInfo.anova_p = atab.pValue(1);
    comparisonInfo.anova_df = [atab.DF(1), atab.DF(2)];
    comparisonInfo.anova_table = atab;

    m_obs = [groupResults.Mean];
    v_obs = [groupResults.Var];
    p_obs_weights = 1 ./ v_obs;
    g_mu = sum(m_obs .* p_obs_weights) / sum(p_obs_weights);
    Qb_obs = sum(p_obs_weights .* (m_obs - g_mu).^2);

    % Observed Pairwise Z-Tests
    pairwise_p_obs = nan(numGroups);
    pairwise_z = nan(numGroups);
    for i = 1:numGroups
        for jj = i+1:numGroups
            diff_val = groupResults(i).Mean - groupResults(jj).Mean;
            se_diff = sqrt(groupResults(i).Var + groupResults(jj).Var);
            z = diff_val / se_diff;
            pairwise_p_obs(i,jj) = 2 * (1 - normcdf(abs(z)));
            pairwise_z(i, jj) = z;
        end
    end

    % --- 2. Bootstrapping ---
    boot_Means_Cell = cell(numGroups, 1);
    pairwise_p_boot = nan(numGroups);
    pairwise_diff_boot = cell(numGroups, numGroups);
    boot_CIs = cell(numGroups, numGroups);
    if numIterations > 0
        b_Qb = zeros(numIterations, 1);
        b_Means_Mat = zeros(numIterations, numGroups);

        for b = 1:numIterations
            resDS = cell(size(datasets));
            for d = 1:length(datasets)
                d_orig = datasets{d}; n_rows = size(d_orig, 1);
                resDS{d} = d_orig(randi(n_rows, [n_rows, 1]), :);
            end
            
            tM = zeros(1, numGroups); tV = zeros(1, numGroups);
            currIdx = 1;
            for i = 1:numGroups
                nIn = splitPattern(i);
                [m, v] = pool_subset(resDS(currIdx : currIdx + nIn - 1));
                tM(i) = m; tV(i) = v;
                currIdx = currIdx + nIn;
            end
            
            tP = 1 ./ tV;
            tG = sum(tM .* tP) / sum(tP);
            b_Qb(b) = sum(tP .* (tM - tG).^2);
            b_Means_Mat(b, :) = tM;
        end
        
        for i = 1:numGroups
            boot_Means_Cell{i} = b_Means_Mat(:, i);
            for jj = i+1:numGroups
                % Zero-crossing test: what % of differences cross zero?
                diffs = b_Means_Mat(:,i) - b_Means_Mat(:,jj);
                pairwise_diff_boot{i, jj} = diffs;
                % p-boot for difference is 2 * min(prop > 0, prop < 0)
                pairwise_p_boot(i,jj) = 2 * min(mean(diffs <= 0), mean(diffs >= 0));
                boot_CIs{i, jj} = [prctile(diffs, 2.5), prctile(diffs, 97.5)];
            end
        end

        comparisonInfo.boot_raw_Qb = b_Qb;
        comparisonInfo.boot_p = mean(b_Qb >= Qb_obs);
        b_CIs = [prctile(b_Means_Mat, 2.5); prctile(b_Means_Mat, 97.5)]';
    end

    % --- 3. Final Outputs ---
    statsTable = table(groupTitles(:), [groupResults.N]', [groupResults.Mean]', ...
        sqrt([groupResults.Var])', [groupResults.Tau2]', {groupResults.RawData}', ...
        'VariableNames', {'Names', 'N', 'WeightedMean', 'StdError', 'TauSquared', 'RawData'});
    
    statsTable.LowerCI = statsTable.WeightedMean - 1.96 * statsTable.StdError;
    statsTable.UpperCI = statsTable.WeightedMean + 1.96 * statsTable.StdError;
    
    if numIterations > 0
        statsTable.BootMean = cellfun(@(x) mean(x, 'omitnan'), boot_Means_Cell);
        statsTable.BootLowerCI = b_CIs(:,1);
        statsTable.BootUpperCI = b_CIs(:,2);
        statsTable.BootDistributions = boot_Means_Cell;
    end
    
    comparisonInfo.Qb = Qb_obs; 
    comparisonInfo.p = 1 - chi2cdf(Qb_obs, numGroups - 1);
    comparisonInfo.pairwise_p_obs = pairwise_p_obs;
    comparisonInfo.pairwise_z = pairwise_z;
    comparisonInfo.pairwise_p_boot = pairwise_p_boot;
    comparisonInfo.pairwise_diff_boot = pairwise_diff_boot;
    comparisonInfo.boot_CI = boot_CIs;
    comparisonInfo.iterations = numIterations;
end