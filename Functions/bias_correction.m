function ref_table = bias_correction(data_table, remove_n, cellType)
% Input: data_table with columns g, N_HC, N_SZ, Author, Area (and optionally Abbv)
%        remove_n = number of most negative studies to trim (0 = none)

g = data_table.g;
nHC = data_table.N_HC;
nSZ = data_table.N_SZ;
authors = data_table.Author;
areas = data_table.Structure;

% Clean invalid rows
valid = ~isnan(g) & ~isnan(nHC) & ~isnan(nSZ) & nHC>0 & nSZ>0;
g = g(valid);
nHC = nHC(valid);
nSZ = nSZ(valid);
authors = authors(valid);
areas = areas(valid);

if length(g) < 2
    warning('Not enough valid studies for %s', cellType);
    ref_table = table();
    return;
end

% Compute SE for Hedges' g
se = zeros(size(g));
for i = 1:length(g)
    N = nHC(i) + nSZ(i);
    df = N - 2;
    J = 1 - 3/(4*df - 1);
    var_g = J^2 * (N/(nHC(i)*nSZ(i)) + g(i)^2/(2*N));
    se(i) = sqrt(var_g);
end
k_total = length(g);

%% Results BEFORE trimming
[pooled_before, p_before, egger_b0, egger_p0] = meta_egger(g, se);
subtitl_label_before = ['g=', num2str(pooled_before, '%.3f'), ', p(g)=', num2str(p_before, '%.3f'), '; B0=', num2str(egger_b0, '%.3f'), ', p(B0)=', num2str(egger_p0, '%.3f')];
plot_funnel(g, se, authors, areas, [cellType ' – All studies (k=' num2str(k_total) ')'], subtitl_label_before, pooled_before);

%% Results AFTER trimming
if remove_n > 0 && remove_n < k_total
    [~, idx] = sort(g);
    rm_idx = idx(1:remove_n);
    g_trim = g;
    g_trim(rm_idx) = [];
    se_trim = se;
    se_trim(rm_idx) = [];
    auth_trim = authors;
    auth_trim(rm_idx) = [];
    area_trim = areas;
    area_trim(rm_idx) = [];
    
    disp(['Removed ' num2str(remove_n) ' most negative ' cellType ' studies:']);
    for i = 1:remove_n
        disp([authors{rm_idx(i)} ' – ' areas{rm_idx(i)} ' (g=' num2str(g(rm_idx(i)), '%.3f') ')']);
    end
else
    g_trim = g;  se_trim = se;  auth_trim = authors;  area_trim = areas;
end

[pooled_after, p_after, egger_b, egger_p] = meta_egger(g_trim, se_trim);
subtitl_label_after = ['g=', num2str(pooled_after, '%.3f'), ', p(g)=', num2str(p_after, '%.3f'), '; B0=', num2str(egger_b, '%.3f'), ', p(B0)=', num2str(egger_p, '%.3f')];

if remove_n > 0
    plot_funnel(g_trim, se_trim, auth_trim, area_trim, ...
        [cellType ' – After trimming ' num2str(remove_n) ' extreme studies'], subtitl_label_after, pooled_after);
end

%% Final table
ref_table = table(...
    {cellType}, k_total, length(g_trim), remove_n, ...
    pooled_before, p_before, egger_b0, egger_p0, ...
    pooled_after,  p_after,  egger_b,  egger_p, ...
    'VariableNames', {'CellType','k_before','k_after','n_removed',...
    'g_before','p_before','Egger_B0','Egger_p0',...
    'g_after','p_after','Egger_B','Egger_p'});
end

% ————————————————————————————————
function plot_funnel(g, se, auth, area, titl, subtitl, pooled_g)
    figure; hold on; box on;

    y_max = max(se) * 1.1; % Add 10% headroom at the bottom
    
    % 2. Calculate the X-axis limits based on the triangle borders
    half_width = 1.96 * y_max;
    
    % Check if any data points fall outside this triangle; if so, expand to include them
    data_max_dist = max(abs(g - pooled_g));
    plot_half_width = max(half_width, data_max_dist) * 1.05;
    
    x_min = pooled_g - plot_half_width;
    x_max = pooled_g + plot_half_width;
    
    % 3. Draw the Triangle Borders (95% and intervals)
    se_range = [0, y_max];
    ci95_left  = pooled_g - 1.96 * se_range;
    ci95_right = pooled_g + 1.96 * se_range;
    plot(ci95_left,  se_range, '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2);
    plot(ci95_right, se_range, '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2);

    % 4. Plot the Studies
    scatter(g, se, 90, 'filled', 'MarkerFaceColor',[0 0.447 0.741], ...
        'MarkerEdgeColor','k', 'MarkerFaceAlpha',0.85);

    % 5. Vertical reference line at pooled mean
    line([pooled_g pooled_g], [0 y_max], 'Color', 'k', 'LineWidth', 1.5);

    % 6. Final Formatting
    set(gca, 'YDir', 'reverse');
    xlim([x_min x_max]);
    ylim([0 y_max]);
    
    xlabel('Hedges'' g', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Standard Error', 'FontWeight', 'bold', 'FontSize', 12);
    title(titl, subtitl, 'FontWeight', 'bold', 'FontSize', 14);

    % Clickable labels (Data Cursor)
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @(~,event) sprintf('%s\n%s\ng=%.3f\nSE=%.3f', ...
        auth{event.DataIndex}, area{event.DataIndex}, ...
        g(event.DataIndex), se(event.DataIndex)));
end

% ————————————————————————————————
function [pooled_g, p_g, egger_b, egger_p] = meta_egger(g, se)
vi = se.^2;
wi = 1./vi;
Q = sum(wi .* (g - sum(wi.*g)/sum(wi)).^2);
df = length(g)-1;
tau2 = max(0, (Q-df)/(sum(wi) - sum(wi.^2)/sum(wi)));
w = 1./(vi + tau2);
pooled_g = sum(w.*g)/sum(w);
p_g = 2*(1-normcdf(abs(pooled_g/sqrt(1/sum(w)))));

% Egger's test
X = [ones(size(se)) se];
beta = (X'*diag(w)*X) \ (X'*diag(w)*g);
V = inv(X'*diag(w)*X);
egger_b = beta(2);
egger_p = 2*(1-normcdf(abs(egger_b/sqrt(V(2,2)))));
end