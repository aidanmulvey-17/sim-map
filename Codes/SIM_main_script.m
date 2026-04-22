%% Schizophrenia Interneuron Metaanalysis (SIM) Main Analysis Script
% Raw_Data_Excel is a required folder contain all raw data
% MATLAB_R2024a is recommended for this script due to custom functions

% Data dictionary:

% All data tables contain:
    % Author (Author name(s), year)
    % Area # (e.g. 9, 45, etc.)
    % Area abbreviation (Abbv)
    % The structure (e.g. V1 is under Visual Cx)
    % The group (Cortex, PFC, Subcortex, Hippocampus)
    % The N subjects of HC and SZ
    % The Hedges g value
    % The sampling variance of g

% Before the underscores below, you can have:
    % PV_IHC, CB_IHC, CR_IHC, SST_IHC
    % PV_mRNA, CB_mRNA, CR_mRNA, SST_mRNA

% _laminar_table
    % Contains all the data from the laminar studies (L1_g, L1_var_g, etc.)
% _single_laminar_table
    % Contains all the data from the laminar studies, pooled into a single g and var_g
% _subcortical_table
    % Contains all the data from the subcortical studies (IHC ONLY!; See below)
% _nonlaminar_table
    % Contains all the data non-laminar studies
% For IHC, only PV and CB have _nonlaminar tables
    % For mRNA, all cell types have them, but they include subcortical data
% _dataframe
    % Contains all of the non-laminar (either combined across layers, subcortical, or non-laminar cortical) data
% _ref_table
    % Same info as _dataframe but with:
    % Method
    % Tissue Bank (and arbitrary codes)
    % Fixation (and arbitrary codes)
    % Age of HC and SZ
    % Sex Ratio (M/F) for HC and SZ
    % Brain pH for HC and SZ
    % Post-Mortem Interval (PMI) for HC and SZ
% _struct
    % Contains all of the _dataframe data but in the format of a struct, divided by brain structure
% _studies
    % Contains the individual studies; author, combined abbreviations, mean
    % g, pooled variance, and all other demographic information
%% Set Path information
folderLocation = setDir('GoPath', true);
warning ('off','all');
%% Background Information

areaSheet = importExcel('Paper_Collection_Bookkeeping', 'Areas_Included');
paperNums = areaSheet.Number;
paperAbbvs = areaSheet.Abbreviation;
paperAssigns = areaSheet.Assignment;
areaRanks = num2cell(areaSheet.Rank);
areaIdentification = [num2cell(paperNums) paperAbbvs paperAssigns areaRanks];

paperIDsheet = importExcel('Paper_Collection_Bookkeeping', 'Papers_Included');
paperID = paperIDsheet.Number;
paperID = paperID(~isnan(paperID));
paperMethod = paperIDsheet.Method(paperID);
methodTypes = unique(paperMethod);
IHC_paper_ID = paperID(strcmp(paperMethod, 'IHC'));
ICC_paper_ID = paperID(strcmp(paperMethod, 'ICC'));
ISH_paper_ID = paperID(strcmp(paperMethod, 'ISH'));
qPCR_paper_ID = paperID(strcmp(paperMethod, 'qPCR'));

subcortex_names = {'Amygdala', 'Midbrain', 'Thalamus', 'Striatum', 'Hypothalamus'};
subcortex_indices = ismember(paperAssigns, subcortex_names);
pfc_indices = ismember(paperAssigns, 'PFC');

areaGroup = paperAssigns;
areaGroup(subcortex_indices) = {'Subcortex'};
areaGroup(pfc_indices) = {'PFC'};
areaGroup(~ismember(areaGroup, {'PFC', 'Subcortex', 'Hippocampus'})) = {'Cortex'};

area_designations = table(paperNums, paperAbbvs, paperAssigns, areaGroup, areaRanks, 'VariableNames', {'Number', 'Abbreviation', 'Structure', 'Group', 'Rank'});
cell_types = ["PV", "CB", "CR", "SST"];
methods = ["IHC", "mRNA"];

%% IHC Data Grab
% import data from our IHC cortical data sheets
[raw_PV_HC_table, raw_PV_SZ_table] = importExcel('IHC_CORTEX', 'PV_HC', 'PV_SZ');
[raw_CB_HC_table, raw_CB_SZ_table] = importExcel('IHC_CORTEX', 'CB_HC', 'CB_SZ');
[raw_CR_HC_table, raw_CR_SZ_table] = importExcel('IHC_CORTEX', 'CR_HC', 'CR_SZ');
[raw_SST_HC_table, raw_SST_SZ_table] = importExcel('IHC_CORTEX', 'SST_HC', 'SST_SZ');
%% mRNA Data Grab
% import data from our mRNA data sheets
[raw_PV_HC_table_mRNA, raw_PV_SZ_table_mRNA] = importExcel('mRNA_data', 'PV_HC', 'PV_SZ');
[raw_CB_HC_table_mRNA, raw_CB_SZ_table_mRNA] = importExcel('mRNA_data', 'CB_HC', 'CB_SZ');
[raw_CR_HC_table_mRNA, raw_CR_SZ_table_mRNA] = importExcel('mRNA_data', 'CR_HC', 'CR_SZ');
[raw_SST_HC_table_mRNA, raw_SST_SZ_table_mRNA] = importExcel('mRNA_data', 'SST_HC', 'SST_SZ');
%% Get Laminar Info
layer_names = {'L1_g', 'L2_g', 'L3_g', 'L4_g', 'L5_g', 'L6_g'};
PV_IHC_laminar_table = get_laminar_info(raw_PV_HC_table, raw_PV_SZ_table, area_designations, "PV", "IHC");
CB_IHC_laminar_table = get_laminar_info(raw_CB_HC_table, raw_CB_SZ_table, area_designations, "CB", "IHC");
CR_IHC_laminar_table = get_laminar_info(raw_CR_HC_table, raw_CR_SZ_table, area_designations, "CR", "IHC");
SST_IHC_laminar_table = get_laminar_info(raw_SST_HC_table, raw_SST_SZ_table, area_designations, "SST", "IHC");

PV_mRNA_laminar_table = get_laminar_info(raw_PV_HC_table_mRNA, raw_PV_SZ_table_mRNA, area_designations, "PV", "mRNA");
CB_mRNA_laminar_table = get_laminar_info(raw_CB_HC_table_mRNA, raw_CB_SZ_table_mRNA, area_designations, "CB", "mRNA");
CR_mRNA_laminar_table = get_laminar_info(raw_CR_HC_table_mRNA, raw_CR_SZ_table_mRNA, area_designations, "CR", "mRNA");
SST_mRNA_laminar_table = get_laminar_info(raw_SST_HC_table_mRNA, raw_SST_SZ_table_mRNA, area_designations, "SST", "mRNA");
%% Get Single Effect Size from Laminar Info
PV_IHC_single_laminar_table = get_info_cross_laminar(raw_PV_HC_table, raw_PV_SZ_table, area_designations);
CB_IHC_single_laminar_table = get_info_cross_laminar(raw_CB_HC_table, raw_CB_SZ_table, area_designations);
CR_IHC_single_laminar_table = get_info_cross_laminar(raw_CR_HC_table, raw_CR_SZ_table, area_designations);
SST_IHC_single_laminar_table = get_info_cross_laminar(raw_SST_HC_table, raw_SST_SZ_table, area_designations);

PV_mRNA_single_laminar_table = get_info_cross_laminar(raw_PV_HC_table_mRNA, raw_PV_SZ_table_mRNA, area_designations);
CB_mRNA_single_laminar_table = get_info_cross_laminar(raw_CB_HC_table_mRNA, raw_CB_SZ_table_mRNA, area_designations);
CR_mRNA_single_laminar_table = get_info_cross_laminar(raw_CR_HC_table_mRNA, raw_CR_SZ_table_mRNA, area_designations);
SST_mRNA_single_laminar_table = get_info_cross_laminar(raw_SST_HC_table_mRNA, raw_SST_SZ_table_mRNA, area_designations);
%% Get subcortical info
[raw_subC_PV_table, raw_subC_CB_table, raw_subC_CR_table, raw_subC_SST_table] = importExcel('IHC_SubCortex', 'PV_Noncortical', 'CB_Noncortical', 'CR_Noncortical', 'SST_Noncortical');

PV_IHC_subcortical_table = get_nonlaminar_info(raw_subC_PV_table, area_designations);
CB_IHC_subcortical_table = get_nonlaminar_info(raw_subC_CB_table, area_designations);
CR_IHC_subcortical_table = get_nonlaminar_info(raw_subC_CR_table, area_designations);
SST_IHC_subcortical_table = get_nonlaminar_info(raw_subC_SST_table, area_designations);
%% Get Non-Laminar Cortical Info
[PV_IHC_NL, CB_IHC_NL] = importExcel('IHC_Cortex', 'PV_NL', 'CB_NL'); % IHC (cell density)

PV_IHC_nonlaminar_table = get_nonlaminar_info(PV_IHC_NL, area_designations);
CB_IHC_nonlaminar_table = get_nonlaminar_info(CB_IHC_NL, area_designations);

[PV_mRNA_NL, CB_mRNA_NL, CR_mRNA_NL, SST_mRNA_NL] = importExcel('mRNA_data', 'PV_NL', 'CB_NL', 'CR_NL', 'SST_NL'); % mRNA (cell expression)

PV_mRNA_nonlaminar_table = get_nonlaminar_info(PV_mRNA_NL, area_designations);
CB_mRNA_nonlaminar_table = get_nonlaminar_info(CB_mRNA_NL, area_designations);
CR_mRNA_nonlaminar_table = get_nonlaminar_info(CR_mRNA_NL, area_designations);
SST_mRNA_nonlaminar_table = get_nonlaminar_info(SST_mRNA_NL, area_designations);
%% Combine all non-laminar data
PV_IHC_dataframe = sortrows(vertcat(PV_IHC_single_laminar_table, PV_IHC_nonlaminar_table, PV_IHC_subcortical_table), 'Group');
CB_IHC_dataframe = sortrows(vertcat(CB_IHC_single_laminar_table, CB_IHC_nonlaminar_table, CB_IHC_subcortical_table), 'Group');
CR_IHC_dataframe = sortrows(vertcat(CR_IHC_single_laminar_table, CR_IHC_subcortical_table), 'Group');
SST_IHC_dataframe = sortrows(vertcat(SST_IHC_single_laminar_table, SST_IHC_subcortical_table), 'Group');

PV_mRNA_dataframe = sortrows(vertcat(PV_mRNA_single_laminar_table, PV_mRNA_nonlaminar_table), 'Group');
CB_mRNA_dataframe = sortrows(vertcat(CB_mRNA_single_laminar_table, CB_mRNA_nonlaminar_table), 'Group');
CR_mRNA_dataframe = sortrows(vertcat(CR_mRNA_single_laminar_table, CR_mRNA_nonlaminar_table), 'Group');
SST_mRNA_dataframe = sortrows(vertcat(SST_mRNA_single_laminar_table, SST_mRNA_nonlaminar_table), 'Group');
%% Full Info Table
table1 = importExcel('Table_1_Excel.xlsx', 'All Studies');
max_studies = height(table1);
num_ihc = sum(ismember(table1.Method, {'IHC', 'ICC'})) + 1;

PV_IHC_ref_table = getInfo(table1, PV_IHC_dataframe, "PV", "IHC", 1:num_ihc);
CB_IHC_ref_table = getInfo(table1, CB_IHC_dataframe, "CB", "IHC", 1:num_ihc);
CR_IHC_ref_table = getInfo(table1, CR_IHC_dataframe, "CR", "IHC", 1:num_ihc);
SST_IHC_ref_table = getInfo(table1, SST_IHC_dataframe, "SST", "IHC", 1:num_ihc);

PV_mRNA_ref_table = getInfo(table1, PV_mRNA_dataframe, "PV", "mRNA", num_ihc:max_studies);
CB_mRNA_ref_table = getInfo(table1, CB_mRNA_dataframe, "CB", "mRNA", num_ihc:max_studies);
CR_mRNA_ref_table = getInfo(table1, CR_mRNA_dataframe, "CR", "mRNA", num_ihc:max_studies);
SST_mRNA_ref_table = getInfo(table1, SST_mRNA_dataframe, "SST", "mRNA", num_ihc:max_studies);
%% Combine Data within Studies
PV_IHC_studies = combine_studies(PV_IHC_ref_table);
CB_IHC_studies = combine_studies(CB_IHC_ref_table);
CR_IHC_studies = combine_studies(CR_IHC_ref_table);
SST_IHC_studies = combine_studies(SST_IHC_ref_table);

PV_mRNA_studies = combine_studies(PV_mRNA_ref_table);
CB_mRNA_studies = combine_studies(CB_mRNA_ref_table);
CR_mRNA_studies = combine_studies(CR_mRNA_ref_table);
SST_mRNA_studies = combine_studies(SST_mRNA_ref_table);

IHC_study_table = [PV_IHC_studies; CB_IHC_studies; CR_IHC_studies; SST_IHC_studies];
mRNA_study_table = [PV_mRNA_studies; CB_mRNA_studies; CR_mRNA_studies; SST_mRNA_studies];

complete_study_table = [PV_IHC_studies; CB_IHC_studies; CR_IHC_studies; SST_IHC_studies; ...
    PV_mRNA_studies; CB_mRNA_studies; CR_mRNA_studies; SST_mRNA_studies];

[~, rank_indx] = ismember(complete_study_table.Structure, area_designations.Structure);
complete_study_table.Rank = cell2mat(area_designations.Rank(rank_indx));

complete_laminar_table = [PV_IHC_laminar_table; CB_IHC_laminar_table; CR_IHC_laminar_table; SST_IHC_laminar_table; ...
    PV_mRNA_laminar_table; CB_mRNA_laminar_table; CR_mRNA_laminar_table; SST_mRNA_laminar_table];

%% \\\\\ Layer Resolved Effects /////
% PV mRNA vs. SST mRNA PFC Layers
PV_mRNA_PFC_laminar_effects = table2array(PV_mRNA_laminar_table(ismember(PV_mRNA_laminar_table.Structure, 'PFC'), layer_names));
SST_mRNA_PFC_laminar_effects = table2array(SST_mRNA_laminar_table(ismember(SST_mRNA_laminar_table.Structure, 'PFC'), layer_names));
[~, PV_SST_mRNA_PFC_stats] = laminarBarPlot(PV_mRNA_PFC_laminar_effects, SST_mRNA_PFC_laminar_effects);

% Laminar Differences in PFC by Method (PV IHC vs. mRNA)
PV_IHC_PFC_laminar_effects = table2array(PV_IHC_laminar_table(ismember(PV_IHC_laminar_table.Structure, 'PFC'), layer_names));
[~, PV_IHC_mRNA_PFC_stats] = laminarBarPlot(PV_IHC_PFC_laminar_effects, PV_mRNA_PFC_laminar_effects);

% Laminar Differences in PV IHC in PFC vs. Entorhinal (acknowledge EC n limitation)
PV_IHC_EC_laminar_effects = table2array(PV_IHC_laminar_table(ismember(PV_IHC_laminar_table.Structure, 'EC'), layer_names));
[~, PV_IHC_PFC_EC_stats] = laminarBarPlot(PV_IHC_PFC_laminar_effects, PV_IHC_EC_laminar_effects);

% Laminar Differences in PFC by cell type (IHC)
CB_IHC_PFC_laminar_effects = table2array(CB_IHC_laminar_table(ismember(CB_IHC_laminar_table.Structure, 'PFC'), layer_names));
CR_IHC_PFC_laminar_effects = table2array(CR_IHC_laminar_table(ismember(CR_IHC_laminar_table.Structure, 'PFC'), layer_names));
[~, PV_CB_CR_IHC_PFC_stats] = laminarBarPlot(PV_IHC_PFC_laminar_effects, CB_IHC_PFC_laminar_effects, CR_IHC_PFC_laminar_effects);

% -- Stats --
raw_laminar_data_cells = {PV_IHC_PFC_laminar_effects, CB_IHC_PFC_laminar_effects, CR_IHC_PFC_laminar_effects, PV_IHC_EC_laminar_effects, PV_mRNA_PFC_laminar_effects, SST_mRNA_PFC_laminar_effects};
row_labels = {'PV_IHC_PFC', 'CB_IHC_PFC', 'CR_IHC_PFC', 'PV_IHC_EC', 'PV_mRNA_PFC', 'SST_mRNA_PFC'};

numExps = length(raw_laminar_data_cells);
numLayers = size(raw_laminar_data_cells{1}, 2);

means_mat = zeros(numExps, numLayers);
n_mat = zeros(numExps, numLayers);
p_mat = zeros(numExps, numLayers);

for i = 1:numExps
    current_data = raw_laminar_data_cells{i};

    for j = 1:numLayers
        layer_data = current_data(:, j);
        layer_data = layer_data(~isnan(layer_data)); % Remove NaNs

        means_mat(i, j) = mean(layer_data);
        n_mat(i, j)     = length(layer_data);

        if length(layer_data) > 1
            [~, p] = ttest(layer_data);
            p_mat(i, j) = p;
        else
            p_mat(i, j) = NaN;
        end
    end
end

colNames = [];
for j = 1:numLayers
    colNames = [colNames, {sprintf('L%d_Mean', j), sprintf('L%d_n', j), sprintf('L%d_pVal', j)}];
end

combined_data = [];
for j = 1:numLayers
    combined_data = [combined_data, means_mat(:,j), n_mat(:,j), p_mat(:,j)];
end

layers_effects_table = array2table(combined_data, 'RowNames', row_labels, 'VariableNames', colNames); % descriptive table of effects across layers
%% \\\\\ Structure Level Differences ///// We then move on to the structure-level differences
% Bar Plots for IHC Structures
PV_IHC_struct = effect_size_to_struct(PV_IHC_dataframe);
CB_IHC_struct = effect_size_to_struct(CB_IHC_dataframe);
CR_IHC_struct = effect_size_to_struct(CR_IHC_dataframe);
SST_IHC_struct = effect_size_to_struct(SST_IHC_dataframe);

PV_IHC_2_stats = struct2barh(PV_IHC_struct, areaIdentification, 'PV Effect Size IHC');
CB_IHC_2_stats = struct2barh(CB_IHC_struct, areaIdentification, 'CB Effect Size IHC');
CR_IHC_2_stats = struct2barh(CR_IHC_struct, areaIdentification, 'CR Effect Size IHC');
SST_IHC_2_stats = struct2barh(SST_IHC_struct, areaIdentification, 'SST Effect Size IHC');

% Effect Size Across Cell Types in PFC (IHC)
effect_PVCB = compute_cohens(PV_IHC_struct.PFC_effect(:, 2), CB_IHC_struct.PFC_effect(:, 2), {'IHC PFC: PV vs. CB'});
effect_PVCR = compute_cohens(PV_IHC_struct.PFC_effect(:, 2), CR_IHC_struct.PFC_effect(:, 2), {'IHC PFC: PV vs. CR'});
effect_CBCR = compute_cohens(CB_IHC_struct.PFC_effect(:, 2), CR_IHC_struct.PFC_effect(:, 2), {'IHC PFC: CB vs. CR'});

% Effect Size Across Cell Types in Hippocampus (IHC)
effect_PVCB_IHC_Hipp = compute_cohens(PV_IHC_struct.Hippocampus_effect(:, 2), CB_IHC_struct.Hippocampus_effect(:, 2), {'IHC Hipp: PV vs. CB'});
effect_PVCR_IHC_Hipp = compute_cohens(PV_IHC_struct.Hippocampus_effect(:, 2), CR_IHC_struct.Hippocampus_effect(:, 2), {'IHC Hipp: PV vs. CR'});
effect_PVSST_IHC_Hipp = compute_cohens(PV_IHC_struct.Hippocampus_effect(:, 2), SST_IHC_struct.Hippocampus_effect(:, 2), {'IHC Hipp: PV vs. SST'});
effect_CBCR_IHC_Hipp = compute_cohens(CB_IHC_struct.Hippocampus_effect(:, 2), CR_IHC_struct.Hippocampus_effect(:, 2), {'IHC Hipp: CB vs. CR'});
effect_CBSST_IHC_Hipp = compute_cohens(CB_IHC_struct.Hippocampus_effect(:, 2), SST_IHC_struct.Hippocampus_effect(:, 2), {'IHC Hipp: CB vs. SST'});
effect_SSTCR_IHC_Hipp = compute_cohens(SST_IHC_struct.Hippocampus_effect(:, 2), CR_IHC_struct.Hippocampus_effect(:, 2), {'IHC Hipp: SST vs. CR'});

% Bar Plots for mRNA Structures
PV_mRNA_struct = effect_size_to_struct(PV_mRNA_dataframe);
CB_mRNA_struct = effect_size_to_struct(CB_mRNA_dataframe);
CR_mRNA_struct = effect_size_to_struct(CR_mRNA_dataframe);
SST_mRNA_struct = effect_size_to_struct(SST_mRNA_dataframe);

PV_mRNA_2_stats = struct2barh(PV_mRNA_struct, areaIdentification, 'PV Effect Size mRNA');
CB_mRNA_2_stats = struct2barh(CB_mRNA_struct, areaIdentification, 'CB Effect Size mRNA');
CR_mRNA_2_stats = struct2barh(CR_mRNA_struct, areaIdentification, 'CR Effect Size mRNA');
SST_mRNA_2_stats = struct2barh(SST_mRNA_struct, areaIdentification, 'SST Effect Size mRNA');

% Effect Size Across Cell Types in PFC (mRNA)
effect_PVCB_mRNA = compute_cohens(PV_mRNA_struct.PFC_effect(:, 2), CB_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: PV vs. CB'});
effect_PVCR_mRNA = compute_cohens(PV_mRNA_struct.PFC_effect(:, 2), CR_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: PV vs. CR'});
effect_PVSST_mRNA = compute_cohens(PV_mRNA_struct.PFC_effect(:, 2), SST_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: PV vs. SST'});
effect_CBCR_mRNA = compute_cohens(CB_mRNA_struct.PFC_effect(:, 2), CR_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: CB vs. CR'});
effect_CBSST_mRNA = compute_cohens(CB_mRNA_struct.PFC_effect(:, 2), SST_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: CB vs. SST'});
effect_SSTCR_mRNA = compute_cohens(SST_mRNA_struct.PFC_effect(:, 2), CR_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: SST vs. CR'});

% Effect Size Across Cell Types in Hippocampus (mRNA)
effect_PVSST_mRNA_hipp = compute_cohens(PV_mRNA_struct.Hippocampus_effect(:, 2), SST_mRNA_struct.Hippocampus_effect(:, 2), {'mRNA Hipp: PV vs. SST'});

% Group Level Comparisons
cell_type_PFC_cohens = vertcat(effect_PVCB, effect_PVCR, effect_CBCR, effect_PVCB_mRNA, effect_PVCR_mRNA, effect_PVSST_mRNA, effect_CBCR_mRNA, effect_SSTCR_mRNA, ...
    effect_PVCB_IHC_Hipp, effect_PVCR_IHC_Hipp, effect_PVSST_IHC_Hipp, effect_CBCR_IHC_Hipp, effect_CBSST_IHC_Hipp, effect_SSTCR_IHC_Hipp, effect_PVSST_mRNA_hipp);
% there is insufficient data to perform this type of analysis in other structures
%% \\\\\ Group Level Differences ///// Compare PFC (frontal) to hippocampus, subcortex, non-frontal cortex
groups = {"PFC", "Hippocampus", "Cortex", "Subcortex"};
% Cohen's Effect Size Comparisons IHC
user_dataframe = PV_IHC_dataframe;
effect_PV_IHC_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'IHC PV: PFC vs. Cortex'});
effect_PV_IHC_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC PV: PFC vs. Hipp'});
effect_PV_IHC_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC PV: Cortex vs. Hipp'});

user_dataframe = CB_IHC_dataframe;
effect_CB_IHC_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'IHC CB: PFC vs. Cortex'});
effect_CB_IHC_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC CB: PFC vs. Hipp'});
effect_CB_IHC_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC CB: Cortex vs. Hipp'});

user_dataframe = CR_IHC_dataframe;
effect_CR_IHC_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'IHC CR: PFC vs. Cortex'});
effect_CR_IHC_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC CR: PFC vs. Hipp'});
effect_CR_IHC_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC CR: Cortex vs. Hipp'});

user_dataframe = SST_IHC_dataframe;
effect_SST_IHC_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'IHC SST: Cortex vs. Hipp'});

group_level_comps_IHC = vertcat(effect_PV_IHC_PFC_CX, effect_PV_IHC_PFC_HIPP, effect_PV_IHC_CX_HIPP, ...
    effect_CB_IHC_PFC_CX, effect_CB_IHC_PFC_HIPP, effect_CB_IHC_CX_HIPP, ...
    effect_CR_IHC_PFC_CX, effect_CR_IHC_PFC_HIPP, effect_CR_IHC_CX_HIPP, ...
    effect_SST_IHC_CX_HIPP);

% Cohen's Effect Size Comparisons mRNA
user_dataframe = PV_mRNA_dataframe;
effect_PV_mRNA_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'mRNA PV: PFC vs. Cortex'});
effect_PV_mRNA_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA PV: PFC vs. Hipp'});
effect_PV_mRNA_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA PV: Cortex vs. Hipp'});

user_dataframe = CB_mRNA_dataframe;
effect_CB_mRNA_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'mRNA CB: PFC vs. Cortex'});
effect_CB_mRNA_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA CB: PFC vs. Hipp'});
effect_CB_mRNA_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA CB: Cortex vs. Hipp'});

user_dataframe = CR_mRNA_dataframe;
effect_CR_mRNA_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'mRNA CR: PFC vs. Cortex'});
effect_CR_mRNA_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA CR: PFC vs. Hipp'});

user_dataframe = SST_mRNA_dataframe;
effect_SST_mRNA_PFC_CX = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), {'mRNA SST: PFC vs. Cortex'});
effect_SST_mRNA_PFC_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'PFC')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA SST: PFC vs. Hipp'});
effect_SST_mRNA_CX_HIPP = compute_cohens(user_dataframe.g(ismember(user_dataframe.Group, 'Cortex')), user_dataframe.g(ismember(user_dataframe.Group, 'Hippocampus')), {'mRNA SST: Cortex vs. Hipp'});

group_level_comps_mRNA = vertcat(effect_PV_mRNA_PFC_CX, effect_PV_mRNA_PFC_HIPP, effect_PV_mRNA_CX_HIPP, ...
    effect_CB_mRNA_PFC_CX, effect_CB_mRNA_PFC_HIPP, effect_CB_mRNA_CX_HIPP, ...
    effect_CR_mRNA_PFC_CX, effect_CR_mRNA_PFC_HIPP, ...
    effect_SST_mRNA_PFC_CX, effect_SST_mRNA_PFC_HIPP, effect_SST_mRNA_CX_HIPP);

% ------------------------------------ Mean Effect in PFC and Hippocampus ------------------------------------
all_structs = {PV_IHC_struct, CB_IHC_struct, CR_IHC_struct, SST_IHC_struct, PV_mRNA_struct, CB_mRNA_struct, CR_mRNA_struct, SST_mRNA_struct};
struct_labels = {'PV IHC', 'CB IHC', 'CR IHC', 'SST IHC', 'PV mRNA', 'CB mRNA', 'CR mRNA', 'SST mRNA'};

PFC_results_table = table();
m = 1;
for jj = 1:size(struct_labels, 2)

    current_struct = all_structs{jj};

    if isfield(current_struct, 'PFC_effect')
        variable = current_struct.PFC_effect(:, 2);
        mean_effect = mean(variable);
        [~, p, ~, stats] = ttest(variable);

        PFC_results_table.Description(m) = struct_labels(jj);
        PFC_results_table.Hedges(m) = mean_effect;
        PFC_results_table.t_stat(m) = stats.tstat;
        PFC_results_table.df(m) = stats.df;
        PFC_results_table.p_value(m) = p;
        m = m+1;
    end

end

Hippocampus_results_table = table();
m = 1;
for jj = 1:size(struct_labels, 2)

    current_struct = all_structs{jj};

    if isfield(current_struct, 'Hippocampus_effect')
        variable = current_struct.Hippocampus_effect(:, 2);
        mean_effect = mean(variable);
        [~, p, ~, stats] = ttest(variable);

        Hippocampus_results_table.Description(m) = struct_labels(jj);
        Hippocampus_results_table.Hedges(m) = mean_effect;
        Hippocampus_results_table.t_stat(m) = stats.tstat;
        Hippocampus_results_table.df(m) = stats.df;
        Hippocampus_results_table.p_value(m) = p;
        m = m+1;
    end

end

% ----- Compare IHC and mRNA in Different Groups
all_ihc_dataframes = {PV_IHC_dataframe, CB_IHC_dataframe, CR_IHC_dataframe, SST_IHC_dataframe};
all_mrna_dataframes = {PV_mRNA_dataframe, CB_mRNA_dataframe, CR_mRNA_dataframe, SST_mRNA_dataframe};
results_cell = cell(length(groups), size(all_ihc_dataframes, 2));
for gg = 1:size(groups, 2)
    current_group = groups{gg};
    for df = 1:size(all_ihc_dataframes, 2)

        ihc_user_dataframe = all_ihc_dataframes{df};
        mrna_user_dataframe = all_mrna_dataframes{df};

        ihc_df = ihc_user_dataframe.g(strcmp(ihc_user_dataframe.Group, current_group));
        mrna_df = mrna_user_dataframe.g(strcmp(mrna_user_dataframe.Group, current_group));

        comparison_label = append(cell_types(df), " IHC vs mRNA: ", current_group);

        if numel(ihc_df) > 1 && numel(mrna_df) > 1
            stats = compute_cohens(ihc_df, mrna_df, comparison_label);
            results_cell{gg, df} = stats;
        end
    end
end
ihc_mrna_stats = vertcat(results_cell{:});

y_data = ihc_mrna_stats.cohens_d;
num_rows = height(ihc_mrna_stats);
x_indices = 1:num_rows;

ci_values = ihc_mrna_stats.CI;
ci_lower = ci_values(:, 1);
ci_upper = ci_values(:, 2);

neg_error = y_data - ci_lower;
pos_error = ci_upper - y_data;

figure;
scatter(y_data, x_indices, 60, 'filled', 'MarkerFaceColor', 'k');
hold on;
eh = errorbar(y_data, x_indices, neg_error, pos_error, 'horizontal', 'Color', 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
yticks(x_indices);
yticklabels(ihc_mrna_stats.Comparison);
xlabel('Cohen''s d (Effect Size)');
title('IHC vs mRNA Effect Sizes');
xlim([-3 3]);
ylim([0.5 num_rows + 0.5]);
xline(0, 'k-', 'LineWidth', 1.2);
set(gca, 'YDir', 'reverse', 'Box', 'off');
text(min(xlim)+0.2, num_rows + 0.25, '\leftarrow IHC More Affected', 'FontWeight', 'bold', 'Color', 'r');
text(max(xlim)-0.2, num_rows + 0.25, 'mRNA More Affected \rightarrow', 'HorizontalAlignment', 'right', 'FontWeight', 'bold', 'Color', 'b');

%% Forest Plot Analysis
plotForest(PV_IHC_dataframe, 'PV IHC', 'remove', 'g'); % removes 1 outlier for visualization
plotForest(CB_IHC_dataframe, 'CB IHC', 'dontremove', 'g');
plotForest(CR_IHC_dataframe, 'CR IHC', 'dontremove', 'g');
plotForest(SST_IHC_dataframe, 'SST IHC', 'dontremove', 'g');

plotForest(PV_mRNA_dataframe, 'PV mRNA', 'dontremove', 'g');
plotForest(CB_mRNA_dataframe, 'CB mRNA', 'dontremove', 'g');
plotForest(CR_mRNA_dataframe, 'CR mRNA', 'dontremove', 'g');
plotForest(SST_mRNA_dataframe, 'SST mRNA', 'dontremove', 'g');
%% ---------------- Supplemental Analyses ----------------
% Publication Bias
fprintf("\nBeginning Publication Bias Testing...\n");
% --- PV  ---
PV_IHC_bias_table = bias_correction(PV_IHC_studies, 0, 'PV IHC');
PV_mRNA_bias_table = bias_correction(PV_mRNA_studies, 0, 'PV mRNA');
% --- CB  ---
CB_IHC_bias_table = bias_correction(CB_IHC_studies, 0, 'CB IHC');
CB_mRNA_bias_table = bias_correction(CB_mRNA_studies, 0, 'CB mRNA');
% --- CR  ---
CR_IHC_bias_table = bias_correction(CR_IHC_studies, 0, 'CR IHC');
CR_mRNA_bias_table = bias_correction(CR_mRNA_studies, 0, 'CR mRNA');
% --- SST  ---
SST_IHC_bias_table = bias_correction(SST_IHC_studies, 0, 'SST IHC');
SST_mRNA_bias_table = bias_correction(SST_mRNA_studies, 0, 'SST mRNA'); % Remove 2

% for SST mRNA bias:
i = 0;
while SST_mRNA_bias_table.Egger_p < 0.05
    i = i + 1;
    SST_mRNA_bias_table = bias_correction(SST_mRNA_studies, i, 'SST mRNA');
end

publication_bias = vertcat(PV_IHC_bias_table, CB_IHC_bias_table, CR_IHC_bias_table, SST_IHC_bias_table, PV_mRNA_bias_table, CB_mRNA_bias_table, CR_mRNA_bias_table, SST_mRNA_bias_table);
% ------------------------------------------------------------------------

% Heterogeneity Analysis (Random-Effects Model)
input_tables = {PV_IHC_studies; PV_mRNA_studies; CB_IHC_studies; CB_mRNA_studies; CR_IHC_studies; CR_mRNA_studies; SST_IHC_studies; SST_mRNA_studies};
i_squared_table = table();
i_squared_table.Label(:) = ["PV IHC"; "PV mRNA"; "CB IHC"; "CB mRNA"; "CR IHC"; "CR mRNA"; "SST IHC"; "SST mRNA"];

input_structures = ["PFC", "Hippocampus"];

for it = 1:size(input_tables)
    input_table = input_tables{it};

    for ss = 1:size(input_structures, 2)
        input_structure = input_structures(ss);

        ref = input_table(ismember(input_table.Structure, input_structure), :);

        yi = ref.g;
        vi = ref.var_g;
        k(ss) = height(ref);

        w_fixed = 1 ./ vi;

        Q = sum(w_fixed .* (yi - sum(w_fixed.*yi)/sum(w_fixed)).^2);
        df = k(ss) - 1;
        p_Q = 1 - chi2cdf(Q, df);

        I2(ss) = max(0, (Q - df)/Q)*100;

    end
    i_squared_table.PFC(it) = I2(1);
    i_squared_table.PFC_n(it) = k(1);

    i_squared_table.Hpcps(it) = I2(2);
    i_squared_table.Hpcps_n(it) = k(2);
end
%% ---------------- Demographics Meta Regression ----------------
input_table = complete_study_table;
g = input_table.g;
var_g = input_table.var_g;
dAge = input_table.SZ_ages - input_table.HC_ages;
dSex = input_table.SZ_sex_ratio - input_table.HC_sex_ratio;
dPMI = input_table.SZ_PMI - input_table.HC_PMI;
dPH = input_table.SZ_PH - input_table.HC_PH;
total_N = (input_table.N_HC + input_table.N_SZ);
Area = input_table.Structure;
MethodType = input_table.MethodType;
Bank = input_table.TissueBank;
Fixation = input_table.FixMethod;
Cell = input_table.CellType;
Author = input_table.Author;

regression_tbl = table(g, var_g, dAge, dSex, dPMI, dPH, total_N, Bank, Fixation, MethodType, Cell, Author, Area, ...
    'VariableNames',{'g','var_g','dAge','dSex','dPMI', 'dPH', 'N', 'Bank', 'Fixation', 'MethodType', 'Cell', 'Author', 'Area'});

regression_tbl.Bank = categorical(lower(string(regression_tbl.Bank)));
regression_tbl.Area = categorical(lower(string(regression_tbl.Area)));
regression_tbl.Fixation = categorical(lower(string(regression_tbl.Fixation)));
regression_tbl.MethodType = categorical(lower(string(regression_tbl.MethodType)));
regression_tbl.Cell = categorical(lower(string(regression_tbl.Cell)));
regression_tbl.Author = categorical(string(regression_tbl.Author));
regression_tbl.Cell = reordercats(regression_tbl.Cell, {'cr', 'pv', 'cb', 'sst'});

regression_tbl = rmmissing(regression_tbl);

w = 1 ./ regression_tbl.var_g;

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>Demographics LMM</strong>\n");
fprintf("---------------------------------------------------\n");

formula_mixed = 'g ~ dAge + dSex + dPMI + dPH + N + Cell + (1|Bank) + (1|Fixation) + (1|Author)';
meta_regression = fitlme(regression_tbl, formula_mixed, 'Weights', w);
disp(meta_regression);
stats = anova(meta_regression);
disp(stats);
fprintf("---------------------------------------------------\n");

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>Parsimonious Demographics LMM</strong>\n");
fprintf("---------------------------------------------------\n");
formula_reduced = 'g ~ dAge + dPMI + N + Cell + (1|Author)';

meta_regression_reduced = fitlme(regression_tbl, formula_reduced, 'Weights', w);
disp(meta_regression_reduced);
stats = anova(meta_regression_reduced);
disp(stats);
fprintf("---------------------------------------------------\n");

regr_name = 'Meta_Regression_Reduced.csv';
fid = fopen(regr_name, 'w');
fprintf(fid, 'MODEL FORMULA: %s\n\n', char(meta_regression_reduced.Formula));
fclose(fid);
writetable(dataset2table(anova(meta_regression_reduced)), regr_name, 'WriteMode', 'append', 'WriteVariableNames', true);
fid = fopen(regr_name, 'a'); fprintf(fid, '\nCOEFFICIENTS / POST-HOC:\n'); fclose(fid);
writetable(dataset2table(meta_regression_reduced.Coefficients), regr_name, 'WriteMode', 'append', 'WriteVariableNames', true);
%% ---------------- Exploratory Analyses -----------------------
% mRNA Sub-Method (FISH, ISH, qPCR, etc.) Regression
g_mrna  = mRNA_study_table.g;
var_mrna = mRNA_study_table.var_g;
Method = mRNA_study_table.Method;
Bank = mRNA_study_table.TissueBank;
Author = mRNA_study_table.Author;

tbl = table(g_mrna, var_mrna, Method, Bank, Author, 'VariableNames',{'g','Var', 'Method', 'Bank', 'Author'});
tbl.Method = categorical(lower(string(tbl.Method)));
tbl.Bank = categorical(lower(string(tbl.Bank)));
tbl.Author = categorical(string(tbl.Author));
tbl = rmmissing(tbl);

weights = 1 ./ tbl.Var; 

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>Regression on mRNA Method Types</strong>\n");
fprintf("---------------------------------------------------\n");
mrna_mdl = fitlme(tbl, 'g ~ Method + (1|Author) + (1|Bank)', 'Weights', weights);
disp(mrna_mdl)
stats = anova(mrna_mdl);
disp(stats);
fprintf("---------------------------------------------------\n");

% Cell Type - Method Interaction Regression
input_table = complete_study_table;
g  = input_table.g;
var_g = input_table.var_g;
cell_type = input_table.CellType;
method = input_table.MethodType;
Bank = input_table.TissueBank;
Author = input_table.Author;

tbl = table(g, var_g, cell_type, method, Bank, Author, 'VariableNames', {'g', 'Var', 'cell_type', 'method', 'Bank', 'Author'});
tbl.cell_type = categorical(lower(string(tbl.cell_type)));
tbl.method = categorical(lower(string(tbl.method)));
tbl.Bank = categorical(lower(string(tbl.Bank)));
tbl.Author = categorical(string(tbl.Author));

tbl = rmmissing(tbl);
weights = 1 ./ tbl.Var;

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>Regression on Cell-Method Interaction </strong>\n");
fprintf("---------------------------------------------------\n");
brain_area_regression_mdl = fitlme(tbl, 'g ~ cell_type * method + (1|Author)', 'Weights', weights);
disp(brain_area_regression_mdl)

stats = anova(brain_area_regression_mdl);
disp(stats);
fprintf("---------------------------------------------------\n");

% SST mRNA Identifying Heterogeneity
input_table = SST_mRNA_studies;
g = input_table.g;
var_g = input_table.var_g;
dAge = input_table.SZ_ages - input_table.HC_ages;
dSex = input_table.SZ_sex_ratio - input_table.HC_sex_ratio;
dPMI = input_table.SZ_PMI - input_table.HC_PMI;
dPH = input_table.SZ_PH - input_table.HC_PH;
total_N = input_table.N_HC + input_table.N_SZ;
Area = input_table.Structure;
Bank = input_table.TissueBankCode;
Fixation = input_table.FixMethod;
Author = input_table.Author;

regression_tbl = table(g, var_g, dAge, dSex, dPMI, dPH, total_N, Bank, Fixation, Author, Area, ...
    'VariableNames',{'g','var_g','dAge','dSex','dPMI', 'dPH', 'total_N', 'Bank', 'Fixation', 'Author', 'Area'});

regression_tbl.Bank = categorical(lower(string(regression_tbl.Bank)));
regression_tbl.Area = categorical(lower(string(regression_tbl.Area)));
regression_tbl.Fixation = categorical(lower(string(regression_tbl.Fixation)));
regression_tbl.Author = categorical(string(regression_tbl.Author));

regression_tbl = rmmissing(regression_tbl);

w = 1 ./ regression_tbl.var_g;

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>SST mRNA Bias Regression</strong>\n");
fprintf("---------------------------------------------------\n");

formula_fixed = 'g ~ dAge + dPMI + dPH + total_N + (1|Bank) + (1|Fixation) + (1|Author)';
sst_mrna_regression = fitlme(regression_tbl, formula_fixed, 'Weights', w);
disp(sst_mrna_regression);
sst_mrna_stats = anova(sst_mrna_regression);
disp(sst_mrna_stats);
fprintf("---------------------------------------------------\n");

%% Characterization of Studies
ihc_labels = {'IHC', 'ICC'};
mrna_labels = {'qPCR', 'ISH', 'FISH', 'OD', 'ISH, qPCR'};

rowsToRemove = ismissing(table1.Author) | ismissing(table1.Year);
cleaned_table = table1(~rowsToRemove, :);

is_ihc = contains(cleaned_table.Method, ihc_labels, 'IgnoreCase', true);
is_mrna = contains(cleaned_table.Method, mrna_labels, 'IgnoreCase', true);

all_unique_studies = unique(cleaned_table(:, {'Author', 'Year'}), 'rows');
total_unique_count = height(all_unique_studies);

ihc_unique_studies = unique(cleaned_table(is_ihc, {'Author', 'Year'}), 'rows');
total_ihc_unique = height(ihc_unique_studies);

mrna_unique_studies = unique(cleaned_table(is_mrna, {'Author', 'Year'}), 'rows');
total_mrna_unique = height(mrna_unique_studies);

target_cells = {'PV', 'CB', 'CR', 'SST'};
ihc_counts = zeros(length(target_cells), 1);
mrna_counts = zeros(length(target_cells), 1);
combined_unique_counts = zeros(length(target_cells), 1);

for i = 1:length(target_cells)
    marker = target_cells{i};
    
    is_marker = contains(cleaned_table.('Cell Type'), marker, 'IgnoreCase', true);
    
    ihc_marker_data = cleaned_table(is_marker & is_ihc, {'Author', 'Year'});
    ihc_counts(i) = height(unique(ihc_marker_data, 'rows'));
    
    mrna_marker_data = cleaned_table(is_marker & is_mrna, {'Author', 'Year'});
    mrna_counts(i) = height(unique(mrna_marker_data, 'rows'));
    
    combined_marker_data = cleaned_table(is_marker & (is_ihc | is_mrna), {'Author', 'Year'});
    combined_unique_counts(i) = height(unique(combined_marker_data, 'rows'));
end

CellTypeBreakdown = table(target_cells', ihc_counts, mrna_counts, combined_unique_counts, ...
    'VariableNames', {'CellType', 'IHC_Studies', 'mRNA_Studies', 'Total_Unique_Studies'});

dual_method_studies = intersect(ihc_unique_studies, mrna_unique_studies, 'rows');
num_dual = height(dual_method_studies);

is_laminar_row = contains(cleaned_table.Laminar, 'Y', 'IgnoreCase', true);
laminar_studies = unique(cleaned_table(is_laminar_row, {'Author', 'Year'}), 'rows');
num_laminar = height(laminar_studies);

non_laminar_studies = setdiff(all_unique_studies, laminar_studies, 'rows');
num_non_laminar = height(non_laminar_studies);

fprintf('------------------------------------------------------------\n');
fprintf('STUDY SUMMARY\n');
fprintf('------------------------------------------------------------\n');
fprintf('Total Unique Publications: %d\n', total_unique_count);
fprintf('Total IHC Publications:    %d\n', total_ihc_unique);
fprintf('Total mRNA Publications:   %d\n\n', total_mrna_unique);

if num_dual > 0
    fprintf('Found %d study(ies) using BOTH IHC and mRNA methods:\n', num_dual);
    disp(dual_method_studies);
end

fprintf('Laminar Studies:     %d\n', num_laminar);
fprintf('Non-Laminar Studies: %d\n\n', num_non_laminar);

fprintf('Cell Type Breakdown (Unique Study Counts):\n');
disp(CellTypeBreakdown);
fprintf('------------------------------------------------------------\n');
%% ------------ Bottom-Up vs. Top-Down Hypothesis Testing ---------- %%
bu_td_colors = [0.8 0.2 0.2; ... % Red for TD
    0.2 0.4 0.8]; % Blue for BU

H_func = @(groups, regr, hidden_sum, label) arrayfun(@(n) strcmp(n,'(Intercept)') + (ismember(erase(n,label),groups)/numel(groups)) - ...
    (ismember(hidden_sum,groups)*(startsWith(n,label)/numel(groups))), regr.CoefficientNames);
    % contrast vector generator, constructs a row vector (H) that, when
    % multiplied by the model coefficients (beta), calculates the average predicted value (EMM) for the specified group

build_H_vector = @(groups, coef_names, hidden_ref, prefix) arrayfun(@(name) ...
    (ismember(erase(name, prefix), groups) / numel(groups)) - ...
    (ismember(hidden_ref, groups) * (startsWith(name, prefix) / numel(groups))), ...
    coef_names);
    % similar to H_func but computed the difference in EMMs (dEMM)
%% Add Bank and Fix to laminar table
% this is done in get_info, but needs to be added for laminar studies
num_ref_rows = height(complete_laminar_table);
matching_indices = NaN(num_ref_rows, 1);

for i = 1:num_ref_rows
    ref_author = complete_laminar_table.Author{i};
    if contains(ref_author, '(')
        ref_author = extractBefore(ref_author, ' (');
    end
    ref_region = num2str(complete_laminar_table.Abbv{i});
    ref_cell_type = complete_laminar_table.CellType{i};

    for j = 1:num_ref_rows
        table1_author = append(table1.Author(j), ', ', num2str(table1.Year(j)));
        table1_region = table1.Area{j};
        table1_cell_types = table1.('Cell Type'){j};

        % Check for author and brain region match
        author_match = strcmpi(ref_author, table1_author);
        region_match = contains(table1_region, ref_region);
        cell_match = contains(table1_cell_types, ref_cell_type);

        if author_match && cell_match
            matching_indices(i) = j;
            break;
        end
    end
end

indices = matching_indices;
complete_laminar_table.TissueBank = table1.("Tissue Obtained")(matching_indices);
complete_laminar_table.FixMethod = table1.("Fixation Method")(matching_indices);

laminar_study_table = combine_studies_multi_layer(complete_laminar_table);

%% ---------------- Hypothesis Test Regression (H1: Layers) ----------------
laminar_stacked_g = stack(laminar_study_table, {'L1_g', 'L2_g', 'L3_g', 'L4_g', 'L5_g', 'L6_g'}, ...
    'NewDataVariableName', 'g', 'IndexVariableName', 'Layer');
laminar_stacked_var = stack(laminar_study_table, {'L1_var_g', 'L2_var_g', 'L3_var_g', 'L4_var_g', 'L5_var_g', 'L6_var_g'}, ...
    'NewDataVariableName', 'var_g', 'IndexVariableName', 'Layer_dummy');

laminar_regr_tbl = laminar_stacked_g;
laminar_regr_tbl.var_g = laminar_stacked_var.var_g; 
laminar_regr_tbl.Layer = categorical(strrep(string(laminar_regr_tbl.Layer), '_g', ''));
laminar_regr_tbl = rmmissing(laminar_regr_tbl(:, {'g', 'var_g', 'Layer', 'Author', 'Structure', 'CellType', 'MethodType', 'TissueBank', 'N_HC', 'N_SZ'}));
laminar_regr_tbl((laminar_regr_tbl.g == 0) & (laminar_regr_tbl.var_g == 0), :) = []; % remove rows with g = 0 (artifacts)
laminar_regr_tbl.total_N = (laminar_regr_tbl.N_HC + laminar_regr_tbl.N_SZ);
laminar_regr_tbl.total_N = laminar_regr_tbl.total_N - mean(laminar_regr_tbl.total_N, 'omitnan');

laminar_regr_tbl.MethodType = categorical(lower(string(laminar_regr_tbl.MethodType)));
laminar_regr_tbl.Area = categorical(lower(string(laminar_regr_tbl.Structure)));
laminar_regr_tbl.Cell = categorical(lower(string(laminar_regr_tbl.CellType)));
laminar_regr_tbl.Cell = reordercats(laminar_regr_tbl.Cell, {'cr', 'pv', 'cb', 'sst'});
laminar_regr_tbl.Author = categorical(string(laminar_regr_tbl.Author));
laminar_regr_tbl.Bank = categorical(string(laminar_regr_tbl.TissueBank));
laminar_regr_tbl = rmmissing(laminar_regr_tbl);

w = 1 ./ laminar_regr_tbl.var_g;

fprintf("\n---------------------------------------------------\n");
fprintf("<strong> Layer Hypothesis Regression Test </strong>\n");
fprintf("---------------------------------------------------\n");
lam_formula = 'g ~ Layer + Cell + Area + total_N + MethodType + (1|Author) + (1|Bank)';
laminar_regression = fitlme(laminar_regr_tbl, lam_formula, 'Weights', w, 'DummyVarCoding', 'effects');
disp(laminar_regression);
fprintf("\n<strong> Layer Hypothesis ANOVA </strong>\n");
lam_stats = anova(laminar_regression);
disp(lam_stats)
fprintf("---------------------------------------------------\n");

coef_table_lam = laminar_regression.Coefficients;
beta_values_lam = coef_table_lam.Estimate;
coef_names_lam = coef_table_lam.Name;

est_L1 = coef_table_lam.Estimate(strcmp(coef_names_lam, 'Layer_L1'));
est_L2 = coef_table_lam.Estimate(strcmp(coef_names_lam, 'Layer_L2'));
est_L3 = coef_table_lam.Estimate(strcmp(coef_names_lam, 'Layer_L3'));
est_L4 = coef_table_lam.Estimate(strcmp(coef_names_lam, 'Layer_L4'));
est_L5 = coef_table_lam.Estimate(strcmp(coef_names_lam, 'Layer_L5'));
est_L6 = -(est_L1 + est_L2 + est_L3 + est_L4 + est_L5);

intercept = coef_table_lam.Estimate(strcmp(coef_names_lam, '(Intercept)'));
means_lam = intercept + [est_L1; est_L2; est_L3; est_L4; est_L5; est_L6];

figure;
plot(1:6, means_lam, 'o-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
grid on;
yline(intercept, 'k', 'Grand Mean', 'LineWidth', 1.5)
xticks(1:6);
xticklabels({'L1', 'L2', 'L3', 'L4', 'L5', 'L6'});
xlabel('Cortical Layer');
ylabel('Estimated Marginal Mean g');
title('Adjusted Laminar Vulnerability Profile');

intercept = laminar_regression.Coefficients.Estimate(1);
beta_values = laminar_regression.Coefficients.Estimate;
coef_names = laminar_regression.CoefficientNames;
cov_matrix = laminar_regression.CoefficientCovariance;
dfe = laminar_regression.DFE;
crit_t = tinv(0.975, dfe);

figure;
sgtitle('Adjusted Laminar Vulnerability Profile');
all_vars = {'Cell', 'Layer','Area'};
for jj = 1:size(all_vars, 2)
    targetVar = all_vars{jj};
    all_possible = unique(laminar_regr_tbl.(targetVar), 'stable');
    
    idx = find(contains(coef_names, [targetVar '_']));
    visible_labels = erase(coef_names(idx), [targetVar '_']);
    hidden_label = setdiff(all_possible, visible_labels, 'stable');
    
    H_hidden_beta = zeros(1, numel(coef_names));
    H_hidden_beta(idx) = -1; 
    
    H_hidden_emm = H_hidden_beta;
    H_hidden_emm(1) = 1; % Include Intercept for EMM
    
    hidden_est = H_hidden_beta * beta_values; % This is the beta deviation
    hidden_emm = H_hidden_emm * beta_values; % This is the absolute g
    
    hidden_se_emm = sqrt(H_hidden_emm * cov_matrix * H_hidden_emm');
    hidden_p_vs_mean = coefTest(laminar_regression, H_hidden_beta); 
    hidden_p_vs_zero = coefTest(laminar_regression, H_hidden_emm); 
    
    visible_ests_beta = beta_values(idx);
    visible_emms = zeros(numel(idx), 1);
    visible_ses_emm = zeros(numel(idx), 1);
    visible_p_vs_mean = zeros(numel(idx), 1);
    visible_p_vs_zero = zeros(numel(idx), 1);
    
    for k = 1:numel(idx)
        H_vis_beta = zeros(1, numel(coef_names));
        H_vis_beta(idx(k)) = 1;
        
        H_vis_emm = H_vis_beta;
        H_vis_emm(1) = 1; % Intercept + Beta
        
        visible_emms(k) = H_vis_emm * beta_values;
        visible_ses_emm(k) = sqrt(H_vis_emm * cov_matrix * H_vis_emm');
        visible_p_vs_mean(k) = coefTest(laminar_regression, H_vis_beta);
        visible_p_vs_zero(k) = coefTest(laminar_regression, H_vis_emm);
    end
    
    final_labels = [visible_labels(:); hidden_label(:)];
    final_emms   = [visible_emms(:); hidden_emm];
    final_ses    = [visible_ses_emm(:); hidden_se_emm];
    final_p_mean = [visible_p_vs_mean(:); hidden_p_vs_mean];
    final_p_zero = [visible_p_vs_zero(:); hidden_p_vs_zero];
    
    % 95% CI calculation (using EMM standard error)
    err_bar = final_ses * crit_t;
    low_CI = final_emms - err_bar;
    hi_CI = final_emms + err_bar;
    CI = [low_CI, hi_CI];

    H1_EMM_table = table(final_labels, final_emms, CI, final_p_zero, 'VariableNames', {'Label' 'EMM', '95% CI' 'p(0)'});
    disp(H1_EMM_table);
    
    subplot(1, size(all_vars, 2), jj);
    hold on;
    % Plotting the EMMs with 95% CI
    errorbar(1:numel(final_emms), final_emms, err_bar, err_bar, ...
        'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8], 'LineWidth', 1.5, 'CapSize', 8);
    
    for i = 1:numel(final_emms)
        % RED STAR:
        if final_p_mean(i) < 0.05
            text(i, final_emms(i) + err_bar(i) + 0.1, '*', 'Color', 'r', ...
                'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
        % BLACK STAR:
        if final_p_zero(i) < 0.05
            text(i, final_emms(i) - err_bar(i) - 0.1, '*', 'Color', 'k', ...
                'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
    end
    
    xticks(1:numel(final_emms));
    xticklabels(final_labels);
    xtickangle(45);
    ylabel('EMM (Hedges'' g)');
    title(['Effect of ', targetVar]);
    yline(0, 'k-', 'No Effect', 'LineWidth', 1.2); % Zero line for Black Stars
    yline(intercept, 'k--', 'Grand Mean', 'Alpha', 0.5); % Intercept for Red Stars
    grid on;
    ylim([min(final_emms - err_bar) - 0.4, max(final_emms + err_bar) + 0.4]);
end
%% ---------------- H1: Layers Planned Linear Contrasts ----------------
coef_names = laminar_regression.CoefficientNames;
all_layers = unique(laminar_regr_tbl.Layer);
visible_layers = erase(coef_names(contains(coef_names, 'Layer_')), 'Layer_');
hidden_layer = setdiff(all_layers, visible_layers);

% Absolute Deficit vs. Zero (EMMs)
H_BU_ALL   = H_func({'L2', 'L3', 'L4'}, laminar_regression, hidden_layer, 'Layer_');
H_BU_INPUT = H_func({'L4'}, laminar_regression, hidden_layer, 'Layer_');
H_TD_INPUT = H_func({'L1'}, laminar_regression, hidden_layer, 'Layer_');

fprintf('\n--- Absolute Deficit vs. Zero (EMMs) ---\n');
fprintf('BU ALL (L2/3/4): Mean = %.3f, p = %.3f\n', H_BU_ALL * laminar_regression.Coefficients.Estimate, coefTest(laminar_regression, H_BU_ALL));
fprintf('BU INPUT (L4): Mean = %.3f, p = %.3f\n', H_BU_INPUT * laminar_regression.Coefficients.Estimate, coefTest(laminar_regression, H_BU_INPUT));
fprintf('TD INPUT (L1): Mean = %.3f, p = %.3f\n', H_TD_INPUT * laminar_regression.Coefficients.Estimate, coefTest(laminar_regression, H_TD_INPUT));

comparisons = {
    'All (L2/3/4 v. L1/5/6)', {'L2', 'L3', 'L4'}, {'L1', 'L5', 'L6'};
    'Input Layers (L4 v. L1)', {'L4'}, {'L1'};
    'Output Layers (L2/3 v. L5/6)', {'L2', 'L3'}, {'L5', 'L6'}
};

results_layer = struct('Comparison', {}, 'Estimate', {}, 'SE', {}, 'PValue', {}, 'LowerCI', {}, 'UpperCI', {});
for i = 1:size(comparisons, 1)

    H = build_H_vector(comparisons{i,2}, coef_names, hidden_layer, 'Layer_') - ...
        build_H_vector(comparisons{i,3}, coef_names, hidden_layer, 'Layer_'); % compute the difference between groups within comparisons
    
    pVal = coefTest(laminar_regression, H);
    est = H * laminar_regression.Coefficients.Estimate;
    se = sqrt(H * laminar_regression.CoefficientCovariance * H');
    
    results_layer(i).Comparison = comparisons{i, 1};
    results_layer(i).Estimate = est;
    results_layer(i).SE = se;
    results_layer(i).PValue = pVal;
    results_layer(i).LowerCI = est - (1.96 * se);
    results_layer(i).UpperCI = est + (1.96 * se);
end

resultsTable_lam = struct2table(results_layer);
figure; hold on;
for i = 1:size(resultsTable_lam, 1)
    line([resultsTable_lam.LowerCI(i), resultsTable_lam.UpperCI(i)], [i, i], 'Color', [0.2 0.2 0.2], 'LineWidth', 2);
    plot(resultsTable_lam.Estimate(i), i, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
    if resultsTable_lam.PValue(i) < 0.05
        text(resultsTable_lam.Estimate(i), i+0.05, '*', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    text(resultsTable_lam.UpperCI(i) + 0.05, i, sprintf('p = %.3f', resultsTable_lam.PValue(i)), 'FontWeight', 'bold');
    
    g1 = laminar_regr_tbl.g(ismember(laminar_regr_tbl.Layer, comparisons{i, 2}));
    g2 = laminar_regr_tbl.g(ismember(laminar_regr_tbl.Layer, comparisons{i, 3}));
    scatter(g1, i + 0.15, 20, 'o', 'MarkerFaceColor', bu_td_colors(2, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
    scatter(g2, i - 0.15, 20, 'o', 'MarkerFaceColor', bu_td_colors(1, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
end
xline(0, 'k--', 'LineWidth', 2);
set(gca, 'YTick', 1:size(resultsTable_lam, 1), 'YTickLabel', resultsTable_lam.Comparison, 'FontSize', 11);
xlabel('Contrast Estimate (Difference in Hedges'' g)');
title('Laminar Contrasts');

%% ---------------- Hypothesis Test Regression (H2/3, Cells and Areas) ----------------
input_table = complete_study_table;
g = input_table.g;
var_g = input_table.var_g;
Area = input_table.Structure;
MethodType = input_table.MethodType;
total_N = (input_table.N_HC + input_table.N_SZ);
Bank = input_table.TissueBank;
Cell = input_table.CellType;
Author = input_table.Author;

cell_area_regr_tbl = table(g, var_g, Bank, total_N, MethodType, Cell, Area, Author, ...
    'VariableNames',{'g','var_g', 'Bank', 'total_N', 'MethodType', 'Cell', 'Area', 'Author'});

cell_area_regr_tbl.Bank = categorical(lower(string(cell_area_regr_tbl.Bank)));
cell_area_regr_tbl.MethodType = categorical(lower(string(cell_area_regr_tbl.MethodType)));
cell_area_regr_tbl.Area = categorical(lower(string(cell_area_regr_tbl.Area)));
cell_area_regr_tbl.Cell = categorical(lower(string(cell_area_regr_tbl.Cell)));
cell_area_regr_tbl.Cell = reordercats(cell_area_regr_tbl.Cell, {'cr', 'pv', 'cb', 'sst'});
cell_area_regr_tbl.Author = categorical(string(cell_area_regr_tbl.Author));

cell_area_regr_tbl = rmmissing(cell_area_regr_tbl);
w = 1 ./ cell_area_regr_tbl.var_g;

fprintf("\n---------------------------------------------------\n");
fprintf("<strong> Cell and Area Hypothesis Regression Test </strong>\n");
fprintf("---------------------------------------------------\n");
hyp_formula = 'g ~ Cell + Area + total_N + MethodType + (1|Bank) + (1|Author)';
cell_area_regression = fitlme(cell_area_regr_tbl, hyp_formula, 'Weights', w, 'DummyVarCoding', 'effects');
disp(cell_area_regression);
cell_area_stats = anova(cell_area_regression);
disp(cell_area_stats);

coef_table_cell_area = cell_area_regression.Coefficients;
beta_values_H12 = coef_table_cell_area.Estimate;
coef_names_H12 = coef_table_cell_area.Name;
num_area_coefficients = sum(contains(coef_names_H12, 'Area'));

area_EMMs = struct();
all_vars = {'Cell', 'Area'};
intercept = cell_area_regression.Coefficients.Estimate(1);
beta_values = cell_area_regression.Coefficients.Estimate;
coef_names = cell_area_regression.CoefficientNames;
cov_matrix = cell_area_regression.CoefficientCovariance;
dfe = cell_area_regression.DFE;
crit_t = tinv(0.975, dfe); % calculate critical value for 95% CI

figure;
sgtitle('Adjusted Vulnerability Profile (Absolute vs. Relative Deficits)');

for jj = 1:size(all_vars, 2)
    targetVar = all_vars{jj};
    all_possible = unique(cell_area_regr_tbl.(targetVar), 'stable');
    
    idx = find(contains(coef_names, [targetVar '_']));
    visible_labels = erase(coef_names(idx), [targetVar '_']);
    hidden_label = setdiff(all_possible, visible_labels, 'stable');
    
    H_hidden_beta = zeros(1, numel(coef_names));
    H_hidden_beta(idx) = -1;
    H_hidden_emm = H_hidden_beta;
    H_hidden_emm(1) = 1; % Include Intercept
    
    hidden_emm_val = H_hidden_emm * beta_values;
    hidden_se_emm = sqrt(H_hidden_emm * cov_matrix * H_hidden_emm');
    
    hidden_p_vs_mean = coefTest(cell_area_regression, H_hidden_beta); 
    hidden_p_vs_zero = coefTest(cell_area_regression, H_hidden_emm); 
    
    visible_emms = zeros(numel(idx), 1);
    visible_ses_emm = zeros(numel(idx), 1);
    visible_p_vs_mean = zeros(numel(idx), 1);
    visible_p_vs_zero = zeros(numel(idx), 1);
    
    for k = 1:numel(idx)
        H_vis_beta = zeros(1, numel(coef_names));
        H_vis_beta(idx(k)) = 1;
        
        H_vis_emm = H_vis_beta;
        H_vis_emm(1) = 1; % Include Intercept
        
        visible_emms(k) = H_vis_emm * beta_values;
        visible_ses_emm(k) = sqrt(H_vis_emm * cov_matrix * H_vis_emm');
        
        visible_p_vs_mean(k) = coefTest(cell_area_regression, H_vis_beta);
        visible_p_vs_zero(k) = coefTest(cell_area_regression, H_vis_emm);
    end
    
    all_labels = [visible_labels(:); hidden_label(:)];
    all_emms   = [visible_emms(:); hidden_emm_val];
    all_ses    = [visible_ses_emm(:); hidden_se_emm];
    all_p_mean = [visible_p_vs_mean(:); hidden_p_vs_mean];
    all_p_zero = [visible_p_vs_zero(:); hidden_p_vs_zero];
    [sortedEMM, sortIdx] = sort(all_emms);
    sortedLabels = all_labels(sortIdx);
    sortedErr    = all_ses(sortIdx) * crit_t; % 95% CI using EMM-SE
    sortedPMean  = all_p_mean(sortIdx);
    sortedPZero  = all_p_zero(sortIdx);

    low_CI = sortedEMM - sortedErr;
    hi_CI = sortedEMM + sortedErr;
    CI = [low_CI, hi_CI];

    H2_3_EMM_table = table(sortedLabels, sortedEMM, CI, sortedPZero, 'VariableNames', {'Label' 'EMM', '95% CI', 'p(0)'});
    disp(H2_3_EMM_table);
    if strcmp(targetVar, 'Area')
        area_EMMs.Avg = H2_3_EMM_table;
    end

    subplot(1, size(all_vars, 2), jj);
    hold on;
    
    errorbar(1:numel(sortedEMM), sortedEMM, sortedErr, sortedErr, ...
        'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8], 'LineWidth', 1.5, 'CapSize', 8);
    
    for i = 1:numel(sortedEMM)
        % RED STAR: Significant Outlier (Diff from Grand Mean)
        if sortedPMean(i) < 0.05
            text(i, sortedEMM(i) + sortedErr(i) + 0.1, '*', 'Color', 'r', ...
                'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
        % BLACK STAR: Significant Deficit (Does not cross 0)
        if sortedPZero(i) < 0.05
            text(i, sortedEMM(i) - sortedErr(i) - 0.15, '*', 'Color', 'k', ...
                'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
    end
    
    xticks(1:numel(sortedEMM));
    xticklabels(sortedLabels);
    xtickangle(45);
    ylabel('EMM (Hedges'' g)');
    title(['Vulnerability of ', targetVar]);
    yline(0, 'k-', 'No Effect', 'LineWidth', 1.2);
    yline(intercept, 'k--', 'Grand Mean', 'Alpha', 0.5);
    grid on;
    ylim([min(sortedEMM - sortedErr) - 0.5, max(sortedEMM + sortedErr) + 0.5]);
end
%% ---------------- H2: Cell Types Planned Linear Contrasts ----------------
coef_names = cell_area_regression.CoefficientNames;
all_cells = unique(cell_area_regr_tbl.Cell);
visible_cells = erase(coef_names(contains(coef_names, 'Cell_')), 'Cell_');
hidden_cell = setdiff(all_cells, visible_cells);

% Absolute Deficit vs. Zero (EMMs)
H_PV  = H_func({'pv'}, cell_area_regression, hidden_cell, 'Cell_');
H_CB  = H_func({'cb'}, cell_area_regression, hidden_cell, 'Cell_');
H_CR  = H_func({'cr'}, cell_area_regression, hidden_cell, 'Cell_');
H_SST = H_func({'sst'}, cell_area_regression, hidden_cell, 'Cell_');

fprintf('\n--- Absolute Deficit vs. Zero (EMMs) ---\n');
fprintf('PV:  Mean = %.3f, p = %.3f\n', H_PV * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_PV));
fprintf('CB:  Mean = %.3f, p = %.3f\n', H_CR * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_CB));
fprintf('CR:  Mean = %.3f, p = %.3f\n', H_CR * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_CR));
fprintf('SST: Mean = %.3f, p = %.3f\n', H_SST * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_SST));

comparisons = {
    'PV vs CR', {'pv'}, {'cr'};
    'PV vs SST', {'pv'}, {'sst'};
    'PV vs CB/SST', {'pv'}, {'cb', 'sst'};
    'PV vs All', {'pv'}, {'cb', 'sst', 'cr'}
};

results_cell = struct('Comparison', {}, 'Estimate', {}, 'SE', {}, 'PValue', {}, 'LowerCI', {}, 'UpperCI', {});
for i = 1:size(comparisons, 1)
    % H = A - B using unified function
    H = build_H_vector(comparisons{i,2}, coef_names, hidden_cell, 'Cell_') - ...
        build_H_vector(comparisons{i,3}, coef_names, hidden_cell, 'Cell_');
    
    pVal = coefTest(cell_area_regression, H);
    est = H * cell_area_regression.Coefficients.Estimate;
    se = sqrt(H * cell_area_regression.CoefficientCovariance * H');
    
    results_cell(i) = struct('Comparison', comparisons{i, 1}, 'Estimate', est, 'SE', se, ...
                             'PValue', pVal, 'LowerCI', est - 1.96*se, 'UpperCI', est + 1.96*se);
end

resultsTable_cell = struct2table(results_cell);
figure; hold on;
for i = 1:size(resultsTable_cell, 1)
    line([resultsTable_cell.LowerCI(i), resultsTable_cell.UpperCI(i)], [i, i], 'Color', [0.2 0.2 0.2], 'LineWidth', 2);
    plot(resultsTable_cell.Estimate(i), i, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
    
    if resultsTable_cell.PValue(i) < 0.05
        text(resultsTable_cell.Estimate(i), i+0.05, '*', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    text(resultsTable_cell.UpperCI(i) + 0.05, i, sprintf('p = %.3f', resultsTable_cell.PValue(i)), 'FontWeight', 'bold');
    
    g1 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Cell, comparisons{i, 2}));
    g2 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Cell, comparisons{i, 3}));
    scatter(g1, i + 0.15, 20, 'o', 'MarkerFaceColor', [0.8 0.2 0.2], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
    scatter(g2, i - 0.15, 20, 'o', 'MarkerFaceColor', [0.2 0.2 0.8], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
end
xline(0, 'k--', 'LineWidth', 2);
set(gca, 'YTick', 1:size(resultsTable_cell, 1), 'YTickLabel', resultsTable_cell.Comparison, 'FontSize', 11);
xlabel('Contrast Estimate (Difference in Hedges'' g)');
title('Contrast Estimates Across Cell Types');
ylim([0.5, size(comparisons, 1) + 0.5]);
%% ---------------- H3: Areas Planned Linear Contrasts ----------------
all_areas = unique(cell_area_regr_tbl.Area);
all_areas_cell = cellstr(all_areas);
coef_names = cell_area_regression.CoefficientNames;
visible_areas = erase(coef_names(contains(coef_names, 'Area_')), 'Area_');
hidden_area = setdiff(all_areas, visible_areas);

pe_areas = {'midbrain', 'thalamus', 'striatum', 'pfc', 'ppc', 'vcx', 'acc'};
non_pe_areas = all_areas_cell(~ismember(all_areas_cell, pe_areas));

% Absolute Deficit vs. Zero (EMMs)
H_PE = H_func(pe_areas, cell_area_regression, hidden_area, 'Area_');
H_NonPE = H_func(non_pe_areas, cell_area_regression, hidden_area, 'Area_');
H_posterior = H_func({'vcx', 'ppc', 'a1'}, cell_area_regression, hidden_area, 'Area_');
H_anterior = H_func({'acc', 'pcc', 'bra', 'mcx', 'pfc'}, cell_area_regression, hidden_area, 'Area_');
H_ec = H_func({'ec'}, cell_area_regression, hidden_area, 'Area_');
H_hippocampus = H_func({'hippocampus'}, cell_area_regression, hidden_area, 'Area_');

fprintf('\n--- Absolute Deficit vs. Zero (EMMs) ---\n');
fprintf('PE Group:     Mean = %.3f, p = %.2e\n', H_PE * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_PE));
fprintf('Non PE Group: Mean = %.3f, p = %.2e\n', H_NonPE * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_NonPE));
fprintf('Posterior:    Mean = %.3f, p = %.2e\n', H_posterior * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_posterior));
fprintf('Anterior:     Mean = %.3f, p = %.2e\n', H_anterior * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_anterior));
fprintf('EC:           Mean = %.3f, p = %.2e\n', H_ec * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_ec));
fprintf('Hippocampus:  Mean = %.3f, p = %.2e\n', H_hippocampus * cell_area_regression.Coefficients.Estimate, coefTest(cell_area_regression, H_hippocampus));

% FB Hierarchy Visualization
FB_hierarchy_EMMs = [H_posterior * cell_area_regression.Coefficients.Estimate;
    H_anterior * cell_area_regression.Coefficients.Estimate;
    H_ec * cell_area_regression.Coefficients.Estimate;
    H_hippocampus * cell_area_regression.Coefficients.Estimate];

figure;
plot(1:numel(FB_hierarchy_EMMs), FB_hierarchy_EMMs,  'o-', 'LineWidth', 2, 'MarkerSize', 8);
xticks(1:4)
xticklabels({'Posterior', 'Anterior', 'EC', 'Hippocampus'});
ylim([-0.8 -0.5])
ylabel('Estimated Marginal Mean');
title('FB Hierarchy EMM');

% Difference Contrasts (dEMMs)
comparisons = {
    'Posterior vs Anterior', {'vcx', 'ppc', 'a1'}, {'acc', 'pcc', 'bra', 'mcx', 'pfc'};
    'Posterior vs Hippocampus', {'vcx', 'ppc', 'a1'}, {'hippocampus'};
    'Anterior vs Hippocampus', {'acc', 'pcc', 'bra', 'mcx', 'pfc'}, {'hippocampus'};
    'Posterior vs EC', {'vcx', 'ppc', 'a1'}, {'ec'};
    'Anterior vs EC', {'acc', 'pcc', 'bra', 'mcx', 'pfc'}, {'ec'};
    'PE vs non-PE', pe_areas, non_pe_areas
};

results_area = struct('Comparison', {}, 'Estimate', {}, 'SE', {}, 'PValue', {}, 'LowerCI', {}, 'UpperCI', {});

for i = 1:size(comparisons, 1)
    groupA = comparisons{i, 2};
    groupB = comparisons{i, 3};
    
    % H = A - B
    H = build_H_vector(groupA, coef_names, hidden_area, 'Area_') - ...
        build_H_vector(groupB, coef_names, hidden_area, 'Area_');
    
    pVal = coefTest(cell_area_regression, H);
    est = H * cell_area_regression.Coefficients.Estimate;
    se = sqrt(H * cell_area_regression.CoefficientCovariance * H');
    
    results_area(i) = struct('Comparison', comparisons{i, 1}, 'Estimate', est, 'SE', se, ...
                             'PValue', pVal, 'LowerCI', est - 1.96*se, 'UpperCI', est + 1.96*se);
end

% Plotting results
resultsTable_area = struct2table(results_area);
figure; hold on;
for i = 1:size(resultsTable_area, 1)
    line([resultsTable_area.LowerCI(i), resultsTable_area.UpperCI(i)], [i, i], 'Color', [0.2 0.2 0.2], 'LineWidth', 2);
    plot(resultsTable_area.Estimate(i), i, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
    
    if resultsTable_area.PValue(i) < 0.05
        text(resultsTable_area.Estimate(i), i+0.05, '*', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    
    text(resultsTable_area.LowerCI(i) - 0.05, i, sprintf('p = %.3f', resultsTable_area.PValue(i)), ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    
    g1 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Area, comparisons{i, 2}));
    g2 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Area, comparisons{i, 3}));
    scatter(g1, i + 0.15, 20, 'o', 'MarkerFaceColor', bu_td_colors(2, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
    scatter(g2, i - 0.15, 20, 'o', 'MarkerFaceColor', bu_td_colors(1, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
end

xline(0, 'k--', 'LineWidth', 2);
set(gca, 'YTick', 1:size(resultsTable_area, 1), 'YTickLabel', resultsTable_area.Comparison, 'FontSize', 11);
xlabel('Contrast Estimate (Difference in Hedges'' g)');
title('Contrast Estimates Across Brain Areas');
ylim([0.5, size(comparisons, 1) + 0.5]);
%% Save Tables to Excel Files
BU_TD_Hypothesis_Tests = [resultsTable_lam; resultsTable_area; resultsTable_cell];
writetable(BU_TD_Hypothesis_Tests, 'HypothesisTests.csv')

fileName1 = 'Laminar_Results_Full.csv';
fid = fopen(fileName1, 'w');
fprintf(fid, 'MODEL FORMULA: %s\n\n', char(laminar_regression.Formula));
fclose(fid);
writetable(dataset2table(anova(laminar_regression)), fileName1, 'WriteMode', 'append', 'WriteVariableNames', true);
fid = fopen(fileName1, 'a'); fprintf(fid, '\nCOEFFICIENTS / POST-HOC:\n'); fclose(fid);
writetable(dataset2table(laminar_regression.Coefficients), fileName1, 'WriteMode', 'append', 'WriteVariableNames', true);

fileName2 = 'CellArea_Results_Full.csv';
fid = fopen(fileName2, 'w');
fprintf(fid, 'MODEL FORMULA: %s\n\n', char(cell_area_regression.Formula));
fclose(fid);
writetable(dataset2table(anova(cell_area_regression)), fileName2, 'WriteMode', 'append', 'WriteVariableNames', true);
fid = fopen(fileName2, 'a'); fprintf(fid, '\nCOEFFICIENTS / POST-HOC:\n'); fclose(fid);
writetable(dataset2table(cell_area_regression.Coefficients), fileName2, 'WriteMode', 'append', 'WriteVariableNames', true);
%% Individual Cells Changing Across Areas
for jj = 1:size(cell_types, 2)
    target_cell = cell_types{jj};

    input_table = complete_study_table;
    g = input_table.g;
    var_g = input_table.var_g;
    Area = input_table.Structure;
    MethodType = input_table.MethodType;
    total_N = (input_table.N_HC + input_table.N_SZ);
    Bank = input_table.TissueBank;
    Cell = input_table.CellType == target_cell;
    Author = input_table.Author;

    cell_indv_regr_tbl = table(g, var_g, Bank, total_N, MethodType, Cell, Area, Author, ...
        'VariableNames',{'g','var_g', 'Bank', 'total_N', 'MethodType', 'Cell', 'Area', 'Author'});

    cell_indv_regr_tbl.Bank = categorical(lower(string(cell_indv_regr_tbl.Bank)));
    cell_indv_regr_tbl.MethodType = categorical(lower(string(cell_indv_regr_tbl.MethodType)));
    cell_indv_regr_tbl.Area = categorical(lower(string(cell_indv_regr_tbl.Area)));
    cell_indv_regr_tbl.Author = categorical(string(cell_indv_regr_tbl.Author));
    cell_indv_regr_tbl = cell_indv_regr_tbl(cell_indv_regr_tbl.Cell == 1, :);
    cell_indv_regr_tbl.Area = removecats(cell_indv_regr_tbl.Area);
    cell_indv_regr_tbl.Bank = removecats(cell_indv_regr_tbl.Bank);

    cell_indv_regr_tbl = rmmissing(cell_indv_regr_tbl);
    w = 1 ./ cell_indv_regr_tbl.var_g;

    hyp_formula = 'g ~ Area + total_N + MethodType + (1|Bank) + (1|Author)';
    cell_type_indv = fitlme(cell_indv_regr_tbl, hyp_formula, 'Weights', w, 'DummyVarCoding', 'effects');
    % disp(cell_type_indv);
    % cell_indv_stats = anova(cell_type_indv);
    % disp(cell_indv_stats);

    coef_table_cell_indv = cell_type_indv.Coefficients;
    beta_values_cell_indv = coef_table_cell_indv.Estimate;
    coef_names_cell_indv = coef_table_cell_indv.Name;
    num_area_coefficients = sum(contains(coef_names_cell_indv, 'Area'));

    intercept = cell_type_indv.Coefficients.Estimate(1);
    beta_values = cell_type_indv.Coefficients.Estimate;
    coef_names = cell_type_indv.CoefficientNames;
    cov_matrix = cell_type_indv.CoefficientCovariance;
    dfe = cell_type_indv.DFE;
    crit_t = tinv(0.975, dfe);

    figure;
    targetVar = 'Area';
    all_possible = unique(cell_indv_regr_tbl.(targetVar), 'stable');

    idx = find(contains(coef_names, [targetVar '_']));
    visible_labels = erase(coef_names(idx), [targetVar '_']);
    hidden_label = setdiff(all_possible, visible_labels, 'stable');

    H_hidden_beta = zeros(1, numel(coef_names));
    H_hidden_beta(idx) = -1;
    H_hidden_emm = H_hidden_beta;
    H_hidden_emm(1) = 1; % Include Intercept

    hidden_emm_val = H_hidden_emm * beta_values;
    hidden_se_emm = sqrt(H_hidden_emm * cov_matrix * H_hidden_emm');

    hidden_p_vs_mean = coefTest(cell_type_indv, H_hidden_beta);
    hidden_p_vs_zero = coefTest(cell_type_indv, H_hidden_emm);

    visible_emms = zeros(numel(idx), 1);
    visible_ses_emm = zeros(numel(idx), 1);
    visible_p_vs_mean = zeros(numel(idx), 1);
    visible_p_vs_zero = zeros(numel(idx), 1);

    for k = 1:numel(idx)
        H_vis_beta = zeros(1, numel(coef_names));
        H_vis_beta(idx(k)) = 1;

        H_vis_emm = H_vis_beta;
        H_vis_emm(1) = 1; % Include Intercept

        visible_emms(k) = H_vis_emm * beta_values;
        visible_ses_emm(k) = sqrt(H_vis_emm * cov_matrix * H_vis_emm');

        visible_p_vs_mean(k) = coefTest(cell_type_indv, H_vis_beta);
        visible_p_vs_zero(k) = coefTest(cell_type_indv, H_vis_emm);
    end

    all_labels = [visible_labels(:); hidden_label(:)];
    all_emms   = [visible_emms(:); hidden_emm_val];
    all_ses    = [visible_ses_emm(:); hidden_se_emm];
    all_p_mean = [visible_p_vs_mean(:); hidden_p_vs_mean];
    all_p_zero = [visible_p_vs_zero(:); hidden_p_vs_zero];
    [sortedEMM, sortIdx] = sort(all_emms);
    sortedLabels = all_labels(sortIdx);
    sortedErr    = all_ses(sortIdx) * crit_t; % 95% CI using EMM-SE
    sortedPMean  = all_p_mean(sortIdx);
    sortedPZero  = all_p_zero(sortIdx);

    low_CI = sortedEMM - sortedErr;
    hi_CI = sortedEMM + sortedErr;
    CI = [low_CI, hi_CI];

    EMM_table = table(sortedLabels, sortedEMM, CI, sortedPZero, 'VariableNames', {'Label' 'EMM', '95% CI', 'p(0)'});
    disp(EMM_table);
    area_EMMs.(target_cell) = EMM_table;

    hold on;
    errorbar(1:numel(sortedEMM), sortedEMM, sortedErr, sortedErr, ...
        'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8], 'LineWidth', 1.5, 'CapSize', 8);
    for i = 1:numel(sortedEMM)
        % RED STAR: Significant Outlier (Diff from Grand Mean)
        if sortedPMean(i) < 0.05
            text(i, sortedEMM(i) + sortedErr(i) + 0.1, '*', 'Color', 'r', ...
                'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
        % BLACK STAR: Significant Deficit (Does not cross 0)
        if sortedPZero(i) < 0.05
            text(i, sortedEMM(i) - sortedErr(i) - 0.15, '*', 'Color', 'k', ...
                'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
    end

    xticks(1:numel(sortedEMM));
    xticklabels(sortedLabels);
    % xtickangle(45);
    ylabel('EMM (Hedges'' g)');
    title(['Vulnerability Across Areas of ', target_cell]);
    yline(0, 'k-', 'No Effect', 'LineWidth', 1.2);
    yline(intercept, 'k--', 'Grand Mean', 'Alpha', 0.5);
    grid on;
    ylim([min(sortedEMM - sortedErr) - 0.5, max(sortedEMM + sortedErr) + 0.5]);
end
%% One Grouped Plot for the Individual Cell Types Across Areas
fields = fieldnames(area_EMMs); % 'Avg', 'PV', 'CB', etc.
all_labels = [];
for i = 1:numel(fields)
    all_labels = [all_labels; string(area_EMMs.(fields{i}).Label)];
end
unique_areas = unique(all_labels, 'stable'); 

emm_mat = nan(numel(unique_areas), numel(fields)); % set up matrix
low_ci_mat = nan(numel(unique_areas), numel(fields));
high_ci_mat = nan(numel(unique_areas), numel(fields));

for c = 1:numel(fields)
    T = area_EMMs.(fields{c});
    for a = 1:numel(unique_areas)
        row_idx = find(string(T.Label) == unique_areas(a));
        
        if ~isempty(row_idx) % extract values
            emm_mat(a, c) = T.EMM(row_idx);
            low_ci_mat(a, c) = T.('95% CI')(row_idx, 1); 
            high_ci_mat(a, c) = T.('95% CI')(row_idx, 2);
        end
    end
end

neg_err = emm_mat - low_ci_mat;
pos_err = high_ci_mat - emm_mat;

fields = fieldnames(area_EMMs);
num_groups = numel(unique_areas);
num_cells = numel(fields);
colors = [0 0 0; 0 0.4 0.7; 0.466 0.674 0.188; 0.850 0.325 0.098; 0.301 0.745 0.933];

figure('Color', 'w', 'Position', [100, 100, 1500, 800]);
hold on;
for x = 0.5:1:(num_groups + 0.5)
    line([x x], [-3, 3], 'Color', [0.85 0.85 0.85], ...
        'LineStyle', '--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

h_plots = gobjects(num_cells, 1);
for a = 1:num_groups
    valid_cell_indices = find(~isnan(emm_mat(a, :)));
    k = numel(valid_cell_indices);
    if k == 0
        continue; 
    end
    
    if k == 1
        local_offsets = 0;
    else
        local_offsets = linspace(-0.25, 0.25, k);
    end
    
    for i = 1:k
        cell_idx = valid_cell_indices(i);
        p = errorbar(a + local_offsets(i), emm_mat(a, cell_idx), ...
            neg_err(a, cell_idx), pos_err(a, cell_idx), ...
            'o', 'Color', colors(cell_idx,:), 'MarkerFaceColor', colors(cell_idx,:), ...
            'MarkerSize', 8, 'LineWidth', 1.5, 'CapSize', 5);
        
        if isgraphics(h_plots(cell_idx)) == 0
            h_plots(cell_idx) = p;
        end
    end
end
yline(0, 'k-', 'LineWidth', 1, 'Alpha', 0.3, 'HandleVisibility', 'off'); 
set(gca, 'XTick', 1:num_groups, 'XTickLabel', unique_areas, ...
    'TickLabelInterpreter', 'none', 'XLim', [0.5, num_groups + 0.5]);
xtickangle(45);
ylabel("EMM (Hedges' g)", 'FontWeight', 'bold');
title("Denoised Regional Map");
legend_mask = isgraphics(h_plots);
legend(h_plots(legend_mask), fields(legend_mask), 'Location', 'northeastoutside');
