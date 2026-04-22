function reference_table = getInfo(table1, input_table, ref_cell_type, ref_method, inputRange)
% tissue_bank_codes = importExcel('Table_1_Excel.xlsx', 'Banks');
% fixation_codes = importExcel('Table_1_Excel.xlsx', 'Fixation');

% N1 = reference_table.N_HC;
% N2 = reference_table.N_SZ;
% df = N1 + N2 - 2;
% J = 1 - 3/(4*df - 1);
% var_g = J^2 * ( (N1+N2)/(N1*N2) + reference_table.t_score^2/(2*(N1+N2)) );
% se_g  = sqrt(var_g);
reference_table = input_table;

num_ref_rows = height(input_table);
matching_indices = NaN(num_ref_rows, 1); % Initialize an array to store matching indices from table1

for i = 1:num_ref_rows
    ref_author = input_table.Author{i};
    if contains(ref_author, '(')
        ref_author = extractBefore(ref_author, ' (');
    end
    ref_region = num2str(input_table.Abbv{i});

    for j = inputRange
        table1_author = append(table1.Author(j), ', ', num2str(table1.Year(j)));
        table1_region = table1.Area{j};
        table1_cell_types = table1.('Cell Type'){j}; % Cell type information from table1

        % Check for author and brain region match
        author_match = strcmpi(ref_author, table1_author);
        region_match = contains(table1_region, ref_region);
        cell_match = contains(table1_cell_types, ref_cell_type);

        if author_match && cell_match
            matching_indices(i) = j;
            break; % Move to the next row in PV_IHC_ref_table once a match is found
        end
    end
end

indices = matching_indices;
reference_table.Method = table1.Method(indices);
reference_table.TissueBank = table1.("Tissue Obtained")(indices);
reference_table.FixMethod = table1.("Fixation Method")(indices);
reference_table.TissueBankCode = table1.("Bank Code")(indices);
reference_table.FixMethodCode = table1.("Fixation Code")(indices);

HC_age_cell = extractBefore((table1.("HC Age (Mean ± SD, years)")(indices)), ' ±');
SZ_age_cell = extractBefore((table1.("SZ Age (Mean ± SD, years)")(indices)), ' ±');

HC_ph = extractBefore((table1.("HC Brain pH (Mean ± SD)")(indices)), ' ±');
SZ_ph = extractBefore((table1.("SZ Brain pH")(indices)), ' ±');

HC_pmi = extractBefore((table1.("HC PMI (Mean ± SD, hours)")(indices)), ' ±');
SZ_pmi = extractBefore((table1.("SZ PMI (Mean ± SD, hours)")(indices)), ' ±');

HC_sex_cell_M = extractBefore((table1.("HC Sex")(indices)), 'M');
HC_sex_cell_F = extractBefore(extractAfter((table1.("HC Sex")(indices)), '/'), 'F');

SZ_sex_cell_M = extractBefore((table1.("SZ Sex")(indices)), 'M');
SZ_sex_cell_F = extractBefore(extractAfter((table1.("SZ Sex")(indices)), '/'), 'F');

HC_ages = zeros(length(indices), 1); SZ_ages = zeros(length(indices), 1);
HC_sex_ratio = zeros(length(indices), 1); SZ_sex_ratio = zeros(length(indices), 1);
HC_PH = zeros(length(indices), 1); SZ_PH = zeros(length(indices), 1);
HC_PMI = zeros(length(indices), 1); SZ_PMI = zeros(length(indices), 1);
for a = 1:length(HC_age_cell)
    HC_ages(a, 1) = str2double(HC_age_cell{a});
    SZ_ages(a, 1) = str2double(SZ_age_cell{a});

    HC_sex_ratio(a, 1) = str2double(HC_sex_cell_F{a}) / str2double(HC_sex_cell_M{a});
    SZ_sex_ratio(a, 1) = str2double(SZ_sex_cell_F{a}) / str2double(SZ_sex_cell_M{a});

    HC_PH(a, 1) = str2double(HC_ph{a});
    SZ_PH(a, 1) = str2double(SZ_ph{a});

    HC_PMI(a, 1) = str2double(HC_pmi{a});
    SZ_PMI(a, 1) = str2double(SZ_pmi{a});
end

reference_table.HC_ages = HC_ages;
reference_table.SZ_ages = SZ_ages;

reference_table.HC_sex_ratio = HC_sex_ratio;
reference_table.SZ_sex_ratio = SZ_sex_ratio;

reference_table.HC_PH = HC_PH;
reference_table.SZ_PH = SZ_PH;

reference_table.HC_PMI = HC_PMI;
reference_table.SZ_PMI = SZ_PMI;

reference_table.CellType(:) = ref_cell_type;
reference_table.MethodType(:) = ref_method;

end

%%
