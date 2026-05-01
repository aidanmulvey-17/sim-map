function laminarComparison(PV_pfc_sup,PV_pfc_deep, cellType, areasIncluded)

    disp(append('--------------', cellType, ' in ', areasIncluded, '--------------'))
[~, p] = ttest(squeeze(PV_pfc_sup));
    disp(append('Superficial has a p-value = ', num2str(p)))
[~, p] = ttest(squeeze(PV_pfc_deep));
 disp(append('Deep has a p-value = ', num2str(p)))
[~, p] = ttest2(PV_pfc_sup, PV_pfc_deep);
     disp(append('Comparing them gives a p-value = ', num2str(p)))


    % sem_sup = std(PV_pfc_sup) / sqrt(length(PV_pfc_sup));
    % sem_deep = std(PV_pfc_deep) / sqrt(length(PV_pfc_deep));
    % 

     figure;
     hist = histogram(PV_pfc_sup, 'NumBins', 10);
     hold on;
     pd = fitdist(PV_pfc_sup, 'Normal');
     x_values_sup = linspace(-20, 20, 100);
     y_values_sup = pdf(pd, x_values_sup);
     y_values_sup = y_values_sup / max(y_values_sup);
     plot(x_values_sup, y_values_sup * (max(hist.Values)+0.05), 'k', 'LineWidth', 2);
     [~, p] = ttest(squeeze(PV_pfc_sup));
     superficial_p = append('Superficial p-value = ', num2str(p));

     hist = histogram(PV_pfc_deep, 'NumBins', 10);
     pd = fitdist(PV_pfc_deep, 'Normal');
     x_values_deep = linspace(-20, 20, 100);
     y_values_deep = pdf(pd, x_values_deep);
     y_values_deep = y_values_deep / max(y_values_deep);
     plot(x_values_deep, y_values_deep * (max(hist.Values)+0.05), 'b', 'LineWidth', 2);
     [~, p] = ttest(squeeze(PV_pfc_deep));
     deep_p = append('Deep p-value = ', num2str(p));

     legend(superficial_p, deep_p);

     xlim([-20 20]);
     xline(0, 'r--', 'LineWidth', 2);
     ylabel('Count'); xlabel('t-score');
     [~, p] = ttest2(PV_pfc_sup, PV_pfc_deep);
     title(append(cellType, ' Cells in ', areasIncluded,' Superficial vs. Deep Layers | p = ', num2str(p)));
end