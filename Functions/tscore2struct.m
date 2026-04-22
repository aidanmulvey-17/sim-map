function effects_struct = tscore2struct(data_table)

structures = data_table.Structure;
numbers = data_table.Area;
effects = data_table.g;

effects_struct = struct();

areaGroups = unique(structures);
for i = 1:length(areaGroups)
    varName = [areaGroups{i} '_effect'];

    effects_data = effects(ismember(structures, areaGroups{i}));
    area_numbers = numbers(ismember(structures, areaGroups{i}));
    
    if ~isempty(effects_data)
        effects_struct.(varName)(:, 1) = area_numbers;
        effects_struct.(varName)(:, 2) = effects_data;
        %assignin('base', varName, tscore_data);
    end
end

end