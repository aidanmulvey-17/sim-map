function [cohens_d,cohens_se] = cohens(A, SEM_A, N_A, B, SEM_B, N_B)
% Input the mean of the controls as A, the SEM of the control and the
% sample size of controls. B is the disease group. A small negative value
% means that group B is slightly larger than A. The more positive the
% value, the larger group A is compared to group B.

SD_A = SEM_A .* sqrt(N_A);
SD_B = SEM_B .* sqrt(N_B);
s_pooled = sqrt( ((N_B-1).*(SD_B.^2) + (N_A-1).*(SD_A.^2)) ./ (N_B + N_A - 2) );

cohens_d = (A - B) ./ s_pooled;

cohens_se = sqrt( ((N_A + N_B) ./ (N_A .* N_B)) + (cohens_d.^2 ./ (2*(N_A + N_B))));

end