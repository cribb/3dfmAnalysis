function [N, D, V, DV, DR, DA, DRV, DAV, msd_params] = model_constants(models);

% MODEL_CONSTANTS generates COLUMN CONSTANTS for each MODEL TYPE for BAYES ANALYSIS OUTPUTS
%
% Panoptes function-supplement to Bayes function
%  
% last modified 9/5/13 (yingzhou)
%

if nargin<1||isempty(models) 
   msd_params.models = {'N', 'D', 'V', 'DV', 'DR', 'DA', 'DRV', 'DAV'};
else
   msd_params.models = models; 
end


N = find(ismember(msd_params.models,'N'))+1;
D = find(ismember(msd_params.models, 'D'))+1;
V = find(ismember(msd_params.models,'V'))+1;
DV = find(ismember(msd_params.models,'DV'))+1;
DR = find(ismember(msd_params.models,'DR'))+1;
DA = find(ismember(msd_params.models,'DA'))+1;
DRV = find(ismember(msd_params.models,'DRV'))+1;
DAV = find(ismember(msd_params.models,'DAV'))+1;

return

