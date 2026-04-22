# sim-map
Schizophrenia Interneuron Metanalysis (SIM) Mapping: A meta-analysis of GABAergic interneuron pathology in schizophrenia. The present manuscript is currently in preparation, but an older version can be found at https://www.biorxiv.org/content/10.1101/2025.05.23.655812v2. Use of this data should properly cite the paper. Data include raw data for interneuron cell density and mRNA expression. Code is scripted for MATLAB_R2024a and other versions may have issues.

# Data Dictionary
- Main analysis scripts can be found in codes folder
- Include functions folder in path of main script
- Raw_Data_Excel contains all the raw data (cell densities, mRNA expressions, etc.) prior to analysis and is called by the main script
- Processed_Data contains estimated marginal means (EMMS) per interneuron type, cortical layer, and brain area, as well as Hedges' g effect sizes per study

# Estimated Marginal Means
- EMMs are denoised, standardized effect sizes (Hedges' g)
- File SIM Open Resource EMM Data.xlsx contains all the EMMs per linear mixed-effects model, which simply represent the Hedges' g effect size while controlling for covariates.
