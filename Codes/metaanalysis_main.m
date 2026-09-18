%%
close all; clear variables; clc;
%% Inhibitory Cell Meta-Analysis Analysis
folderLocation = setDir('GoPath', true);
rmpath("Archived")
saveFigs = 'No';
closeFigures = 'No';
warning ('off','all');
%% Background Information

areaSheet = importExcel('Raw_Data_Excel/Paper_Collection_Bookkeeping', 'Areas_Included');
paperNums = areaSheet.Number;
paperAbbvs = areaSheet.Abbreviation;
paperAssigns = areaSheet.Assignment;
areaRanks = num2cell(areaSheet.Rank);
areaIdentification = [num2cell(paperNums) paperAbbvs paperAssigns areaRanks];

paperIDsheet = importExcel('Raw_Data_Excel/Paper_Collection_Bookkeeping', 'Papers_Included');
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

cell_colors = containers.Map();
cell_colors('PV')  = [0.00, 0.44, 0.74]; % Dark Blue
cell_colors('CB')  = [0.46, 0.67, 0.18]; % Green
cell_colors('CR')  = [0.85, 0.32, 0.10]; % Orange
cell_colors('SST') = [0.30, 0.75, 0.93]; % Baby blue

%% IHC Data Grab
% import data from our IHC cortical data sheets
[raw_PV_HC_table, raw_PV_SZ_table] = importExcel('Raw_Data_Excel/IHC_CORTEX', 'PV_HC', 'PV_SZ');
[raw_CB_HC_table, raw_CB_SZ_table] = importExcel('Raw_Data_Excel/IHC_CORTEX', 'CB_HC', 'CB_SZ');
[raw_CR_HC_table, raw_CR_SZ_table] = importExcel('Raw_Data_Excel/IHC_CORTEX', 'CR_HC', 'CR_SZ');
[raw_SST_HC_table, raw_SST_SZ_table] = importExcel('Raw_Data_Excel/IHC_CORTEX', 'SST_HC', 'SST_SZ');
%% mRNA Data Grab
% import data from our mRNA data sheets
[raw_PV_HC_table_mRNA, raw_PV_SZ_table_mRNA] = importExcel('Raw_Data_Excel/mRNA_data', 'PV_HC', 'PV_SZ');
[raw_CB_HC_table_mRNA, raw_CB_SZ_table_mRNA] = importExcel('Raw_Data_Excel/mRNA_data', 'CB_HC', 'CB_SZ');
[raw_CR_HC_table_mRNA, raw_CR_SZ_table_mRNA] = importExcel('Raw_Data_Excel/mRNA_data', 'CR_HC', 'CR_SZ');
[raw_SST_HC_table_mRNA, raw_SST_SZ_table_mRNA] = importExcel('Raw_Data_Excel/mRNA_data', 'SST_HC', 'SST_SZ');
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
[raw_subC_PV_table, raw_subC_CB_table, raw_subC_CR_table, raw_subC_SST_table] = importExcel('Raw_Data_Excel/IHC_SubCortex', 'PV_Noncortical', 'CB_Noncortical', 'CR_Noncortical', 'SST_Noncortical');

PV_IHC_subcortical_table = get_nonlaminar_info(raw_subC_PV_table, area_designations);
CB_IHC_subcortical_table = get_nonlaminar_info(raw_subC_CB_table, area_designations);
CR_IHC_subcortical_table = get_nonlaminar_info(raw_subC_CR_table, area_designations);
SST_IHC_subcortical_table = get_nonlaminar_info(raw_subC_SST_table, area_designations);

%% Get non-laminar cortical info

[PV_IHC_NL, CB_IHC_NL] = importExcel('Raw_Data_Excel/IHC_Cortex', 'PV_NL', 'CB_NL');

PV_IHC_nonlaminar_table = get_nonlaminar_info(PV_IHC_NL, area_designations);
CB_IHC_nonlaminar_table = get_nonlaminar_info(CB_IHC_NL, area_designations);

[PV_mRNA_NL, CB_mRNA_NL, CR_mRNA_NL, SST_mRNA_NL] = importExcel('Raw_Data_Excel/mRNA_data', 'PV_NL', 'CB_NL', 'CR_NL', 'SST_NL');

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
table1 = importExcel('Raw_Data_Excel/Table_1_Excel.xlsx', 'All studies');
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

complete_ref_table = [PV_IHC_ref_table; CB_IHC_ref_table; CR_IHC_ref_table; SST_IHC_ref_table; ...
    PV_mRNA_ref_table; CB_mRNA_ref_table; CR_mRNA_ref_table; SST_mRNA_ref_table];
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
%% Data Types Descriptions

% All data tables contain:
% Author (Author name(s), year)
% Area # (e.g. 9, 45, etc.)
% Area abbreviation (Abbv)
% The structure (e.g. V1 is under Visual Cx)
% The group (Cortex, PFC, Subcortex, Hippocampus)
% The N subjects of HC and SZ
% The Hedges g value
% The sampling variance of g

% Before the underscore, you can have:
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
%% ------- General Results Sections -------
n_fdr_tests = table(Size=[0, 2], VariableTypes=["string" "double"], VariableNames=["Family" "N_Tests"]);
%% (1) \\\\\ Layer Resolved Effects /////
figure_folder = '/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\LaminarEffects';

% PV mRNA vs. SST mRNA PFC Layers
PV_mRNA_PFC_laminar_effects = table2array(PV_mRNA_laminar_table(ismember(PV_mRNA_laminar_table.Structure, 'PFC'), layer_names));
SST_mRNA_PFC_laminar_effects = table2array(SST_mRNA_laminar_table(ismember(SST_mRNA_laminar_table.Structure, 'PFC'), layer_names));
[~, PV_SST_mRNA_PFC_stats] = laminarBarPlot(PV_mRNA_PFC_laminar_effects, SST_mRNA_PFC_laminar_effects);
% saveToAI(figure_folder, 'Fig3d mRNA Cell Type Comparison')

% Laminar Differences in PFC by Method (PV IHC vs. mRNA)
PV_IHC_PFC_laminar_effects = table2array(PV_IHC_laminar_table(ismember(PV_IHC_laminar_table.Structure, 'PFC'), layer_names));
[~, PV_IHC_mRNA_PFC_stats] = laminarBarPlot(PV_IHC_PFC_laminar_effects, PV_mRNA_PFC_laminar_effects);
% saveToAI(figure_folder, 'Fig3c PV PFC Method Comparison')

% Laminar Differences in PV IHC in PFC vs. Entorhinal (acknowledge EC n limitation)
PV_IHC_EC_laminar_effects = table2array(PV_IHC_laminar_table(ismember(PV_IHC_laminar_table.Structure, 'EC'), layer_names));
[~, PV_IHC_PFC_EC_stats] = laminarBarPlot(PV_IHC_PFC_laminar_effects, PV_IHC_EC_laminar_effects);
% saveToAI(figure_folder, 'Fig3a PV IHC Area Comparison')

% Laminar Differences in PFC by cell type (IHC)
CB_IHC_PFC_laminar_effects = table2array(CB_IHC_laminar_table(ismember(CB_IHC_laminar_table.Structure, 'PFC'), layer_names));
CR_IHC_PFC_laminar_effects = table2array(CR_IHC_laminar_table(ismember(CR_IHC_laminar_table.Structure, 'PFC'), layer_names));
[~, PV_CB_CR_IHC_PFC_stats] = laminarBarPlot(PV_IHC_PFC_laminar_effects, CB_IHC_PFC_laminar_effects, CR_IHC_PFC_laminar_effects);
% saveToAI(figure_folder, 'Fig3b IHC Cell Type Comparison')

All_Comparisons_Stats = [PV_SST_mRNA_PFC_stats; PV_IHC_mRNA_PFC_stats; PV_IHC_PFC_EC_stats; PV_CB_CR_IHC_PFC_stats];
All_Comparisons_Stats.pVal_FDR = mafdr(All_Comparisons_Stats.pVal, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"Layer Comparisons (Cohens')", height(All_Comparisons_Stats)};

% -- Laminar Stats --
% PV mRNA PFC Layers
pv_mrna_mask  = ismember(PV_mRNA_laminar_table.Structure, 'PFC');
PV_mRNA_PFC_laminar_effects  = table2array(PV_mRNA_laminar_table(pv_mrna_mask, layer_names));
PV_mRNA_PFC_authors  = PV_mRNA_laminar_table.Author(pv_mrna_mask);

% SST mRNA PFC Layers
sst_mrna_mask = ismember(SST_mRNA_laminar_table.Structure, 'PFC');
SST_mRNA_PFC_laminar_effects = table2array(SST_mRNA_laminar_table(sst_mrna_mask, layer_names));
SST_mRNA_PFC_authors = SST_mRNA_laminar_table.Author(sst_mrna_mask);

% PV IHC PFC / EC
pv_ihc_pfc_mask = ismember(PV_IHC_laminar_table.Structure, 'PFC');
pv_ihc_ec_mask  = ismember(PV_IHC_laminar_table.Structure, 'EC');
PV_IHC_PFC_laminar_effects = table2array(PV_IHC_laminar_table(pv_ihc_pfc_mask, layer_names));
PV_IHC_EC_laminar_effects  = table2array(PV_IHC_laminar_table(pv_ihc_ec_mask, layer_names));
PV_IHC_PFC_authors = PV_IHC_laminar_table.Author(pv_ihc_pfc_mask);
PV_IHC_EC_authors  = PV_IHC_laminar_table.Author(pv_ihc_ec_mask);

% CB / CR IHC PFC
cb_ihc_mask = ismember(CB_IHC_laminar_table.Structure, 'PFC');
cr_ihc_mask = ismember(CR_IHC_laminar_table.Structure, 'PFC');
CB_IHC_PFC_laminar_effects = table2array(CB_IHC_laminar_table(cb_ihc_mask, layer_names));
CR_IHC_PFC_laminar_effects = table2array(CR_IHC_laminar_table(cr_ihc_mask, layer_names));
CB_IHC_PFC_authors = CB_IHC_laminar_table.Author(cb_ihc_mask);
CR_IHC_PFC_authors = CR_IHC_laminar_table.Author(cr_ihc_mask);

raw_laminar_data_cells = {PV_IHC_PFC_laminar_effects, CB_IHC_PFC_laminar_effects, CR_IHC_PFC_laminar_effects, ...
                          PV_IHC_EC_laminar_effects, PV_mRNA_PFC_laminar_effects, SST_mRNA_PFC_laminar_effects};
raw_laminar_authors_cells = {PV_IHC_PFC_authors, CB_IHC_PFC_authors, CR_IHC_PFC_authors, ...
                             PV_IHC_EC_authors, PV_mRNA_PFC_authors, SST_mRNA_PFC_authors};
row_labels = {'PV_IHC_PFC', 'CB_IHC_PFC', 'CR_IHC_PFC', 'PV_IHC_EC', 'PV_mRNA_PFC', 'SST_mRNA_PFC'};

numExps = length(raw_laminar_data_cells);
numLayers = size(raw_laminar_data_cells{1}, 2);
means_mat = zeros(numExps, numLayers);
n_mat  = zeros(numExps, numLayers);  % N_o: number of datapoints
ns_mat = zeros(numExps, numLayers);  % N_s: number of unique studies
p_mat  = zeros(numExps, numLayers);

for i = 1:numExps
    current_data    = raw_laminar_data_cells{i};
    current_authors = raw_laminar_authors_cells{i};
    for j = 1:numLayers
        layer_data   = current_data(:, j);
        valid_mask   = ~isnan(layer_data);
        layer_data   = layer_data(valid_mask);
        layer_authors = current_authors(valid_mask);

        means_mat(i, j) = mean(layer_data);
        n_mat(i, j)     = length(layer_data);
        ns_mat(i, j)    = length(unique(layer_authors));

        if length(layer_data) > 1
            [~, p] = ttest(layer_data);
            p_mat(i, j) = p;
        else
            p_mat(i, j) = NaN;
        end
    end
end

valid_idx = ~isnan(p_mat(:));
valid_p_vals = p_mat(valid_idx);
valid_p_FDR = mafdr(valid_p_vals, 'BHFDR', true);
p_mat_FDR_vec = NaN(size(p_mat(:)));
p_mat_FDR_vec(valid_idx) = valid_p_FDR;
p_mat_FDR = reshape(p_mat_FDR_vec, size(p_mat));

colNames = [];
combined_data = [];
for j = 1:numLayers
    colNames = [colNames, {sprintf('L%d_Mean', j), sprintf('L%d_N_o', j), sprintf('L%d_N_s', j), ...
                            sprintf('L%d_pVal', j), sprintf('L%d_pVal_FDR', j)}];
    combined_data = [combined_data, means_mat(:,j), n_mat(:,j), ns_mat(:,j), p_mat(:,j), p_mat_FDR(:, j)];
end
layers_effects_table = array2table(combined_data, 'RowNames', row_labels, 'VariableNames', colNames);

n_fdr_tests(end+1, :) = {"Laminar Effect Sizes (One-Sample)", height(valid_p_FDR)};
%% (2) \\\\\ Structure Level Differences ///// We then move on to the structure-level differences
figure_folder = '/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure3';
% Bar Plots for IHC Structures
PV_IHC_struct = tscore2struct(PV_IHC_dataframe);
CB_IHC_struct = tscore2struct(CB_IHC_dataframe);
CR_IHC_struct = tscore2struct(CR_IHC_dataframe);
SST_IHC_struct = tscore2struct(SST_IHC_dataframe);

PV_IHC_2_stats = struct2barh(PV_IHC_struct, areaIdentification, 'PV Effect Size IHC');
% saveToAI(figure_folder, 'Fig3g PV Interneurons Across Areas IHC')
CB_IHC_2_stats = struct2barh(CB_IHC_struct, areaIdentification, 'CB Effect Size IHC');
% saveToAI(figure_folder, 'Fig3j CB Interneurons Across Areas IHC')
CR_IHC_2_stats = struct2barh(CR_IHC_struct, areaIdentification, 'CR Effect Size IHC');
% saveToAI(figure_folder, 'Fig3i CR Interneurons Across Areas IHC')
SST_IHC_2_stats = struct2barh(SST_IHC_struct, areaIdentification, 'SST Effect Size IHC');
% saveToAI(figure_folder, 'Fig3h SST Interneurons Across Areas IHC')

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
PV_mRNA_struct = tscore2struct(PV_mRNA_dataframe);
CB_mRNA_struct = tscore2struct(CB_mRNA_dataframe);
CR_mRNA_struct = tscore2struct(CR_mRNA_dataframe);
SST_mRNA_struct = tscore2struct(SST_mRNA_dataframe);

PV_mRNA_2_stats = struct2barh(PV_mRNA_struct, areaIdentification, 'PV Effect Size mRNA');
% saveToAI(figure_folder, 'Fig3g PV Interneurons Across Areas mRNA')
CB_mRNA_2_stats = struct2barh(CB_mRNA_struct, areaIdentification, 'CB Effect Size mRNA');
% saveToAI(figure_folder, 'Fig3j CB Interneurons Across Areas mRNA')
CR_mRNA_2_stats = struct2barh(CR_mRNA_struct, areaIdentification, 'CR Effect Size mRNA');
% saveToAI(figure_folder, 'Fig3i CR Interneurons Across Areas mRNA')
SST_mRNA_2_stats = struct2barh(SST_mRNA_struct, areaIdentification, 'SST Effect Size mRNA');
% saveToAI(figure_folder, 'Fig3h SST Interneurons Across Areas mRNA')

% Effect Size Across Cell Types in PFC (mRNA)
effect_PVCB_mRNA = compute_cohens(PV_mRNA_struct.PFC_effect(:, 2), CB_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: PV vs. CB'});
effect_PVCR_mRNA = compute_cohens(PV_mRNA_struct.PFC_effect(:, 2), CR_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: PV vs. CR'});
effect_PVSST_mRNA = compute_cohens(PV_mRNA_struct.PFC_effect(:, 2), SST_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: PV vs. SST'});
effect_CBCR_mRNA = compute_cohens(CB_mRNA_struct.PFC_effect(:, 2), CR_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: CB vs. CR'});
effect_CBSST_mRNA = compute_cohens(CB_mRNA_struct.PFC_effect(:, 2), SST_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: CB vs. SST'});
effect_SSTCR_mRNA = compute_cohens(SST_mRNA_struct.PFC_effect(:, 2), CR_mRNA_struct.PFC_effect(:, 2), {'mRNA PFC: SST vs. CR'});

% Effect Size Across Cell Types in Hippocampus (mRNA)
effect_PVSST_mRNA_hipp = compute_cohens(PV_mRNA_struct.Hippocampus_effect(:, 2), SST_mRNA_struct.Hippocampus_effect(:, 2), {'mRNA Hipp: PV vs. SST'});

% Within-Group Comparisons
cell_type_PFC_cohens = vertcat(effect_PVCB, effect_PVCR, effect_CBCR, effect_PVCB_mRNA, effect_PVCR_mRNA, effect_PVSST_mRNA, effect_CBCR_mRNA, effect_SSTCR_mRNA, ...
    effect_PVCB_IHC_Hipp, effect_PVCR_IHC_Hipp, effect_PVSST_IHC_Hipp, effect_CBCR_IHC_Hipp, effect_CBSST_IHC_Hipp, effect_SSTCR_IHC_Hipp, effect_PVSST_mRNA_hipp);
% there is insufficient data to perform this type of analysis in other structures
cell_type_PFC_cohens.p_FDR = mafdr(cell_type_PFC_cohens.p_value, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"Cell-Cell Comparisons within Groups", height(cell_type_PFC_cohens)};

% FDR Correct Structure-Level Deficits (One-Sample Tests)
p_PV_IHC = PV_IHC_2_stats.pVal;
p_CB_IHC = CB_IHC_2_stats.pVal;
p_CR_IHC = CR_IHC_2_stats.pVal;
p_SST_IHC = SST_IHC_2_stats.pVal;

p_PV_mRNA = PV_mRNA_2_stats.pVal;
p_CB_mRNA = CB_mRNA_2_stats.pVal;
p_CR_mRNA = CR_mRNA_2_stats.pVal;
p_SST_mRNA = SST_mRNA_2_stats.pVal;

All_Struct_pVals = [p_PV_IHC; p_CB_IHC; p_CR_IHC; p_SST_IHC; p_PV_mRNA; p_CB_mRNA; p_CR_mRNA; p_SST_mRNA];

valid_idx_struct = ~isnan(All_Struct_pVals);
valid_p_vals_struct = All_Struct_pVals(valid_idx_struct);

valid_p_FDR_struct = mafdr(valid_p_vals_struct, 'BHFDR', true);

All_Struct_pFDR = NaN(size(All_Struct_pVals));
All_Struct_pFDR(valid_idx_struct) = valid_p_FDR_struct;

idx = 1;
PV_IHC_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_PV_IHC) - 1);
    idx = idx + length(p_PV_IHC);
CB_IHC_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_CB_IHC) - 1);
    idx = idx + length(p_CB_IHC);
CR_IHC_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_CR_IHC) - 1);
    idx = idx + length(p_CR_IHC);
SST_IHC_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_SST_IHC) - 1);
    idx = idx + length(p_SST_IHC);

PV_mRNA_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_PV_mRNA) - 1);
    idx = idx + length(p_PV_mRNA);
CB_mRNA_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_CB_mRNA) - 1);
    idx = idx + length(p_CB_mRNA);
CR_mRNA_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_CR_mRNA) - 1);
    idx = idx + length(p_CR_mRNA);
SST_mRNA_2_stats.pVal_FDR = All_Struct_pFDR(idx : idx + length(p_SST_mRNA) - 1);

n_fdr_tests(end+1, :) = {"Cellular Structural Deficits (e.g., PV IHC ACC)", height(valid_p_FDR_struct)};

% ------------------------------------ PV vs. SST mRNA ------------------------------------
PV_fields = fieldnames(PV_mRNA_struct);
PV_fieldRanks = zeros(length(PV_fields), 1);
for ii = 1:length(PV_fields)
    rankName = PV_fields{ii};
    areaRank = PV_mRNA_struct.(rankName)(1);
    PV_fieldRanks(ii) = cell2mat(areaIdentification(((cell2mat(areaIdentification(:, 1))) == areaRank), 4));
end
[~, rankIndx] = sort(PV_fieldRanks, 'descend');
ranks = zeros(size(PV_fieldRanks));
ranks(rankIndx) = 1:length(PV_fieldRanks);
PV_color = cell_colors('PV');
SST_color =  cell_colors('SST');

numSEM = 2;
figure;
for ar = 1:length(PV_fields)
    fieldName = PV_fields{ar};
    areaNumber = PV_mRNA_struct.(fieldName)(1, 1);
    PV_fieldValues = PV_mRNA_struct.(fieldName)(:, 2);
    SST_fieldValues = SST_mRNA_struct.(fieldName)(:, 2);

    b = barh(ranks(ar), [mean(SST_fieldValues), mean(PV_fieldValues)]);
    PV_pos = b(2).XEndPoints; SST_pos = b(1).XEndPoints;
    b(2).FaceColor = PV_color; b(2).FaceAlpha = 0.3; b(2).EdgeColor = PV_color;
    b(1).FaceColor = SST_color; b(1).FaceAlpha = 0.3; b(1).EdgeColor = SST_color;
    hold on;

    PV_SEM = numSEM*(std(PV_fieldValues)/sqrt(numel(PV_fieldValues)));
    PV_areaMean = mean(PV_fieldValues);

    SST_SEM = numSEM*(std(SST_fieldValues)/sqrt(numel(SST_fieldValues)));
    SST_areaMean = mean(SST_fieldValues);

    scatter(PV_fieldValues, PV_pos, 250, '.', 'MarkerEdgeColor', PV_color)
    scatter(SST_fieldValues, SST_pos, 250, '.', 'MarkerEdgeColor', SST_color)

    errorbar(PV_areaMean, PV_pos, PV_SEM, 'horizontal', 'LineStyle', 'none', 'Color', PV_color)
    errorbar(SST_areaMean, SST_pos, SST_SEM, 'horizontal', 'LineStyle', 'none', 'Color', SST_color)

    areaLabels{ar} = cell2mat(areaIdentification(((cell2mat(areaIdentification(:, 1))) == areaNumber), 3));

    [~, p] = ttest2(PV_fieldValues, SST_fieldValues);
    if p < 0.05
        line([-2 -2],[PV_pos SST_pos], 'Color', 'k', 'LineWidth', 2)
        text(-2.2, ar, '*', 'FontWeight', 'bold', 'FontSize', 20)
    end
    [~, p] = ttest(PV_fieldValues);
    if p < 0.01
        text(-2.8, PV_pos, '**', 'Color', PV_color, 'FontWeight', 'bold', 'FontSize', 20)
    elseif p < 0.05
        text(-2.8, PV_pos, '*', 'Color', PV_color, 'FontWeight', 'bold', 'FontSize', 20)
    end
    [~, p] = ttest(SST_fieldValues);
    if p < 0.01
        text(-2.8, SST_pos, '**', 'Color', SST_color, 'FontWeight', 'bold', 'FontSize', 20)
    elseif p < 0.05
        text(-2.8, SST_pos, '*', 'Color', SST_color, 'FontWeight', 'bold', 'FontSize', 20)
    end
end
yticks(1:length(PV_fields))
yticklabels(areaLabels(rankIndx))
xlim([-3 3])
ylabel('Area')
xlabel('Hedge''s g')
title('PV & SST mRNA Effect Size')
legend('SST', 'PV')

%% (3) \\\\\ Group Level Differences ///// Compare PFC (frontal) to hippocampus, subcortex, non-frontal cortex
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

% effect_PV_IHC_SST_HIPP = compute_cohens(PV_IHC_dataframe.g(ismember(PV_IHC_dataframe.Group, 'Hippocampus')), SST_IHC_dataframe.g(ismember(SST_IHC_dataframe.Group, 'Hippocampus')), {'IHC Hipp: PV vs. SST'});

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
        PFC_results_table.n(m) = numel(variable);
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
        Hippocampus_results_table.n(m) = numel(variable);
        Hippocampus_results_table.p_value(m) = p;
        m = m+1;
    end

end

PFC_Hipp_pvals = [PFC_results_table.p_value; Hippocampus_results_table.p_value];
PFC_Hipp_p_FDR = mafdr(PFC_Hipp_pvals, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"PFC/Hipp Deficits (one-sample)", height(PFC_Hipp_p_FDR)};

PFC_results_table.p_FDR = PFC_Hipp_p_FDR(1:height(PFC_results_table));
Hippocampus_results_table.p_FDR = PFC_Hipp_p_FDR(height(PFC_results_table)+1:end);

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

% pub_format(gcf, 'Figures_01_2026/cohens_supp1', 'nature', '1.5', true);
% saveToAI(append(folderLocation, '\Figures_01_2026'), 'IHC_vs_mRNA_Cohens');

group_level_comps = [group_level_comps_IHC; group_level_comps_mRNA; ihc_mrna_stats];
group_level_comps.p_FDR = mafdr(group_level_comps.p_value, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"Comparisons within cell types across groups (e.g., (PV PFC vs. Cx)", height(group_level_comps)};
%% Forest Plot Analysis
figure_folder = append(folderLocation, '\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure2');

plotForest(PV_IHC_dataframe, 'PV IHC', 'remove', 'g');
% saveToAI(figure_folder, 'PV_IHC_forest');
plotForest(CB_IHC_dataframe, 'CB IHC', 'dontremove', 'g');
% saveToAI(figure_folder, 'CB_IHC_forest');
plotForest(CR_IHC_dataframe, 'CR IHC', 'dontremove', 'g');
% saveToAI(figure_folder, 'CR_IHC_forest');
plotForest(SST_IHC_dataframe, 'SST IHC', 'dontremove', 'g');
% saveToAI(figure_folder, 'SST_IHC_forest');

plotForest(PV_mRNA_dataframe, 'PV mRNA', 'dontremove', 'g');
% saveToAI(figure_folder, 'PV_mRNA_forest');
plotForest(CB_mRNA_dataframe, 'CB mRNA', 'dontremove', 'g');
% saveToAI(figure_folder, 'CB_mRNA_forest');
plotForest(CR_mRNA_dataframe, 'CR mRNA', 'dontremove', 'g');
% saveToAI(figure_folder, 'CR_mRNA_forest');
plotForest(SST_mRNA_dataframe, 'SST mRNA', 'dontremove', 'g');
% saveToAI(figure_folder, 'SST_mRNA_forest');
%% Brain Effect Size Heat Maps
input_range = 2;
% PV_IHC_heatmap_data = effectsize2heatmap(PV_IHC_dataframe, input_range, "PV IHC");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'PV_IHC_heatmaps');
% CB_IHC_heatmap_data = effectsize2heatmap(CB_IHC_dataframe, input_range, "CB IHC");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'CB_IHC_heatmaps');
% CR_IHC_heatmap_data = effectsize2heatmap(CR_IHC_dataframe, input_range, "CR IHC");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'CR_IHC_heatmaps');
% SST_IHC_heatmap_data = effectsize2heatmap(SST_IHC_dataframe, input_range, "SST IHC");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'SST_IHC_heatmaps');
% 
% PV_mRNA_heatmap_data = effectsize2heatmap(PV_mRNA_dataframe, input_range, "PV mRNA");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'PV_mRNA_heatmaps');
% CB_mRNA_heatmap_data = effectsize2heatmap(CB_mRNA_dataframe, input_range, "CB mRNA");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'CB_mRNA_heatmaps');
% CR_mRNA_heatmap_data = effectsize2heatmap(CR_mRNA_dataframe, input_range, "CR mRNA");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'CR_mRNA_heatmaps');
% SST_mRNA_heatmap_data = effectsize2heatmap(SST_mRNA_dataframe, input_range, "SST mRNA");
% % saveToAI(append(folderLocation, '\Figures_01_2026\HeatmapsFig(5)_Raw'), 'SST_mRNA_heatmaps');

%% Publication Bias

combined_fig = figure('WindowState', 'maximized');
t = tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');

[PV_IHC_bias_table, ~]   = bias_correction(PV_IHC_studies, 0, 'PV IHC', nexttile(t));
[CB_IHC_bias_table, ~]   = bias_correction(CB_IHC_studies, 0, 'CB IHC', nexttile(t));
[CR_IHC_bias_table, ~]   = bias_correction(CR_IHC_studies, 0, 'CR IHC', nexttile(t));
[SST_IHC_bias_table, ~]  = bias_correction(SST_IHC_studies, 0, 'SST IHC', nexttile(t));

[PV_mRNA_bias_table, ~]  = bias_correction(PV_mRNA_studies, 0, 'PV mRNA', nexttile(t));
[CB_mRNA_bias_table, ~]  = bias_correction(CB_mRNA_studies, 0, 'CB mRNA', nexttile(t));
[CR_mRNA_bias_table, ~]  = bias_correction(CR_mRNA_studies, 0, 'CR mRNA', nexttile(t));
[SST_mRNA_bias_table, ~] = bias_correction(SST_mRNA_studies, 0, 'SST mRNA', nexttile(t));

% saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\SUPP', 'SuppFig1 Publication Bias')

publication_bias = vertcat(PV_IHC_bias_table, CB_IHC_bias_table, CR_IHC_bias_table, SST_IHC_bias_table, PV_mRNA_bias_table, CB_mRNA_bias_table, CR_mRNA_bias_table, SST_mRNA_bias_table);
publication_bias.Egger_p0_FDR = mafdr(publication_bias.Egger_p0, 'BHFDR', true);
%% Heterogeneity Analysis (Random-Effects Model)
input_tables = {PV_IHC_studies; PV_mRNA_studies; CB_IHC_studies; CB_mRNA_studies; CR_IHC_studies; CR_mRNA_studies; SST_IHC_studies; SST_mRNA_studies};

% input_tables = {PV_IHC_ref_table; CB_IHC_ref_table; CR_IHC_ref_table; SST_IHC_ref_table; PV_mRNA_ref_table; CB_mRNA_ref_table; CR_mRNA_ref_table; SST_mRNA_ref_table};

min_studies = 5;

het_table = table();
het_table.Label = ["PV IHC"; "CB IHC"; "CR IHC"; "SST IHC"; "PV mRNA"; "CB mRNA"; "CR mRNA"; "SST mRNA"];

input_structures = ["PFC", "Hippocampus", "Cortex", "Subcortex"];

for it = 1:length(input_tables)
    input_table = input_tables{it};
    
    for ss = 1:length(input_structures)
        input_structure = input_structures(ss);
        ref = input_table(ismember(input_table.Group, input_structure), :);
        
        yi = ref.g;
        vi = ref.var_g;
        k(ss) = height(ref);
        
        if k(ss) >= min_studies
            w_fixed = 1 ./ vi;
            sum_w = sum(w_fixed);
            sum_w_sq = sum(w_fixed.^2);
            
            % Cochran's Q
            Q = sum(w_fixed .* (yi - sum(w_fixed.*yi)/sum_w).^2);
            df = k(ss) - 1;
            p_Q = 1 - chi2cdf(Q, df);
            
            % I-squared (%)
            I2(ss) = max(0, (Q - df)/Q) * 100;
            
            % Tau-squared (DerSimonian-Laird)
            C = sum_w - (sum_w_sq / sum_w);
            Tau2(ss) = max(0, (Q - df) / C);
        else
            % Handle cases with < X studies
            I2(ss) = NaN;
            Tau2(ss) = NaN;
        end
    end
    
    % Populate Table for PFC
    het_table.PFC_k(it) = k(1);
    het_table.PFC_I2(it) = I2(1);
    het_table.PFC_Tau2(it) = Tau2(1);
    
    % Populate Table for Hippocampus
    het_table.Hpcps_k(it) = k(2);
    het_table.Hpcps_I2(it) = I2(2);
    het_table.Hpcps_Tau2(it) = Tau2(2);

    if size(input_structures, 2) > 2
        % Populate Table for Cortex
        het_table.Cx_k(it) = k(3);
        het_table.Cx_I2(it) = I2(3);
        het_table.Cx_Tau2(it) = Tau2(3);

        % Populate Table for Subcx
        het_table.Subcx_k(it) = k(4);
        het_table.Subcx_I2(it) = I2(4);
        het_table.Subcx_Tau2(it) = Tau2(4);
    end
end

disp(het_table);
%% ---------------- Demographics Meta Regression ----------------
input_table = complete_ref_table; % or complete_study_table
g = input_table.g;
var_g = input_table.var_g;
dAge = input_table.SZ_ages - input_table.HC_ages;
dSex = input_table.SZ_sex_ratio - input_table.HC_sex_ratio;
dPMI = input_table.SZ_PMI - input_table.HC_PMI;
dPH = input_table.SZ_PH - input_table.HC_PH;
total_N = (input_table.N_HC + input_table.N_SZ);
subregion = input_table.Abbv;
macro_area = input_table.Structure;
area_group = input_table.Group;
MethodType = input_table.MethodType;
Bank = input_table.TissueBank;
Fixation = input_table.FixMethod;
Cell = input_table.CellType;
Author = input_table.Author;

regression_tbl = table(g, var_g, dAge, dSex, dPMI, dPH, total_N, Bank, Fixation, MethodType, Cell, Author, macro_area, subregion, area_group, ...
    'VariableNames',{'g','var_g','dAge','dSex','dPMI', 'dPH', 'N', 'Bank', 'Fixation', 'MethodType', 'Cell', 'Author', 'macro_area', 'subregion', 'area_group'});

regression_tbl.Bank = categorical(lower(string(regression_tbl.Bank)));
regression_tbl.Area = categorical(lower(string(regression_tbl.area_group))); % subregion, area_group
regression_tbl.Fixation = categorical(lower(string(regression_tbl.Fixation)));
regression_tbl.MethodType = categorical(lower(string(regression_tbl.MethodType)));
regression_tbl.Cell = categorical(lower(string(regression_tbl.Cell)));
regression_tbl.Author = categorical(string(regression_tbl.Author));
regression_tbl.Cell = reordercats(regression_tbl.Cell, {'cr', 'cb', 'sst', 'pv'});

regression_tbl = rmmissing(regression_tbl);

regression_tbl.weights = 1 ./ regression_tbl.var_g;

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>Linear Mixed-Effects Meta-Regression</strong>\n");
fprintf("---------------------------------------------------\n");

formula_mixed = 'g ~ dAge + dSex + dPMI + dPH + MethodType + Area + N + Cell + (1|Bank) + (1|Fixation) + (1|Author)';
meta_regression = fitlme(regression_tbl, formula_mixed, 'Weights', regression_tbl.weights, 'DummyVarCoding', 'effects');
disp(meta_regression);
fprintf("---------------------------------------------------\n");
demo_stats_table = anova(meta_regression);
disp(demo_stats_table);

%%%
% regression_tbl_reduced = table(g, var_g, dAge, dPMI,total_N, Bank, MethodType, Cell, Author, macro_area, subregion, area_group, ...
%     'VariableNames',{'g','var_g','dAge','dPMI', 'N', 'Bank', 'MethodType', 'Cell', 'Author', 'macro_area', 'subregion', 'area_group'});
% 
% regression_tbl_reduced.Bank = categorical(lower(string(regression_tbl_reduced.Bank)));
% regression_tbl_reduced.Area = categorical(lower(string(regression_tbl_reduced.area_group))); % subregion, area_group
% regression_tbl_reduced.MethodType = categorical(lower(string(regression_tbl_reduced.MethodType)));
% regression_tbl_reduced.Cell = categorical(lower(string(regression_tbl_reduced.Cell)));
% regression_tbl_reduced.Author = categorical(string(regression_tbl_reduced.Author));
% regression_tbl_reduced.Cell = reordercats(regression_tbl_reduced.Cell, {'pv', 'cb', 'sst', 'cr'});
% 
% regression_tbl_reduced = rmmissing(regression_tbl_reduced);
% 
% w = 1 ./ regression_tbl_reduced.var_g;
% 
% formula_reduced = 'g ~ dAge + dPMI + MethodType + Area + N + Cell + (1|Author) + (1|Bank)';
% meta_regression_reduced = fitlme(regression_tbl_reduced, formula_reduced, 'Weights', w, 'DummyVarCoding', 'effects');
% disp(meta_regression_reduced);
% fprintf("---------------------------------------------------\n");
% demo_stats_reduced = anova(meta_regression_reduced);

demo_anova = dataset2table(demo_stats_table);
demo_anova.p_FDR = mafdr(demo_anova.pValue, 'BHFDR', true);
disp(demo_anova);
n_fdr_tests(end+1, :) = {"Demographics Anova", height(demo_anova)};

beta = meta_regression.Coefficients.Estimate;
beta_cells = meta_regression.Coefficients(contains(meta_regression.Coefficients.Name, "Cell"), :);
covMat = meta_regression.CoefficientCovariance;
dfe = meta_regression.DFE;
coefNames = meta_regression.CoefficientNames;

H = zeros(1, numel(beta));
H(strcmp(coefNames, 'Cell_pv')) = -1;
H(strcmp(coefNames, 'Cell_cb')) = -1;
H(strcmp(coefNames, 'Cell_sst')) = -1;

cr_est = H * beta;
cr_se = sqrt(H * covMat * H');
cr_t = cr_est / cr_se;
cr_p = coefTest(meta_regression, H);
crit_t = tinv(0.975, dfe);
cr_lower = cr_est - (crit_t * cr_se);
cr_upper = cr_est + (crit_t * cr_se);

CR_Table = table("Cell_cr", cr_est, cr_se, cr_t, dfe, cr_p, cr_lower, cr_upper, ...
    'VariableNames', {'Name', 'Estimate', 'SE', 'tStat', 'DF', 'pValue', 'Lower', 'Upper'});

demographics_coefficients = [dataset2table(meta_regression.Coefficients); CR_Table];

%% Estimated Marginal Means for MethodType from Demographics Model
unique_methods = string(unique(regression_tbl.MethodType, 'stable'));
beta_names = meta_regression.CoefficientNames;
beta_vals = meta_regression.Coefficients.Estimate;
cov_mat_red = meta_regression.CoefficientCovariance;
dfe_red = meta_regression.DFE;
crit_t_red = tinv(0.975, dfe_red);

hidden_method = "";
for i = 1:numel(unique_methods)
    if ~any(strcmp(beta_names, "MethodType_" + char(unique_methods(i))))
        hidden_method = unique_methods(i);
        break;
    end
end

method_out_name = cell(numel(unique_methods), 1);
method_emm = zeros(numel(unique_methods), 1);
method_se = zeros(numel(unique_methods), 1);
method_p = zeros(numel(unique_methods), 1);

for m = 1:numel(unique_methods)
    curr_m = unique_methods(m);
    method_out_name{m} = char(curr_m);
    
    H_m = zeros(1, numel(beta_names));
    
    for i = 1:numel(beta_names)
        col = beta_names{i};
        
        if strcmp(col, '(Intercept)')
            H_m(i) = 1;
            continue;
        end
        
        if startsWith(col, 'MethodType_')
            clean_m = erase(col, 'MethodType_');
            if strcmp(clean_m, curr_m)
                H_m(i) = 1;
            elseif strcmp(curr_m, hidden_method)
                H_m(i) = -1;
            end
        end
    end
    
    method_emm(m) = H_m * beta_vals;
    method_se(m) = sqrt(H_m * cov_mat_red * H_m');
    method_p(m) = coefTest(meta_regression, H_m);
end

err_margin = method_se * crit_t_red;
Method_EMM_Demog_Table = table(method_out_name, method_emm, ...
    method_emm - err_margin, method_emm + err_margin, method_p, ...
    'VariableNames', {'MethodType', 'EMM_g', 'Lower_95CI', 'Upper_95CI', 'p_Value'});

fprintf("\n---------------------------------------------------\n");
fprintf("<strong>Adjusted EMMs for MethodType (Controlling for Demographics)</strong>\n");
fprintf("---------------------------------------------------\n");
disp(Method_EMM_Demog_Table);
%% -------- Sensitivity Analysis: Leave-One-Author-Out --------
unique_authors = unique(regression_tbl.Author);

target_params = {'(Intercept)', 'dAge', 'dPMI', 'N', 'Cell_pv', 'Cell_cb', 'Cell_sst', 'MethodType_mrna'};
formula_reduced = 'g ~ dAge + dPMI + MethodType + Area + N + Cell + (1|Author) + (1|Bank)';

sensitivity_summary = table();

fprintf("\nRunning Leave-One-Author-Out Sensitivity Analysis...\n");

for i = 1:length(unique_authors)
    current_author = unique_authors(i);

    sensitivity_tbl = regression_tbl(regression_tbl.Author ~= current_author, :);
    w_sens = 1 ./ sensitivity_tbl.var_g;

    try
        meta_sens = fitlme(sensitivity_tbl, formula_mixed, 'Weights', w_sens);
        coef_tbl = meta_sens.Coefficients;

        row_entry = table(current_author, 'VariableNames', {'OmittedAuthor'});

        for p = 1:length(target_params)
            p_name = target_params{p};
            match_idx = strcmp(coef_tbl.Name, p_name);

            if any(match_idx)
                row_entry.(p_name) = coef_tbl.Estimate(match_idx);
            else
                row_entry.(p_name) = NaN;
            end
        end

        sensitivity_summary = [sensitivity_summary; row_entry];

    catch ME
        fprintf("Skipping Author '%s' due to model estimation failure.\n", string(current_author));
    end
end

disp('------------------------------------------------------------');
disp('<strong>Structured Leave-One-Author-Out Coefficient Estimates</strong>');
disp('------------------------------------------------------------');
disp(sensitivity_summary);

numeric_cols = target_params;
numeric_data = table2array(sensitivity_summary(:, numeric_cols));

mean_coef = mean(numeric_data, 1, 'omitnan');
sd_coef  = std(numeric_data, 0, 1, 'omitnan');
min_coef  = min(numeric_data, [], 1, 'omitnan');
max_coef  = max(numeric_data, [], 1, 'omitnan');

manuscript_reporting_tbl = table(numeric_cols', mean_coef', sd_coef', min_coef', max_coef', ...
    'VariableNames', {'Parameter', 'LOO_Mean', 'LOO_SD', 'LOO_Min', 'LOO_Max'});

disp('------------------------------------------------------------');
disp('<strong>PRISMA Sensitivity Analysis Summary for Manuscript Text</strong>');
disp('------------------------------------------------------------');
disp(manuscript_reporting_tbl);

% ---- LOO Stability: Test if mean estimate differs from zero ----
t_stat = mean_coef ./ (sd_coef ./ sqrt(size(numeric_data, 1)));
df = size(numeric_data, 1) - 1;
p_val = 2 * (1 - tcdf(abs(t_stat), df));

stability_tbl = table(numeric_cols', mean_coef', sd_coef', t_stat', p_val', ...
    'VariableNames', {'Parameter', 'LOO_Mean', 'LOO_SD', 't_stat', 'p_value'});

disp(stability_tbl);
%% ---------------- Multilevel Egger's Test ----------------
fprintf("\n===================================================\n");
fprintf("<strong>MULTILEVEL EGGER'S REGRESSION TEST</strong>\n");
fprintf("===================================================\n");

regression_tbl.SE = sqrt(regression_tbl.var_g);

formula_egger = 'g ~ SE + dAge + dPMI + MethodType + area_group + N + Cell + (1|Author)';
meta_egger = fitlme(regression_tbl, formula_egger, 'Weights', regression_tbl.weights);

egger_coefs = meta_egger.Coefficients;
egger_row = egger_coefs(strcmp(egger_coefs.Name, 'SE'), :);
disp(egger_row);
fprintf("===================================================\n");

if egger_row.pValue < 0.05
    fprintf("RESULT: Significant funnel asymmetry detected (p = %.4f).\n", egger_row.pValue);
    fprintf("--> Interpretation: Potential risk of publication bias. Small studies tend to report larger effects.\n");
else
    fprintf("RESULT: No significant funnel asymmetry detected (p = %.4f).\n", egger_row.pValue);
    fprintf("--> Interpretation: Low risk of publication bias altering the synthesized results.\n");
end

%% ---------------- Exploratory Analyses -----------------------
% mRNA Technique (FISH, ISH, qPCR, etc.) Regression
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
fprintf("<strong>Regression on mRNA Technique Types</strong>\n");
fprintf("---------------------------------------------------\n");
mrna_technique_mdl = fitlme(tbl, 'g ~ Method + (1|Author) + (1|Bank)', 'Weights', weights);
disp(mrna_technique_mdl)
mrna_technique_anova = anova(mrna_technique_mdl);
disp(mrna_technique_anova);

mrna_technique_mdl_coeffs = dataset2table(mrna_technique_mdl.Coefficients);
%% Cell Type - Method Interaction Regression
input_table = complete_ref_table;
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
cell_method_regression_mdl = fitlme(tbl, 'g ~ cell_type * method + (1|Author)', 'Weights', weights, 'DummyVarCoding', 'effects');
disp(cell_method_regression_mdl)
stats = anova(cell_method_regression_mdl);
disp(stats);

cell_method_regression_anova = dataset2table(stats);

beta_values = cell_method_regression_mdl.Coefficients.Estimate;
coef_names = cell_method_regression_mdl.CoefficientNames;
cov_matrix = cell_method_regression_mdl.CoefficientCovariance;
crit_t = tinv(0.975, cell_method_regression_mdl.DFE);

unique_cells = string(unique(tbl.cell_type, 'stable'));
unique_methods = string(unique(tbl.method, 'stable'));

hidden_cell = '';
for i = 1:numel(unique_cells)
    if ~any(strcmp(coef_names, ['cell_type_' char(unique_cells(i))]))
        hidden_cell = unique_cells(i);
        break;
    end
end

hidden_method = '';
for i = 1:numel(unique_methods)
    if ~any(strcmp(coef_names, ['method_' char(unique_methods(i))]))
        hidden_method = unique_methods(i);
        break;
    end
end

num_cells = numel(unique_cells);
num_methods = numel(unique_methods);
total_combos = num_cells * num_methods;

out_cell = cell(total_combos, 1);
out_method = cell(total_combos, 1);
emm_means = zeros(total_combos, 1);
emm_ses = zeros(total_combos, 1);
p_vs_zero = zeros(total_combos, 1);

row_idx = 1;
for c = 1:num_cells
    curr_cell = unique_cells(c);
    
    for m = 1:num_methods
        curr_method = unique_methods(m);
        
        out_cell{row_idx}   = char(curr_cell);
        out_method{row_idx} = char(curr_method);
        
        H = zeros(1, numel(coef_names));
        for i = 1:numel(coef_names)
            col_name = coef_names{i};
            
            if strcmp(col_name, '(Intercept)')
                H(i) = 1;
                continue;
            end
            
            cell_match = 0;
            if startsWith(col_name, 'cell_type_') && ~contains(col_name, ':')
                clean_c = erase(col_name, 'cell_type_');
                if strcmp(clean_c, curr_cell), cell_match = 1;
                elseif strcmp(curr_cell, hidden_cell), cell_match = -1; end
                H(i) = cell_match;
                continue;
            end
            
            method_match = 0;
            if startsWith(col_name, 'method_') && ~contains(col_name, ':')
                clean_m = erase(col_name, 'method_');
                if strcmp(clean_m, curr_method), method_match = 1;
                elseif strcmp(curr_method, hidden_method), method_match = -1; end
                H(i) = method_match;
                continue;
            end
            
            if contains(col_name, ':')
                tokens = split(col_name, ':');
                X_cell = ''; Y_method = '';
                
                if startsWith(tokens{1}, 'cell_type_')
                    X_cell = erase(tokens{1}, 'cell_type_');
                end
                if startsWith(tokens{2}, 'cell_type_')
                    X_cell = erase(tokens{2}, 'cell_type_');
                end
                if startsWith(tokens{1}, 'method_')
                    Y_method = erase(tokens{1}, 'method_');
                end
                if startsWith(tokens{2}, 'method_')
                    Y_method = erase(tokens{2}, 'method_');
                end
                
                c_weight = 0;
                if strcmp(X_cell, curr_cell), c_weight = 1;
                elseif strcmp(curr_cell, hidden_cell), c_weight = -1; end
                
                m_weight = 0;
                if strcmp(Y_method, curr_method), m_weight = 1;
                elseif strcmp(curr_method, hidden_method), m_weight = -1; end
                
                H(i) = c_weight * m_weight;
            end
        end
        
        emm_means(row_idx) = H * beta_values;
        emm_ses(row_idx)   = sqrt(H * cov_matrix * H');
        p_vs_zero(row_idx) = coefTest(cell_method_regression_mdl, H);
        
        row_idx = row_idx + 1;
    end
end

err_bars   = emm_ses * crit_t;
Lower_95CI = emm_means - err_bars;
Upper_95CI = emm_means + err_bars;

Cell_Method_EMM_Table = table(out_cell, out_method, emm_means, Lower_95CI, Upper_95CI, p_vs_zero, ...
    'VariableNames', {'Cell_Type', 'Method', 'EMM_g', 'Lower_95CI', 'Upper_95CI', 'p_Value'});
disp(Cell_Method_EMM_Table);
%% --- Reagent Manufacturer Regression ---
input_table = complete_ref_table;
g = input_table.g;
var_g = input_table.var_g;
dAge = input_table.SZ_ages - input_table.HC_ages;
dSex = input_table.SZ_sex_ratio - input_table.HC_sex_ratio;
dPMI = input_table.SZ_PMI - input_table.HC_PMI;
dPH = input_table.SZ_PH - input_table.HC_PH;
total_N = (input_table.N_HC + input_table.N_SZ);
subregion = input_table.Abbv;
macro_area = input_table.Structure;
area_group = input_table.Group;
MethodType = input_table.MethodType;
Bank = input_table.TissueBank;
Fixation = input_table.FixMethod;
Cell = input_table.CellType;
Author = input_table.Author;
Manufacturer = input_table.Manufacturer;

manu_regression_tbl = table(g, var_g, total_N, dPH, dPMI, dAge, Bank, Cell, Author, area_group, Manufacturer, ...
    'VariableNames',{'g','var_g', 'N', 'dpH', 'dPMI', 'dAge', 'Bank', 'Cell', 'Author', 'area_group', 'Manufacturer'});

manu_regression_tbl.Bank = categorical(lower(string(manu_regression_tbl.Bank)));
manu_regression_tbl.Area = categorical(lower(string(manu_regression_tbl.area_group))); 
manu_regression_tbl.Cell = categorical(lower(string(manu_regression_tbl.Cell)));
manu_regression_tbl.Author = categorical(string(manu_regression_tbl.Author));
manu_regression_tbl.Manufacturer = categorical(string(manu_regression_tbl.Manufacturer));

manu_regression_tbl.Cell = reordercats(manu_regression_tbl.Cell, {'pv', 'cb', 'sst', 'cr'});

manu_regression_tbl = rmmissing(manu_regression_tbl);

manu_regression_tbl.Author = removecats(manu_regression_tbl.Author);
manu_regression_tbl.Manufacturer = removecats(manu_regression_tbl.Manufacturer);
manu_regression_tbl.Area = removecats(manu_regression_tbl.Area);
manu_regression_tbl.Cell = removecats(manu_regression_tbl.Cell);

w = 1 ./ manu_regression_tbl.var_g;

manu_formula = 'g ~ dAge + dPMI + dpH + Manufacturer + N + Cell + (1|Author) + (1|Bank)'; 

manu_regression = fitlme(manu_regression_tbl, manu_formula, 'Weights', w);
anova(manu_regression)
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

fprintf('Laminar Studies:           %d\n', num_laminar);
fprintf('Non-Laminar Studies:       %d\n\n', num_non_laminar);

fprintf('Cell Type Breakdown (Unique Study Counts):\n');
disp(CellTypeBreakdown);
fprintf('------------------------------------------------------------\n');
%% ------------ Bottom-Up vs. Top-Down Hypothesis Testing ---------- %%
%  ----------------------------------------------------------------- %

bu_td_labels = {'Bottom-Up', 'Top-Down'};
bu_td_colors = [0.8 0.2 0.2; ... % Red for TD
    0.2 0.4 0.8]; % Blue for BU
bu_td_cells = {'PV', 'CB', 'SST'};
n_boot = 1000;
rng(42, 'twister');

pe_areas = {'Midbrain', 'Thalamus', 'Striatum', 'PFC', 'PPC', 'VCx', 'ACC'};
posterior_areas = {'VCx', 'PPC', 'A1'};
anterior_areas = {'ACC', 'PCC', 'BrA', 'MCx', 'PFC'};

complete_study_table.Hierarchy(ismember(complete_study_table.Structure, posterior_areas)) = "Posterior";
complete_study_table.Hierarchy(ismember(complete_study_table.Structure, anterior_areas)) = "Anterior";
complete_study_table.Hierarchy(ismember(complete_study_table.Structure, {'Hippocampus', 'EC'})) = "Hippocampus/EC";

complete_study_table.isPE = repmat("Non-PE", height(complete_study_table), 1);
complete_study_table.isPE(ismember(complete_study_table.Structure, pe_areas)) = "PE";

% posterior = {'VCx', 'PPC', 'A1'};
% anterior = {'ACC', 'PCC', 'BrA', 'MCx', 'PFC'};
% complete_study_table.Region = repmat("Other", height(complete_study_table), 1);
% complete_study_table.Region(ismember(complete_study_table.Structure, posterior)) = "Posterior";
% complete_study_table.Region(ismember(complete_study_table.Structure, anterior)) = "Anterior";
% complete_study_table.Region(ismember(complete_study_table.Structure, 'EC')) = "Entorhinal";
% complete_study_table.Region(ismember(complete_study_table.Structure, 'Hippocampus')) = "Hippocampus";
%% Add Bank and Fix to laminar table
% this is done in get_info, but needs to be added for laminar studies
num_ref_rows = height(complete_laminar_table);
num_table1_rows = height(table1);

table1_authors = string(table1.Author) + ", " + string(table1.Year);
table1_cell_types = string(table1.("Cell Type"));
table1_regions = string(table1.Area);

ref_authors = string(complete_laminar_table.Author);
ref_authors = regexprep(ref_authors, '\s*\((\d{4})\)', ', $1');

ref_cell_types = string(complete_laminar_table.CellType);
ref_regions = string(complete_laminar_table.Abbv);

matching_indices = NaN(num_ref_rows, 1);

for i = 1:num_ref_rows
    for j = 1:num_table1_rows
        author_match = strcmpi(ref_authors(i), table1_authors(j));
        cell_match = contains(table1_cell_types(j), ref_cell_types(i), 'IgnoreCase', true);

        % region_match = contains(table1_regions(j), ref_regions(i), 'IgnoreCase', true);

        if author_match && cell_match % && region_match
            matching_indices(i) = j;
            break;
        end
    end
end

complete_laminar_table.TissueBank = repmat({string(missing)}, num_ref_rows, 1);
complete_laminar_table.FixMethod = repmat({string(missing)}, num_ref_rows, 1);
complete_laminar_table.ReagentSource = repmat({string(missing)}, num_ref_rows, 1);

matched_idx = ~isnan(matching_indices);

if any(matched_idx)
    for i = find(matched_idx(:))'
        v_row = matching_indices(i);
        
        complete_laminar_table.TissueBank{i} = table1.("Tissue Obtained")(v_row);
        complete_laminar_table.FixMethod{i} = table1.("Fixation Method")(v_row);
        
        target_cell = string(complete_laminar_table.CellType{i});
        
        col_name = "Manufacturer_" + target_cell;
        
        if any(strcmp(table1.Properties.VariableNames, col_name))
            complete_laminar_table.ReagentSource{i} = table1.(col_name)(v_row);
        else
            complete_laminar_table.ReagentSource{i} = "NA";
        end
    end
end

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
laminar_regr_tbl.Cell = reordercats(laminar_regr_tbl.Cell, {'cr', 'pv', 'sst', 'cb'});
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
% disp(lam_stats);
fprintf("---------------------------------------------------\n");

laminar_interaction_formula = 'g ~ Layer*Cell + Area + total_N + MethodType + (1|Author) + (1|Bank)';
laminar_interaction_regr = fitlme(laminar_regr_tbl, laminar_interaction_formula, 'Weights', w, 'DummyVarCoding', 'effects');
disp(laminar_interaction_regr);

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

all_vars = {'Cell', 'Layer'};
intercept = laminar_regression.Coefficients.Estimate(1);
beta_values = laminar_regression.Coefficients.Estimate;
coef_names = laminar_regression.CoefficientNames;
cov_matrix = laminar_regression.CoefficientCovariance;
dfe = laminar_regression.DFE;
crit_t = tinv(0.975, dfe);

all_vars = {'Cell', 'Area','Layer'};
Master_H1_EMM_table = table();
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
    H1_EMM_table.p_FDR = mafdr(H1_EMM_table.("p(0)") , 'BHFDR', true);
    disp(H1_EMM_table);
    
    n_fdr_tests(end+1, :) = {("H1 (Layers) EMM: " + targetVar), height(H1_EMM_table)};

    Master_H1_EMM_table = [Master_H1_EMM_table; H1_EMM_table];
    
    figure;
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
    set(gca, "view", [90 90]);

    if strcmp(targetVar, 'Layer')
        saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure3', ...
            'Fig3e Estimated Marginal Mean of Cortical Layers')
    else
        saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\SUPP', ...
            ['SuppFig2 Estimated Marginal means of ', targetVar])
    end

end
% saveToAI(append(folderLocation, '\Figures_01_2026\'), 'Laminar_EMMs');

%% ---------------- H1: Layers Planned Linear Contrasts ----------------

coef_names = laminar_regression.CoefficientNames;
num_coefs = numel(coef_names);
all_layers = unique(laminar_regr_tbl.Layer);
visible_layers = erase(coef_names(contains(coef_names, 'Layer_')), 'Layer_');
hidden_layer = setdiff(all_layers, visible_layers);

H_func = @(groups, regr, hidden_sum, label) arrayfun(@(n) strcmp(n,'(Intercept)') + (ismember(erase(n,label),groups)/numel(groups)) - ...
    (ismember(hidden_sum,groups)*(startsWith(n,label)/numel(groups))), regr.CoefficientNames);

% H_func_int = @(groups, regr, hidden_sum, label) cell2mat(cellfun(@(n) ...
%     ( strcmp(n,'(Intercept)') ) + ... % 1. Intercept component
%     ( ismember(erase(n,label), groups) / numel(groups) ) - ... % 2. Main Effect inclusion
%     ( ismember(hidden_sum, groups) * (startsWith(n,label) && ~contains(n,':')) / numel(groups) ) + ... % 3. Main Effect hidden reference correction
%     ... % 4. Interaction Term Distribution
%     ( contains(n,':') && any(cellfun(@(g) contains(n, [label g]) || contains(n, [g ':']), groups)) / numel(groups) ) - ... 
%     ... % 5. Interaction Term Hidden Reference Correction
%     ( contains(n,':') && ismember(hidden_sum, groups) * any(cellfun(@(str) startsWith(n,str) || endsWith(n,str), {label, hidden_sum})) / numel(groups)), ...
%     regr.CoefficientNames, 'UniformOutput', false));

H_BU_ALL = H_func({'L2', 'L3', 'L4'}, laminar_regression, hidden_layer, 'Layer_');
H_BU_INPUT = H_func({'L4'}, laminar_regression, hidden_layer, 'Layer_');
H_BU_OUPUT = H_func({'L2', 'L3'}, laminar_regression, hidden_layer, 'Layer_');

H_TD_ALL = H_func({'L1', 'L5', 'L6'}, laminar_regression, hidden_layer, 'Layer_');
H_TD_INPUT = H_func({'L1'}, laminar_regression, hidden_layer, 'Layer_');
H_TD_OUTPUT = H_func({'L5', 'L6'}, laminar_regression, hidden_layer, 'Layer_');

emm_labels = {'BU ALL (L2/3/4)'; 'BU INPUT (L4)'; 'BU OUTPUT (L2/3)'; ...
              'TD ALL (L1/5/6)'; 'TD INPUT (L1)'; 'TD OUTPUT (L5/6)'};
          
emm_vectors = {H_BU_ALL; H_BU_INPUT; H_BU_OUPUT; ...
               H_TD_ALL; H_TD_INPUT; H_TD_OUTPUT};

means = zeros(numel(emm_vectors), 1);
lower_cis = zeros(numel(emm_vectors), 1);
upper_cis = zeros(numel(emm_vectors), 1);
p_values = zeros(numel(emm_vectors), 1);
for i = 1:numel(emm_vectors)
    H = emm_vectors{i};
    
    est = H * laminar_regression.Coefficients.Estimate;
    se = sqrt(H * laminar_regression.CoefficientCovariance * H');
    
    means(i) = est;
    lower_cis(i) = est - 1.96 * se;
    upper_cis(i) = est + 1.96 * se;
    p_values(i) = coefTest(laminar_regression, H);
end
Laminar_EMM_Summary = table(emm_labels, means, lower_cis, upper_cis, p_values, ...
    'VariableNames', {'Label', 'Mean_Estimate', 'Lower_95CI', 'Upper_95CI', 'P_Value'});
disp('--- Summary of Estimated Marginal Means (Laminar Groups) ---');
disp(Laminar_EMM_Summary);

comparisons = {
    'All (L2/3/4 v. L1/5/6)', {'L2', 'L3', 'L4'}, {'L1', 'L5', 'L6'};
    'Receivers (L4 v. L1)', {'L4'}, {'L1'};
    'Senders (L2/3 v. L5/6)', {'L2', 'L3'}, {'L5', 'L6'}
};

results_layer = struct('Comparison', {}, 'Estimate', {}, 'SE', {}, 'PValue', {}, 'LowerCI', {}, 'UpperCI', {});

for i = 1:size(comparisons, 1)
    compA = comparisons{i, 2};
    compB = comparisons{i, 3};
    H = zeros(1, num_coefs);
    
    % Effects coding: Beta_L6 = -(Beta_L1 + Beta_L2 + Beta_L3 + Beta_L4 + Beta_L5)
    for j = 1:num_coefs
        name = coef_names{j};
        
        for k = 1:numel(compA)
            layer = compA{k};
            if strcmp(name, ['Layer_', layer])
                H(j) = H(j) + (1 / numel(compA));
            elseif strcmp(layer, 'L6') && startsWith(name, 'Layer_L') && ~strcmp(name, 'Layer_L6')
                H(j) = H(j) - (1 / numel(compA));
            end
        end
        for k = 1:numel(compB)
            layer = compB{k};
            if strcmp(name, ['Layer_', layer])
                H(j) = H(j) - (1 / numel(compB));
            elseif strcmp(layer, 'L6') && startsWith(name, 'Layer_L') && ~strcmp(name, 'Layer_L6')
                H(j) = H(j) + (1 / numel(compB));
            end
        end
    end
    
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
Estimates = resultsTable_lam.Estimate;
Lower = resultsTable_lam.LowerCI; Upper = resultsTable_lam.UpperCI;
y_pos = 1:size(comparisons, 1);

figure;
hold on;
for i = 1:size(comparisons, 1)
    line([Lower(i), Upper(i)], [y_pos(i), y_pos(i)], 'Color', [0.2 0.2 0.2], 'LineWidth', 2);
    plot(Estimates(i), y_pos(i), 'ks', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
    if resultsTable_lam.PValue(i) < 0.05
        text(Estimates(i), y_pos(i)+0.05, '*', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    text(Upper(i) + 0.05, y_pos(i), ['p = ', num2str(resultsTable_lam.PValue(i), '%.3f')], 'FontWeight', 'bold');
    
    g1 = laminar_regr_tbl.g(ismember(laminar_regr_tbl.Layer, comparisons{i, 2}));
    g2 = laminar_regr_tbl.g(ismember(laminar_regr_tbl.Layer, comparisons{i, 3}));
    scatter(g1, y_pos(i) + 0.15, 20, 'o', 'MarkerFaceColor', [0.8 0.2 0.2], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.3);
    scatter(g2, y_pos(i) - 0.15, 20, 'o', 'MarkerFaceColor', [0.2 0.2 0.8], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.3);
end
xline(0, 'k--', 'LineWidth', 2);
set(gca, 'YTick', 1:size(comparisons, 1), 'YTickLabel', resultsTable_lam.Comparison, 'FontSize', 11);
xlabel('Contrast Estimate (Difference in Hedges'' g)');
title('Laminar Contrasts');
% saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure4', ...
%     'Fig4c Laminar Contrasts')
%% ---------------- Hypothesis Test Regression (H2/3, Cells and Areas) ----------------

input_table = complete_study_table; %(ismember(complete_study_table.Group, ["Subcortex"; "Hippocampus"]), :);
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
% disp(cell_area_regression);
cell_area_stats = anova(cell_area_regression);
% disp(cell_area_stats);
% pe_cell_interaction = fitlme(cell_area_regr_tbl, 'g ~ Cell*isPE + total_N + MethodType + (1|Bank) + (1|Author)', 'Weights', w, 'DummyVarCoding', 'effects');
% pe_cell_stats = anova(pe_cell_interaction);

coef_table_cell_area = cell_area_regression.Coefficients;
beta_values_H12 = coef_table_cell_area.Estimate;
coef_names_H12 = coef_table_cell_area.Name;
num_area_coefficients = sum(contains(coef_names_H12, 'Area'));

area_EMMs = struct();
all_vars = {'Area', 'Cell'};
intercept = cell_area_regression.Coefficients.Estimate(1);
beta_values = cell_area_regression.Coefficients.Estimate;
coef_names = cell_area_regression.CoefficientNames;
cov_matrix = cell_area_regression.CoefficientCovariance;
dfe = cell_area_regression.DFE;
crit_t = tinv(0.975, dfe);

% sgtitle('Adjusted Vulnerability Profile (Absolute vs. Relative Deficits)');
Master_H2_EMM_Table = table();
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
    H2_3_EMM_table.p_FDR = mafdr(H2_3_EMM_table.("p(0)") , 'BHFDR', true);
    disp(H2_3_EMM_table);

    n_fdr_tests(end+1, :) = {("H2/3 (Area/Cell) EMM: " + targetVar), height(H2_3_EMM_table)};

    Master_H2_EMM_Table = [Master_H2_EMM_Table; H2_3_EMM_table];
    if strcmp(targetVar, 'Area')
        area_EMMs.Avg = H2_3_EMM_table;
    end

    % subplot(1, size(all_vars, 2), jj);
    figure;
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
    set(gca, "view", [90 90]);

    % if strcmp(targetVar, 'Cell')
    %     saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure3', ...
    %         'Fig3 Estimated Marginal Mean of Cells')
    % else
    %     saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\SUPP', ...
    %         'SuppFig3 Estimated Marginal Mean of Areas')
    % end

end
%% ---------------- H2: Cell Types Planned Linear Contrasts ----------------

coef_names = cell_area_regression.CoefficientNames;
all_cells = unique(cell_area_regr_tbl.Cell);
visible_cells = erase(coef_names(contains(coef_names, 'Cell_')), 'Cell_');
hidden_cell = setdiff(all_cells, visible_cells);

H_func = @(groups, regr, hidden_sum, label) arrayfun(@(n) strcmp(n,'(Intercept)') + (ismember(erase(n,label),groups)/numel(groups)) - ...
    (ismember(hidden_sum,groups)*(startsWith(n,label)/numel(groups))), regr.CoefficientNames);

H_PV = H_func({'pv'}, cell_area_regression, hidden_cell, 'Cell_');
H_CB = H_func({'cb'}, cell_area_regression, hidden_cell, 'Cell_');
H_CR = H_func({'cr'}, cell_area_regression, hidden_cell, 'Cell_');
H_SST = H_func({'sst'}, cell_area_regression, hidden_cell, 'Cell_');
H_TD_Cells = H_func({'cb', 'cr', 'sst'}, cell_area_regression, hidden_cell, 'Cell_');

cell_labels = {'PV'; 'CB'; 'CR'; 'SST'; 'TD Cells (CB/CR/SST)'};     
cell_vectors = {H_PV; H_CB; H_CR; H_SST; H_TD_Cells};

means_cell = zeros(numel(cell_vectors), 1);
lower_cis_cell = zeros(numel(cell_vectors), 1);
upper_cis_cell = zeros(numel(cell_vectors), 1);
p_values_cell = zeros(numel(cell_vectors), 1);

for i = 1:numel(cell_vectors)
    H = cell_vectors{i};
    
    est = H * cell_area_regression.Coefficients.Estimate;
    se = sqrt(H * cell_area_regression.CoefficientCovariance * H');
    
    means_cell(i) = est;
    lower_cis_cell(i) = est - 1.96 * se;
    upper_cis_cell(i) = est + 1.96 * se;
    p_values_cell(i) = coefTest(cell_area_regression, H);
end
Cell_EMM_Summary = table(cell_labels, means_cell, lower_cis_cell, upper_cis_cell, p_values_cell, ...
    'VariableNames', {'Label', 'Mean_Estimate', 'Lower_95CI', 'Upper_95CI', 'P_Value'});
fprintf('\n--- Summary of Estimated Marginal Means (Cell Types) ---\n');
disp(Cell_EMM_Summary);

comparisons = {
    'PV vs CR', {'pv'}, {'cr'};
    'PV vs SST', {'pv'}, {'sst'};
    'PV vs CB/SST', {'pv'}, {'cb', 'sst'};
    'PV vs All', {'pv'}, {'cb', 'sst', 'cr'}
};

results_cell = struct('Comparison', {}, 'Estimate', {}, 'SE', {}, 'PValue', {}, 'LowerCI', {}, 'UpperCI', {});

for i = 1:size(comparisons, 1)
    groupA = comparisons{i, 2};
    groupB = comparisons{i, 3};
    
    build_H = @(groups) arrayfun(@(name) ...
        (ismember(erase(name, 'Cell_'), groups) / numel(groups)) - ...
        (ismember(hidden_cell, groups) * (startsWith(name, 'Cell_') / numel(groups))), ...
        coef_names);

    H = build_H(groupA) - build_H(groupB);
    
    pVal = coefTest(cell_area_regression, H);
    est = H * cell_area_regression.Coefficients.Estimate;
    se = sqrt(H * cell_area_regression.CoefficientCovariance * H');
    
    results_cell(i) = struct('Comparison', comparisons{i, 1}, 'Estimate', est, 'SE', se, ...
                             'PValue', pVal, 'LowerCI', est - 1.96*se, 'UpperCI', est + 1.96*se);
end

resultsTable_cell = struct2table(results_cell);
Estimates = resultsTable_cell.Estimate;
Lower = resultsTable_cell.LowerCI; 
Upper = resultsTable_cell.UpperCI;
y_pos = 1:size(comparisons, 1);

figure; hold on;
for i = 1:size(comparisons, 1)
    line([Lower(i), Upper(i)], [y_pos(i), y_pos(i)], 'Color', [0.2 0.2 0.2], 'LineWidth', 2);
    plot(Estimates(i), y_pos(i), 'ks', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
    
    if resultsTable_cell.PValue(i) < 0.05
        text(Estimates(i), y_pos(i)+0.05, '*', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    text(Upper(i) + 0.05, y_pos(i), ['p = ', num2str(resultsTable_cell.PValue(i), '%.3f')], 'FontWeight', 'bold');
    
    g1 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Cell, comparisons{i, 2}));
    g2 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Cell, comparisons{i, 3}));
    
    scatter(g1, y_pos(i) + 0.15, 20, 'o', 'MarkerFaceColor', [0.8 0.2 0.2], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
    scatter(g2, y_pos(i) - 0.15, 20, 'o', 'MarkerFaceColor', [0.2 0.2 0.8], 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
end

xline(0, 'k--', 'LineWidth', 2);
set(gca, 'YTick', 1:size(comparisons, 1), 'YTickLabel', resultsTable_cell.Comparison, 'FontSize', 11);
xlabel('Contrast Estimate (Difference in Hedges'' g)');
title('Contrast Estimates Across Cell Types');
ylim([0.5, size(comparisons, 1) + 0.5]);
% saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure4', ...
%     'Fig4d Cell Type Contrasts')
%% ---------------- H3: Areas Planned Linear Contrasts ----------------

all_areas = unique(cell_area_regr_tbl.Area);
all_areas_cell = cellstr(all_areas);
coef_names = cell_area_regression.CoefficientNames;
visible_areas = erase(coef_names(contains(coef_names, 'Area_')), 'Area_');
hidden_area = setdiff(all_areas, visible_areas);
pe_areas = {'midbrain', 'thalamus', 'striatum', 'pfc', 'ppc', 'vcx', 'acc'};
non_pe_areas = all_areas_cell(~ismember(all_areas_cell, pe_areas));
posterior_areas = {'vcx', 'ppc', 'a1'};
anterior_areas = {'acc', 'pcc', 'bra', 'mcx', 'pfc'};
hippocampal_areas = {'hippocampus'};
ec_areas = {'ec'};

H_func = @(groups, regr, hidden_sum, label) arrayfun(@(n) strcmp(n,'(Intercept)') + (ismember(erase(n,label),groups)/numel(groups)) - ...
    (ismember(hidden_sum,groups)*(startsWith(n,label)/numel(groups))), regr.CoefficientNames);

% H_PE = H_func(pe_areas, cell_area_regression, hidden_area, 'Area_');
% H_NonPE = H_func(non_pe_areas, cell_area_regression, hidden_area, 'Area_');
H_posterior = H_func({'vcx', 'ppc', 'a1'}, cell_area_regression, hidden_area, 'Area_');
H_anterior = H_func({'acc', 'pcc', 'bra', 'mcx', 'pfc'}, cell_area_regression, hidden_area, 'Area_');
H_ec = H_func({'ec'}, cell_area_regression, hidden_area, 'Area_');
H_hippocampus = H_func({'hippocampus'}, cell_area_regression, hidden_area, 'Area_');

area_labels = {'Posterior'; 'Anterior'; 'EC'; 'Hippocampus'};
area_vectors = {H_posterior; H_anterior; H_ec; H_hippocampus};

means_area = zeros(numel(area_vectors), 1);
lower_cis_area = zeros(numel(area_vectors), 1);
upper_cis_area = zeros(numel(area_vectors), 1);
p_values_area = zeros(numel(area_vectors), 1);

for i = 1:numel(area_vectors)
    H = area_vectors{i};
    est = H * cell_area_regression.Coefficients.Estimate;
    se = sqrt(H * cell_area_regression.CoefficientCovariance * H');
    
    means_area(i) = est;
    lower_cis_area(i) = est - 1.96 * se;
    upper_cis_area(i) = est + 1.96 * se;
    p_values_area(i) = coefTest(cell_area_regression, H);
end
Area_EMM_Summary = table(area_labels, means_area, lower_cis_area, upper_cis_area, p_values_area, ...
    'VariableNames', {'Label', 'Mean_Estimate', 'Lower_95CI', 'Upper_95CI', 'P_Value'});
fprintf('\n--- Summary of Estimated Marginal Means (Brain Areas) ---\n');
disp(Area_EMM_Summary);

FB_hierarchy_EMMs = [H_posterior * cell_area_regression.Coefficients.Estimate;
    H_anterior * cell_area_regression.Coefficients.Estimate;
    H_ec * cell_area_regression.Coefficients.Estimate;
    H_hippocampus * cell_area_regression.Coefficients.Estimate];

figure;
plot(1:height(FB_hierarchy_EMMs), FB_hierarchy_EMMs,  'o-', 'LineWidth', 2, 'MarkerSize', 8);
xticks(1:4)
xticklabels({'Posterior', 'Anterior', 'EC', 'Hippocampus'});
ylim([-0.8 -0.5])
ylabel('Estimated Marginal Mean');
title('FB Hierarchy EMM');

sensory_motor_areas = {'vcx', 'a1', 'mcx'};
heteromodal_areas = {'ppc', 'pfc', 'bra'};
paralimbic_areas = {'pcc', 'acc'};
limbic_areas = {'amygdala', 'ec', 'hippocampus'};

H_primary_motor_sensor = H_func(sensory_motor_areas, cell_area_regression, hidden_area, 'Area_');
H_heteromodal = H_func(heteromodal_areas, cell_area_regression, hidden_area, 'Area_');
H_paralimbic = H_func(paralimbic_areas, cell_area_regression, hidden_area, 'Area_');
H_limbic = H_func(limbic_areas, cell_area_regression, hidden_area, 'Area_');

mesulam_hierarchy_EMMs = [H_primary_motor_sensor * cell_area_regression.Coefficients.Estimate;
    H_heteromodal * cell_area_regression.Coefficients.Estimate;
    H_paralimbic * cell_area_regression.Coefficients.Estimate;
    H_limbic * cell_area_regression.Coefficients.Estimate;
    ];

figure;
plot(1:height(mesulam_hierarchy_EMMs), mesulam_hierarchy_EMMs,  'o-', 'LineWidth', 2, 'MarkerSize', 8);
xticks(1:height(mesulam_hierarchy_EMMs))
xticklabels({'Sensory-Motor', 'Heteromodal', 'Paralimbic', 'Limbic'});
ylim([-0.8 -0.5])
ylabel('Estimated Marginal Mean');
title('Mesulam Hierarchy EMM');

% comparisons = {
%     'Sensory-Motor vs Heteromodal', sensory_motor_areas, heteromodal_areas;
%     'Sensory-Motor vs Paralimbic', sensory_motor_areas, paralimbic_areas;
%     'Sensory-Motor vs Limbic', sensory_motor_areas, limbic_areas;
%     'Heteromodal vs Paralimbic', heteromodal_areas, paralimbic_areas;
%     'Heteromodal vs Limbic', heteromodal_areas, limbic_areas;
%     'Paralimbic vs Limbic', paralimbic_areas, limbic_areas;
%     'PE vs non-PE', pe_areas, non_pe_areas
% };

comparisons = {
    'Posterior vs Anterior', {'vcx', 'ppc', 'a1'}, {'acc', 'pcc', 'bra', 'mcx', 'pfc'};
    'Posterior vs Hippocampus', {'vcx', 'ppc', 'a1'}, {'hippocampus'};
    'Anterior vs Hippocampus', {'acc', 'pcc', 'bra', 'mcx', 'pfc'}, {'hippocampus'};
    'Posterior vs EC', {'vcx', 'ppc', 'a1'}, {'ec'};
    'Anterior vs EC', {'acc', 'pcc', 'bra', 'mcx', 'pfc'}, {'ec'}
    % 'PE vs non-PE', pe_areas, non_pe_areas;
    % 'Sensory-Motor vs Heteromodal', sensory_motor_areas, heteromodal_areas;
    % 'Sensory-Motor vs Paralimbic', sensory_motor_areas, paralimbic_areas;
    % 'Sensory-Motor vs Limbic', sensory_motor_areas, limbic_areas;
    % 'Heteromodal vs Paralimbic', heteromodal_areas, paralimbic_areas;
    % 'Heteromodal vs Limbic', heteromodal_areas, limbic_areas;
    % 'Paralimbic vs Limbic', paralimbic_areas, limbic_areas
    };

% comparisons = {'PE vs non-PE', pe_areas, non_pe_areas};

results_area = struct('Comparison', {}, 'Estimate', {}, 'SE', {}, 'PValue', {}, 'LowerCI', {}, 'UpperCI', {});

for i = 1:size(comparisons, 1)
    groupA = comparisons{i, 2};
    groupB = comparisons{i, 3};
    
    build_H = @(groups) arrayfun(@(name) ...
        (ismember(erase(name, 'Area_'), groups) / numel(groups)) - ...
        (ismember(hidden_area, groups) * (startsWith(name, 'Area_') / numel(groups))), ...
        coef_names);

    H = build_H(groupA) - build_H(groupB);
    
    pVal = coefTest(cell_area_regression, H);
    est = H * cell_area_regression.Coefficients.Estimate;
    se = sqrt(H * cell_area_regression.CoefficientCovariance * H');
    
    results_area(i) = struct('Comparison', comparisons{i, 1}, 'Estimate', est, 'SE', se, ...
                             'PValue', pVal, 'LowerCI', est - 1.96*se, 'UpperCI', est + 1.96*se);
end

resultsTable_area = struct2table(results_area);
Estimates = resultsTable_area.Estimate;
Lower = resultsTable_area.LowerCI; 
Upper = resultsTable_area.UpperCI;
y_pos = 1:size(comparisons, 1);

figure;
hold on;
for i = 1:size(comparisons, 1)
    line([Lower(i), Upper(i)], [y_pos(i), y_pos(i)], 'Color', [0.2 0.2 0.2], 'LineWidth', 2);
    plot(Estimates(i), y_pos(i), 'ks', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8]);
    
    if resultsTable_area.PValue(i) < 0.05
        text(Estimates(i), y_pos(i)+0.05, '*', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    text(Lower(i) - 0.05, y_pos(i), ['p = ', num2str(resultsTable_area.PValue(i), '%.3f')], ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    
    g1 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Area, comparisons{i, 2}));
    g2 = cell_area_regr_tbl.g(ismember(cell_area_regr_tbl.Area, comparisons{i, 3}));
    
    scatter(g1, y_pos(i) + 0.15, 20, 'o', 'MarkerFaceColor', bu_td_colors(2, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
    scatter(g2, y_pos(i) - 0.15, 20, 'o', 'MarkerFaceColor', bu_td_colors(1, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.4);
end
xline(0, 'k--', 'LineWidth', 2);
set(gca, 'YTick', 1:size(comparisons, 1), 'YTickLabel', resultsTable_area.Comparison, 'FontSize', 11);
xlabel('Contrast Estimate (Difference in Hedges'' g)');
title('Contrast Estimates Across Brain Areas');
ylim([0.5, size(comparisons, 1) + 0.5]);
% saveToAI('/Users/aidanmulvey/Library/CloudStorage/OneDrive-Vanderbilt/Bastos Lab/Meta_analysis\Submissions\Translational Psychiatry\Figures Raw\EPS\Figure4', ...
%     'Fig4e Brain Area and Hierarchical Contrasts')
%% Save Tables to Excel Files
% dEMM
resultsTable_lam.p_FDR = mafdr(resultsTable_lam.PValue, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"BU/TD dEMM Layers", height(resultsTable_lam)};

BU_TD_CellArea_Tests = [resultsTable_area; resultsTable_cell];
BU_TD_CellArea_Tests.p_FDR = mafdr(BU_TD_CellArea_Tests.PValue, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"BU/TD dEMM Cell/Area", height(BU_TD_CellArea_Tests)};

BU_TD_Hypothesis_Tests = [resultsTable_lam; BU_TD_CellArea_Tests];
disp(BU_TD_Hypothesis_Tests)
% writetable(BU_TD_Hypothesis_Tests, 'HypothesisTests.csv')

% Anova
lam_stats_table = dataset2table(lam_stats);
lam_stats_table.p_FDR = mafdr(lam_stats_table.pValue, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"H1 Laminar Anova", height(lam_stats_table)};

cell_area_stats_table = dataset2table(cell_area_stats);
cell_area_stats_table.p_FDR = mafdr(cell_area_stats_table.pValue, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"H2/3 Cell/Area Anova", height(cell_area_stats_table)};

anova_table = [lam_stats_table; cell_area_stats_table];
disp(anova_table)

% EMMs
Laminar_EMM_Summary.p_FDR = mafdr(Laminar_EMM_Summary.P_Value, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"H1 BU/TD EMMs", height(Laminar_EMM_Summary)};

EMMs_CellArea = [Cell_EMM_Summary; Area_EMM_Summary];
EMMs_CellArea.p_FDR = mafdr(EMMs_CellArea.P_Value, 'BHFDR', true);

n_fdr_tests(end+1, :) = {"H2/3 Cell/Area EMMs", height(EMMs_CellArea)};

all_EMM_summary = [Laminar_EMM_Summary; EMMs_CellArea];
disp(all_EMM_summary)


CB = [
    mean(CB_IHC_dataframe.g); 
    mean(CB_mRNA_dataframe.g); 
    Master_H1_EMM_table.EMM(Master_H1_EMM_table.Label == "cb"); 
    Cell_EMM_Summary.Mean_Estimate(Cell_EMM_Summary.Label == "CB")
];

CR = [
    mean(CR_IHC_dataframe.g); 
    mean(CR_mRNA_dataframe.g); 
    Master_H1_EMM_table.EMM(Master_H1_EMM_table.Label == "cr"); 
    Cell_EMM_Summary.Mean_Estimate(Cell_EMM_Summary.Label == "CR")
];

Summary_Table = table(CB, CR, ...
    'RowNames', {'Forest_IHC', 'Forest_mRNA', 'Laminar_Model', 'Cellular_Model'});
%% Individual Cells Changing Across Areas
areas = ["Thalamus"; "Striatum"; "PPC"; "MCx"; "PCC"; "Hippocampus"; "EC"; "Amygdala"; "BrA"; "PFC"; "VCx"; "ACC"; "Midbrain"; "A1"];
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
    EMM_table.p_FDR = mafdr(EMM_table.("p(0)") , 'BHFDR', true);
    disp(EMM_table);
    area_EMMs.(target_cell) = EMM_table;

    n_fdr_tests(end+1, :) = {("Area EMMs Per Cell Type: " + target_cell), height(EMM_table)};

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

%% Plotting for All Combined
fields = fieldnames(area_EMMs);
all_labels = [];
for i = 1:numel(fields)
    all_labels = [all_labels; string(area_EMMs.(fields{i}).Label)];
end
unique_areas = unique(all_labels, 'stable');

% Initialize matrices for EMMs, CIs, and significance flags
emm_mat    = nan(numel(unique_areas), numel(fields));
low_ci_mat = nan(numel(unique_areas), numel(fields));
high_ci_mat= nan(numel(unique_areas), numel(fields));
p_mean_mat = nan(numel(unique_areas), numel(fields)); % For red stars (vs mean)
p_zero_mat = nan(numel(unique_areas), numel(fields)); % For black stars (vs zero)

for c = 1:numel(fields)
    T = area_EMMs.(fields{c});
    for a = 1:numel(unique_areas)
        row_idx = find(string(T.Label) == unique_areas(a));
        if ~isempty(row_idx)
            emm_mat(a, c)    = T.EMM(row_idx);
            low_ci_mat(a, c) = T.('95% CI')(row_idx, 1); 
            high_ci_mat(a, c)= T.('95% CI')(row_idx, 2);
            p_mean_mat(a, c) = T.("p(0)")(row_idx); % Update if using separate p_mean variable
        end
    end
end

neg_err = emm_mat - low_ci_mat;
pos_err = high_ci_mat - emm_mat;

num_groups = numel(unique_areas);
num_cells = numel(fields);
colors = [0 0 0; 0 0.4 0.7; 0.466 0.674 0.188; 0.850 0.325 0.098; 0.301 0.745 0.933];

figure('Position', [100, 100, 800, 900]); % Adjust figure size for better spacing
hold on;

% Expand the axis limits to give more breathing room per area block
ylim_padding = 0.25; 
set(gca, 'YLim', [0.5 - ylim_padding, num_groups + 0.5 + ylim_padding]);

for y_grid = 1.5:1:(num_groups - 0.5)
    line([-3.75, 3.75], [y_grid y_grid], 'Color', [0.85 0.85 0.85], ...
        'LineStyle', '--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

h_plots = gobjects(num_cells, 1);

for a = 1:num_groups
    valid_cell_indices = find(~isnan(emm_mat(a, :)));
    k = numel(valid_cell_indices);
    if k == 0; continue; end
    
    % Spread out markers more dynamically to avoid overlap
    if k == 1
        local_offsets = 0;
    else
        local_offsets = linspace(-0.35, 0.35, k); % Increased spread from 0.25 to 0.35
    end
    
    for i = 1:k
        cell_idx = valid_cell_indices(i);
        y_pos = a + local_offsets(i); % Offset along the categorical axis
        
        p = errorbar(emm_mat(a, cell_idx), y_pos, ...
            neg_err(a, cell_idx), pos_err(a, cell_idx), ...
            'horizontal', ... % Make error bars horizontal since axes are flipped
            'o', 'Color', colors(cell_idx,:), 'MarkerFaceColor', colors(cell_idx,:), ...
            'MarkerSize', 7, 'LineWidth', 1.2, 'CapSize', 3);
        
        if isgraphics(h_plots(cell_idx)) == 0
            h_plots(cell_idx) = p;
        end
        
        if ~isnan(p_mean_mat(a, cell_idx)) && p_mean_mat(a, cell_idx) < 0.05
            star_x = low_ci_mat(a, cell_idx) - 0.15; 
            text(star_x, y_pos, '*', 'Color', 'k', ...
                'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'HandleVisibility', 'off');
        end
    end
end

[~, loc] = ismember(lower(unique_areas), lower(areas));
matchedIdx = loc > 0;
unique_areas(matchedIdx) = areas(loc(matchedIdx));

xline(0, 'k-', 'LineWidth', 1, 'Alpha', 0.3, 'HandleVisibility', 'off'); 

set(gca, 'YTick', 1:num_groups, 'YTickLabel', unique_areas, ...
    'TickLabelInterpreter', 'none', ...
    'FontName', 'Arial', 'FontSize', 11);

h_xlabel = xlabel("EMM (Hedges' g)");
h_title = title("Estimated Marginal Mean of Areas by Cell Type", 'Fontweight', 'normal');
set([h_xlabel, h_title], 'FontName', 'Arial', 'FontSize', 12);
xlim([-3.75 3]);

legend_mask = isgraphics(h_plots);
h_leg = legend(h_plots(legend_mask), fields(legend_mask), 'Location', 'northwest', 'Box', 'off');
set(h_leg, 'FontName', 'Arial', 'FontSize', 12);
%% Individual Cells Changing Across LAYERS
layer_EMMs = struct();
for jj = 1:size(cell_types, 2)
    target_cell = cell_types{jj};
    try
        laminar_stacked_g = stack(laminar_study_table, {'L1_g', 'L2_g', 'L3_g', 'L4_g', 'L5_g', 'L6_g'}, ...
            'NewDataVariableName', 'g', 'IndexVariableName', 'Layer');
        laminar_stacked_var = stack(laminar_study_table, {'L1_var_g', 'L2_var_g', 'L3_var_g', 'L4_var_g', 'L5_var_g', 'L6_var_g'}, ...
            'NewDataVariableName', 'var_g', 'IndexVariableName', 'Layer_dummy');
        
        laminar_regr_tbl = laminar_stacked_g;
        laminar_regr_tbl.var_g = laminar_stacked_var.var_g;
        laminar_regr_tbl.Layer = categorical(strrep(string(laminar_regr_tbl.Layer), '_g', ''));
        
        laminar_regr_tbl = rmmissing(laminar_regr_tbl(:, {'g', 'var_g', 'Layer', 'Author', 'Structure', 'CellType', 'TissueBank', 'N_HC', 'N_SZ'}));
        laminar_regr_tbl((laminar_regr_tbl.g == 0) & (laminar_regr_tbl.var_g == 0), :) = []; 
        
        % Filter by target cell type
        laminar_regr_tbl = laminar_regr_tbl(laminar_regr_tbl.CellType == target_cell, :);
        
        laminar_regr_tbl.total_N = (laminar_regr_tbl.N_HC + laminar_regr_tbl.N_SZ);
        % laminar_regr_tbl.MethodType = categorical(lower(string(laminar_regr_tbl.MethodType)));
        laminar_regr_tbl.Area = categorical(lower(string(laminar_regr_tbl.Structure)));
        laminar_regr_tbl.Author = categorical(string(laminar_regr_tbl.Author));
        laminar_regr_tbl.Bank = categorical(lower(string(laminar_regr_tbl.TissueBank)));
        
        laminar_regr_tbl = rmmissing(laminar_regr_tbl);
        laminar_regr_tbl.Layer = removecats(laminar_regr_tbl.Layer);
        laminar_regr_tbl.Area = removecats(laminar_regr_tbl.Area);
        laminar_regr_tbl.Bank = removecats(laminar_regr_tbl.Bank);
        
        w = 1 ./ laminar_regr_tbl.var_g;
        hyp_formula = 'g ~ Layer + Area + total_N + (1|Bank) + (1|Author)';
        
        cell_type_indv = fitlme(laminar_regr_tbl, hyp_formula, 'Weights', w, 'DummyVarCoding', 'effects');
        
        intercept = cell_type_indv.Coefficients.Estimate(1);
        beta_values = cell_type_indv.Coefficients.Estimate;
        coef_names = cell_type_indv.CoefficientNames;
        cov_matrix = cell_type_indv.CoefficientCovariance;
        dfe = cell_type_indv.DFE;
        crit_t = tinv(0.975, dfe);
        
        figure;
        targetVar = 'Layer';
        all_possible = unique(laminar_regr_tbl.(targetVar), 'stable');
        idx = find(contains(coef_names, [targetVar '_']));
        visible_labels = erase(coef_names(idx), [targetVar '_']);
        hidden_label = setdiff(all_possible, visible_labels, 'stable');
        
        H_hidden_beta = zeros(1, numel(coef_names));
        H_hidden_beta(idx) = -1;
        H_hidden_emm = H_hidden_beta;
        H_hidden_emm(1) = 1; 
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
            H_vis_emm(1) = 1; 
            visible_emms(k) = H_vis_emm * beta_values;
            visible_ses_emm(k) = sqrt(H_vis_emm * cov_matrix * H_vis_emm');
            visible_p_vs_mean(k) = coefTest(cell_type_indv, H_vis_beta);
            visible_p_vs_zero(k) = coefTest(cell_type_indv, H_vis_emm);
        end
        
        all_labels = [visible_labels(:); hidden_label(:)];
        all_emms   = [visible_emms(:); hidden_emm_val];
        all_ses    = [visible_ses_emm(:); hidden_se_emm] * crit_t; 
        all_p_mean = [visible_p_vs_mean(:); hidden_p_vs_mean];
        all_p_zero = [visible_p_vs_zero(:); hidden_p_vs_zero];
        
        % SORT BY LAYER NAME (L1 to L6) INSTEAD OF EMM MAGNITUDE
        [sortedLabels, sortIdx] = sort(all_labels);
        sortedEMM   = all_emms(sortIdx);
        sortedErr   = all_ses(sortIdx);
        sortedPMean = all_p_mean(sortIdx);
        sortedPZero = all_p_zero(sortIdx);
        
        low_CI = sortedEMM - sortedErr;
        hi_CI = sortedEMM + sortedErr;
        CI = [low_CI, hi_CI];
        
        EMM_table = table(sortedLabels, sortedEMM, CI, sortedPZero, 'VariableNames', {'Label' 'EMM', '95% CI', 'p(0)'});
        EMM_table.p_FDR = mafdr(EMM_table.("p(0)") , 'BHFDR', true);
        disp(EMM_table);
        
        layer_EMMs.(target_cell) = EMM_table;
        
        hold on;
        errorbar(1:numel(sortedEMM), sortedEMM, sortedErr, sortedErr, ...
            'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.2 0.6 0.8], 'LineWidth', 1.5, 'CapSize', 8);
        
        for i = 1:numel(sortedEMM)
            if sortedPMean(i) < 0.05
                text(i, sortedEMM(i) + sortedErr(i) + 0.1, '*', 'Color', 'r', ...
                    'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
            end
            if sortedPZero(i) < 0.05
                text(i, sortedEMM(i) - sortedErr(i) - 0.15, '*', 'Color', 'k', ...
                    'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
            end
        end
        
        xticks(1:numel(sortedEMM));
        xticklabels(sortedLabels);
        ylabel('EMM (Hedges'' g)');
        title(['Vulnerability Across Layers of ', target_cell]);
        yline(0, 'k-', 'No Effect', 'LineWidth', 1.2);
        yline(intercept, 'k--', 'Grand Mean', 'Alpha', 0.5);
        grid on;
        ylim([min(sortedEMM - sortedErr) - 0.5, max(sortedEMM + sortedErr) + 0.5]);
        
    catch ME
        warning('Skipping cell type "%s" due to an error: %s', target_cell, ME.message);
        continue;
    end
end

% Plotting for all combined
fields = fieldnames(layer_EMMs); 
all_labels = [];
for i = 1:numel(fields)
    all_labels = [all_labels; string(layer_EMMs.(fields{i}).Label)];
end

colors = zeros(numel(fields), 3);
for i = 1:numel(fields)
    if isKey(cell_colors, fields{i})
        colors(i, :) = cell_colors(fields{i});
    else
        colors(i, :) = [0.5, 0.5, 0.5]; % Fallback gray for any unexpected cell type
    end
end

unique_layers = unique(all_labels, 'stable'); 
unique_layers = sort(unique_layers); 

emm_mat = nan(numel(unique_layers), numel(fields));
low_ci_mat = nan(numel(unique_layers), numel(fields));
high_ci_mat = nan(numel(unique_layers), numel(fields));
p_zero_mat = nan(numel(unique_layers), numel(fields)); 
p_mean_mat = nan(numel(unique_layers), numel(fields)); % Optional if tracking mean comparison

for c = 1:numel(fields)
    T = layer_EMMs.(fields{c});
    for a = 1:numel(unique_layers)
        row_idx = find(string(T.Label) == unique_layers(a));
        
        if ~isempty(row_idx)
            emm_mat(a, c) = T.EMM(row_idx);
            low_ci_mat(a, c) = T.('95% CI')(row_idx, 1); 
            high_ci_mat(a, c) = T.('95% CI')(row_idx, 2);
            p_zero_mat(a, c) = T.('p(0)')(row_idx);
        end
    end
end

neg_err = emm_mat - low_ci_mat;
pos_err = high_ci_mat - emm_mat;
num_groups = numel(unique_layers);
num_cells = numel(fields);

% Increased figure height for vertical breathing room
figure('Position', [100, 100, 900, 1100]);
hold on;

% Expand the axis limits to give more breathing room per layer block
ylim_padding = 0.25; 
set(gca, 'YLim', [0.5 - ylim_padding, num_groups + 0.5 + ylim_padding]);

for y_grid = 1.5:1:(num_groups - 0.5)
    line([-3, 3], [y_grid y_grid], 'Color', [0.85 0.85 0.85], ...
        'LineStyle', '--', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

h_plots = gobjects(num_cells, 1);

for a = 1:num_groups
    valid_cell_indices = find(~isnan(emm_mat(a, :)));
    k = numel(valid_cell_indices);
    if k == 0; continue; end
    
    % Wider spacing for cell types within the same layer
    if k == 1
        local_offsets = 0;
    else
        local_offsets = linspace(-0.42, 0.42, k);
    end
    
    for i = 1:k
        cell_idx = valid_cell_indices(i);
        y_pos = a + local_offsets(i);
        
        p = errorbar(emm_mat(a, cell_idx), y_pos, ...
            neg_err(a, cell_idx), pos_err(a, cell_idx), ...
            'horizontal', ...
            'o', 'Color', colors(cell_idx,:), ...
            'MarkerFaceColor', colors(cell_idx,:), ...
            'MarkerSize', 7, 'LineWidth', 1.2, 'CapSize', 3);
        
        if isgraphics(h_plots(cell_idx)) == 0
            h_plots(cell_idx) = p;
        end
        
        % Significance star positioned at the left tail (lower CI bound)
        if ~isnan(p_zero_mat(a, cell_idx)) && p_zero_mat(a, cell_idx) < 0.05
            star_x = low_ci_mat(a, cell_idx) - 0.15; 
            text(star_x, y_pos, '*', 'Color', 'k', ...
                'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', 'HandleVisibility', 'off');
        end
    end
end

xline(0, 'k-', 'LineWidth', 1, 'Alpha', 0.3, 'HandleVisibility', 'off'); 

set(gca, 'YTick', 1:num_groups, 'YTickLabel', unique_layers, ...
    'TickLabelInterpreter', 'none', ...
    'FontName', 'Arial', 'FontSize', 11);

h_xlabel = xlabel("EMM (Hedges' g)");
h_title = title("Estimated Marginal Mean of Layers by Cell Type", 'Fontweight', 'normal');
set([h_xlabel, h_title], 'FontName', 'Arial', 'FontSize', 12);
xlim([-3 2]);

legend_mask = isgraphics(h_plots);
h_leg = legend(h_plots(legend_mask), fields(legend_mask), 'Location', 'northwest', 'Box', 'off');
set(h_leg, 'FontName', 'Arial', 'FontSize', 12);
% ax1 = gca; set(ax1, 'Box', 'off', 'TickDir', 'out', 'Color', 'none', 'LineWidth', 1.2, 'LooseInset', max(get(gca, 'TightInset'), 0.02), 'TickLength', [0.02 0.025]);
%% Summary of Stats
% Raw Data
Table_of_All_Studies = complete_ref_table;
Table_of_All_Laminar_Studies = complete_laminar_table;

% PV_IHC_heatmap_data; CB_IHC_heatmap_data; CR_IHC_heatmap_data; SST_IHC_heatmap_data;
% PV_mRNA_heatmap_data; CB_mRNA_heatmap_data; CR_mRNA_heatmap_data; SST_mRNA_heatmap_data;

% Sensitivity Analyses:
heterogeneity = het_table; % ID: c001
publication_bias; % ID: c002
leave_one_out_results = manuscript_reporting_tbl; % ID: c003

% Layer Specific:
Cohens_laminar_comparisons = All_Comparisons_Stats; % ID: d001
Laminar_effect_sizes = layers_effects_table; % ID: d002

% Structure Level:
PV_IHC_area_stats = PV_IHC_2_stats; % ID: e001
CB_IHC_area_stats = CB_IHC_2_stats; % ID: e002
CR_IHC_area_stats = CR_IHC_2_stats; % ID: e003
SST_IHC_area_stats = SST_IHC_2_stats; % ID: e004

PV_mRNA_area_stats = PV_mRNA_2_stats; % ID: e005
CB_mRNA_area_stats = CB_mRNA_2_stats; % ID: e006
CR_mRNA_area_stats = CR_mRNA_2_stats; % ID: e007
SST_mRNA_area_stats = SST_mRNA_2_stats; % ID: e008

Cohens_comparisons_cell_types = cell_type_PFC_cohens; % ID: e009

% Group Level:
PFC_group_results = PFC_results_table; % ID: f001
Hippocampus_group_results = Hippocampus_results_table; % ID: f002
Cohens_comparisons_groups = group_level_comps; % ID: f003

% Model Results:
EMM_diffs_from_zero = all_EMM_summary; % ID: a001
BU_TD_Hypothesis_Tests; % ID: a002

Demographics_Model_Anova = demo_anova; % Model 1; ID: a003
Cell_Area_Model_Anova = cell_area_stats_table; % Model 2; ID: a004
Laminar_Model_Anova = lam_stats_table; % Model 3; ID: a005

Model_1_demographics_Coefficients = demographics_coefficients; % ID: a006
Model_2_cell_area_Coefficients = dataset2table(coef_table_cell_area); % ID: a007
Model_3_laminar_Coefficients = dataset2table(laminar_regression.Coefficients); % ID: a008

Number_of_tests_per_FDR_family = n_fdr_tests; % ID: a009

% Standardized Resource:
Cell_Area_EMMs = Master_H2_EMM_Table; % ID: b001
Cell_Layer_EMMs = Master_H1_EMM_table; % ID: b002
Cells_by_Layer_EMMs = layer_EMMs; % ID: b003
Cells_by_Area_EMMs = area_EMMs; % ID: b004

%%
dataframes = struct();
dataframes.PV_IHC = PV_IHC_dataframe;
dataframes.CB_IHC = CB_IHC_dataframe;
dataframes.CR_IHC = CR_IHC_dataframe;
dataframes.SST_IHC = SST_IHC_dataframe;
dataframes.PV_mRNA = PV_mRNA_dataframe;
dataframes.CB_mRNA = CB_mRNA_dataframe;
dataframes.CR_mRNA = CR_mRNA_dataframe;
dataframes.SST_mRNA = SST_mRNA_dataframe;

df_labels = fieldnames(dataframes);

for jj = 1:length(df_labels)
    current_struct = dataframes.(df_labels{jj});
    unique_areas = unique(current_struct.Structure);

    var_name = [df_labels{jj} '_summary'];
    
    var_table = table();
    for ii = 1:length(unique_areas)
        unique_structure = unique_areas(ii);

        working_data = current_struct(ismember(current_struct.Structure, unique_structure), :);

        new_row = table(unique_structure, ...
                        mean(working_data.g, 'omitnan'), ...
                        height(working_data), ...
                        height(unique(working_data.Author)), ...
                        'VariableNames', {'Structure', 'mean_g', 'N_o', 'N_s'});
                    
        var_table = [var_table; new_row];

    end

    dataframes.(var_name) = var_table;
end


%% Formatting and Extracting Effect Sizes for Supp Table 1

methods = unique(complete_ref_table.MethodType);
method_tables = struct();

for jj = 1:numel(methods)
    current_method = methods(jj);
    
    % Ensure method name is safe for structure field naming
    safeMethodName = matlab.lang.makeValidName(string(current_method));
    
    input_ref = complete_ref_table(strcmp(complete_ref_table.MethodType, current_method), :);
    
    if height(input_ref) == 0
        continue;
    end
    
    Authors = input_ref.Author;
    Areas = input_ref.Abbv;
    CellTypes = input_ref.CellType;
    g_vals = input_ref.g;
    var_g_vals = input_ref.var_g;
    
    formattedData = cell(height(input_ref), 1);
    for i = 1:height(input_ref)
        formattedData{i} = sprintf('%s: %.3f ± %.3f', Areas{i}, g_vals(i), var_g_vals(i));
    end
    
    T_work = table(Authors, CellTypes, formattedData, 'VariableNames', {'Author', 'CellType', 'Metric'});
    [G, authorKeys, cellKeys] = findgroups(T_work.Author, T_work.CellType);
    combinedMetrics = splitapply(@(x) {strjoin(x, newline)}, T_work.Metric, G);
    T_grouped = table(authorKeys, cellKeys, combinedMetrics, 'VariableNames', {'Author', 'CellType', 'CombinedMetrics'});
    
    uniqueAuthors = unique(T_grouped.Author);
    uniqueCellTypes = unique(T_grouped.CellType);
    numAuthors = length(uniqueAuthors);
    numCellTypes = length(uniqueCellTypes);
    
    validCellNames = matlab.lang.makeValidName(string(uniqueCellTypes));
    dataCell = cell(numAuthors, numCellTypes + 1);
    dataCell(:, 1) = uniqueAuthors;
    
    for i = 1:numAuthors
        currAuthor = uniqueAuthors{i};
        for j = 1:numCellTypes
            currCellType = uniqueCellTypes{j};
            matchIdx = strcmp(T_grouped.Author, currAuthor) & strcmp(T_grouped.CellType, currCellType);
            if any(matchIdx)
                dataCell{i, j + 1} = T_grouped.CombinedMetrics{matchIdx};
            else
                dataCell{i, j + 1} = 'NA';
            end
        end
    end
    
    varNames = [{'Author'}, cellstr(validCellNames)'];
    T_final = cell2table(dataCell, 'VariableNames', varNames);
    
    desiredOrder = {'PV', 'CB', 'CR', 'SST'};
    existingCols = T_final.Properties.VariableNames;
    presentCols = desiredOrder(ismember(desiredOrder, existingCols));
    otherCols = setdiff(existingCols, [{'Author'}, presentCols], 'stable');
    newColOrder = [{'Author'}, presentCols, otherCols];
    T_final = T_final(:, newColOrder);
    
    for col = 2:width(T_final)
        T_final.(col) = string(T_final{:, col});
    end
    
    method_tables.(safeMethodName) = T_final;
end
%%
methods = unique(complete_laminar_table.MethodType);

for jj = 1:numel(methods)
    current_method = methods(jj);

    method_name = append(current_method, "_Laminar");
    
    input_ref = complete_laminar_table(strcmp(complete_laminar_table.MethodType, current_method), :);
    if height(input_ref) == 0, continue; end
    
    Authors = input_ref.Author;
    Areas = input_ref.Abbv;
    CellTypes = input_ref.CellType;
    
    % 1. Build multi-laminar text string for each row (L1 to L6)
    formattedData = cell(height(input_ref), 1);
    for i = 1:height(input_ref)
        lamText = {};
        for L = 1:6
            g_colName = sprintf('L%d_g', L);
            v_colName = sprintf('L%d_var_g', L);
            
            % Check if columns exist and value is not NaN
            if any(strcmp(input_ref.Properties.VariableNames, g_colName))
                g_val = input_ref{i, g_colName};
                v_val = input_ref{i, v_colName};
                
                if ~isnan(g_val)
                    lamStr = sprintf('%s (L%d): %.3f ± %.3f', Areas{i}, L, g_val, v_val);
                    lamText{end+1} = lamStr;
                end
            end
        end
        formattedData{i} = strjoin(lamText, newline);
    end
    
    T_work = table(Authors, CellTypes, formattedData, 'VariableNames', {'Author', 'CellType', 'Metric'});
    [G, authorKeys, cellKeys] = findgroups(T_work.Author, T_work.CellType);
    combinedMetrics = splitapply(@(x) {strjoin(x, newline)}, T_work.Metric, G);
    T_grouped = table(authorKeys, cellKeys, combinedMetrics, 'VariableNames', {'Author', 'CellType', 'CombinedMetrics'});
    
    % 2. Dynamically extract unique authors present in this method subset
    uniqueAuthors = unique(T_grouped.Author);
    uniqueCellTypes = unique(T_grouped.CellType);
    numAuthors = length(uniqueAuthors);
    numCellTypes = length(uniqueCellTypes);
    
    validCellNames = matlab.lang.makeValidName(string(uniqueCellTypes));
    dataCell = cell(numAuthors, numCellTypes + 1);
    dataCell(:, 1) = uniqueAuthors;
    
    % 3. Populate data cells
    for i = 1:numAuthors
        currAuthor = uniqueAuthors{i};
        for j = 1:numCellTypes
            currCellType = uniqueCellTypes{j};
            
            matchIdx = strcmp(T_grouped.Author, currAuthor) & ...
                       strcmp(T_grouped.CellType, currCellType);
                   
            if any(matchIdx)
                dataCell{i, j + 1} = strjoin(T_grouped.CombinedMetrics(matchIdx), newline);
            else
                dataCell{i, j + 1} = 'NA';
            end
        end
    end
    
    varNames = [{'Author'}, cellstr(validCellNames)'];
    T_final = cell2table(dataCell, 'VariableNames', varNames);
    
    % Reorder columns
    desiredOrder = {'PV', 'CB', 'CR', 'SST'};
    existingCols = T_final.Properties.VariableNames;
    presentCols = desiredOrder(ismember(desiredOrder, existingCols));
    otherCols = setdiff(existingCols, [{'Author'}, presentCols], 'stable');
    T_final = T_final(:, [{'Author'}, presentCols, otherCols]);
    
    % Convert columns to string to avoid quotes in Excel
    for col = 2:width(T_final)
        T_final.(col) = string(T_final{:, col});
    end
    
    method_tables.(method_name) = T_final;
    % writetable(T_final, sprintf('laminar_meta_analysis_%s.xlsx', char(safeMethodName)));
end
%%

CB_studies = complete_study_table(complete_study_table.CellType == "CB", :);

CB_removed_pyrams = complete_study_table.g(ismember(CB_studies.Author, ["Tooney & Chahl, 2004"; "Daviss & Lewis, 1995"]));
CB_kept_pyrams = complete_study_table.g(~ismember(CB_studies.Author, ["Tooney & Chahl, 2004"; "Daviss & Lewis, 1995"]));

compute_cohens(CB_removed_pyrams, CB_kept_pyrams, "CB Studies Pyramidal")