function ref_table = funnel_preprocess(areaIDs, all_tscores, authors_combined, areas_combined, N_HC, N_SZ, outliers_to_remove, cellType)
disp(append('--------------- Processing ', cellType, '---------------'));
min_tscore = min(all_tscores(:));
disp(['Minimum t-score (potential outlier): ', num2str(min_tscore)]);
% Find the index (or indices) of the minimum t-score
single_outlier_indx = find(all_tscores == min_tscore);
if ~isempty(single_outlier_indx)
if ~iscell(authors_combined)
        authors_combined = cellstr(authors_combined);
end
if ~iscell(areas_combined)
        areas_combined = cellstr(areas_combined);
end
    single_outlier_authors = authors_combined(single_outlier_indx);
    single_outlier_areas = areas_combined(single_outlier_indx);
    disp(['Author(s) of the single minimum outlier study/studies with t-score ', num2str(min_tscore), ': ', strjoin(single_outlier_authors, ', ')]);
    disp(['Area(s) associated with the single minimum outlier t-score: ', strjoin(single_outlier_areas, ', ')]); % Print the area(s)
else
    disp('No single minimum outlier found.');
end
% --- Prepare data for PV funnel plot ---
all_PV_IHC_tscores_col = all_tscores(:);
all_PV_IHC_N_HC_col = N_HC(:);
all_PV_IHC_N_SZ_col = N_SZ(:);
% --- Identify and Remove Multiple Outliers ---
all_PV_IHC_tscores_for_trimming = all_PV_IHC_tscores_col;
all_PV_IHC_N_HC_for_trimming = all_PV_IHC_N_HC_col;
all_PV_IHC_N_SZ_for_trimming = all_PV_IHC_N_SZ_col;
PV_IHC_authors_for_trimming = authors_combined;
PV_IHC_areas_for_trimming = areas_combined;
if outliers_to_remove > 0 && outliers_to_remove <= length(all_PV_IHC_tscores_col)
% Sort t-scores in ascending order to find the most negative
    [~, sorted_indices] = sort(all_PV_IHC_tscores_for_trimming);
% Identify the indices of the 'num_outliers_to_remove_PV' most negative t-scores
    multiple_outlier_indices_in_original_PV = sorted_indices(1:outliers_to_remove);
% Print the t-scores, authors, and areas of the multiple outliers being removed
    disp(['--- Removing ', num2str(outliers_to_remove), ' Most Negative Outliers ---']);
if ~iscell(PV_IHC_authors_for_trimming)
        PV_IHC_authors_for_trimming = cellstr(PV_IHC_authors_for_trimming);
end
if ~iscell(PV_IHC_areas_for_trimming)
        PV_IHC_areas_for_trimming = cellstr(PV_IHC_areas_for_trimming);
end
for i = 1:length(multiple_outlier_indices_in_original_PV)
        idx = multiple_outlier_indices_in_original_PV(i);
        disp(['Outlier ', num2str(i), ': t-score = ', num2str(all_PV_IHC_tscores_for_trimming(idx)), ...
', Author(s) = ', strjoin(PV_IHC_authors_for_trimming(idx), ', '), ...
', Area(s) = ', strjoin(PV_IHC_areas_for_trimming(idx), ', ')]);
end
    disp('-----------------------------------------------------');
% Create new variables by removing the multiple outliers
    all_PV_IHC_tscores_no_multiple_outliers = all_PV_IHC_tscores_for_trimming;
    all_PV_IHC_N_HC_no_multiple_outliers = all_PV_IHC_N_HC_for_trimming;
    all_PV_IHC_N_SZ_no_multiple_outliers = all_PV_IHC_N_SZ_for_trimming;
    PV_IHC_authors_no_multiple_outliers = PV_IHC_authors_for_trimming;
    PV_IHC_areas_no_multiple_outliers = PV_IHC_areas_for_trimming;
    all_PV_IHC_tscores_no_multiple_outliers(multiple_outlier_indices_in_original_PV) = [];
    all_PV_IHC_N_HC_no_multiple_outliers(multiple_outlier_indices_in_original_PV) = [];
    all_PV_IHC_N_SZ_no_multiple_outliers(multiple_outlier_indices_in_original_PV) = [];
    PV_IHC_authors_no_multiple_outliers(multiple_outlier_indices_in_original_PV) = [];
    PV_IHC_areas_no_multiple_outliers(multiple_outlier_indices_in_original_PV) = [];
    disp(['Removed ', num2str(outliers_to_remove), ' studies for ', cellType, '. New number of studies: ', num2str(length(all_PV_IHC_tscores_no_multiple_outliers))]);
else
    disp('No multiple outliers removed for ', cellType, '(num_outliers_to_remove is 0 or invalid).');
    all_PV_IHC_tscores_no_multiple_outliers = all_PV_IHC_tscores_col;
    all_PV_IHC_N_HC_no_multiple_outliers = all_PV_IHC_N_HC_col;
    all_PV_IHC_N_SZ_no_multiple_outliers = all_PV_IHC_N_SZ_col;
    PV_IHC_authors_no_multiple_outliers = authors_combined;
    PV_IHC_areas_no_multiple_outliers = areas_combined;
end
% --- Funnel plot for PV IHC - Combined areas (All Data) ---
[~, ~, ~, txtOut] = funnel(all_PV_IHC_tscores_col, all_PV_IHC_N_HC_col, all_PV_IHC_N_SZ_col, append(cellType, ' Combined (All Data)'));
datacursormode on;
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn', {@my_datacursor_function, areas_combined, authors_combined});
function output_txt = my_datacursor_function(obj, event_obj, areas_combined, authors_combined)
        index = get(event_obj, 'DataIndex');
        output_txt = {['Brain Area: ', areas_combined{index}], ['Author: ', authors_combined{index}], ...
            ['tscore: ', num2str(event_obj.Position(1))], ['SE: ', num2str(event_obj.Position(2))]};
end
[~, p] = ttest(all_PV_IHC_tscores_col);
disp(['Pre-correction: t''=', num2str(mean(all_PV_IHC_tscores_col)),' df=', num2str(length(all_PV_IHC_tscores_col)-1), ' p=', num2str(p)]);
disp(['Pre: ', txtOut])
%
% saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis/Figures/PubBias', append(cellType, ' Combined (All Data)'))
% --- Funnel plot for PV IHC - Combined areas (Multiple Outliers Removed) ---
[tscore_se_no_multiple_outliers_PV, ~, ~, txtOut] = funnel(all_PV_IHC_tscores_no_multiple_outliers, all_PV_IHC_N_HC_no_multiple_outliers, all_PV_IHC_N_SZ_no_multiple_outliers, [cellType, ' Combined (Top ', num2str(outliers_to_remove), ' Negative Outliers Removed)']);
datacursormode on;
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn', {@my_datacursor_function, areas_combined, authors_combined});
[~, p] = ttest(all_PV_IHC_tscores_no_multiple_outliers);
disp(['Post: ', txtOut])
disp(['Corrected: t''=', num2str(mean(all_PV_IHC_tscores_no_multiple_outliers)),' df=', num2str(length(all_PV_IHC_tscores_no_multiple_outliers)-1), ' p=', num2str(p)]);
% saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis/Figures/PubBias', append(cellType, ' Outliers Removed'))
% --- Identify Most and Least Precise Studies (PV - After Outlier Removal) ---
if ~isempty(tscore_se_no_multiple_outliers_PV)
    [min_se_PV, most_precise_idx_PV] = min(tscore_se_no_multiple_outliers_PV);
    [max_se_PV, least_precise_idx_PV] = max(tscore_se_no_multiple_outliers_PV);
    disp('--- Most and Least Precise Studies (After Outlier Removal) ---');
if ~iscell(PV_IHC_authors_no_multiple_outliers)
        PV_IHC_authors_no_multiple_outliers = cellstr(PV_IHC_authors_no_multiple_outliers);
end
if ~iscell(PV_IHC_areas_no_multiple_outliers)
        PV_IHC_areas_no_multiple_outliers = cellstr(PV_IHC_areas_no_multiple_outliers);
end
% Print details of the most precise study
    disp(append('Most Precise Study ', cellType, ':'));
    disp([' t-score: ', num2str(all_PV_IHC_tscores_no_multiple_outliers(most_precise_idx_PV))]);
    disp([' N_HC: ', num2str(all_PV_IHC_N_HC_no_multiple_outliers(most_precise_idx_PV))]);
    disp([' N_SZ: ', num2str(all_PV_IHC_N_SZ_no_multiple_outliers(most_precise_idx_PV))]);
    disp([' Standard Error: ', num2str(min_se_PV)]);
    disp([' Author(s): ', strjoin(PV_IHC_authors_no_multiple_outliers(most_precise_idx_PV), ', ')]);
    disp([' Area(s): ', strjoin(PV_IHC_areas_no_multiple_outliers(most_precise_idx_PV), ', ')]);
% Print details of the least precise study
    disp(append('Least Precise Study ', cellType, ':'));
    disp([' t-score: ', num2str(all_PV_IHC_tscores_no_multiple_outliers(least_precise_idx_PV))]);
    disp([' N_HC: ', num2str(all_PV_IHC_N_HC_no_multiple_outliers(least_precise_idx_PV))]);
    disp([' N_SZ: ', num2str(all_PV_IHC_N_SZ_no_multiple_outliers(least_precise_idx_PV))]);
    disp([' Standard Error: ', num2str(max_se_PV)]);
    disp([' Author(s): ', strjoin(PV_IHC_authors_no_multiple_outliers(least_precise_idx_PV), ', ')]);
    disp([' Area(s): ', strjoin(PV_IHC_areas_no_multiple_outliers(least_precise_idx_PV), ', ')]);
    disp('-------------------------------------------------------------');
else
    disp('Could not identify most/least precise studies as the dataset after outlier removal is empty.');
end
end