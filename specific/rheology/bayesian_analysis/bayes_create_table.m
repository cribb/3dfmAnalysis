function [table] = bayes_create_table(bayes_results)
%BAYES_CREATE_TABLE 
%
% Created:       2/5/13, Luke Osborne 
% Last modified: 2/5/14, Luke Osborne 
%
% inputs:   bayes_results   this is the output structure from msd_curves_bayes MIT code function
%           
% outputs:  table           table that has             
% 
%
%
% this function is responsible for 
%   - taking in output from msd_curves_bayes
%   - generating table


if isempty(bayes_results) == 0

    bayes_table (1,:) = [bayes_results.mean_curve.N.C bayes_results.mean_curve.N.C_se bayes_results.mean_curve.N.PrM];
    bayes_table (2,:) = [bayes_results.mean_curve.D.D bayes_results.mean_curve.D.D_se bayes_results.mean_curve.D.PrM];

    bayes_table (3,:) = [bayes_results.mean_curve.DA.D bayes_results.mean_curve.DA.D_se bayes_results.mean_curve.DA.PrM];
    bayes_table (4,:) = [bayes_results.mean_curve.DA.A bayes_results.mean_curve.DA.A_se bayes_results.mean_curve.DA.PrM];

    bayes_table (5,:) = [bayes_results.mean_curve.DR.D bayes_results.mean_curve.DR.D_se bayes_results.mean_curve.DR.PrM];
    bayes_table (6,:) = [bayes_results.mean_curve.DR.R bayes_results.mean_curve.DR.R_se bayes_results.mean_curve.DR.PrM];

    bayes_table (7,:) = [bayes_results.mean_curve.V.V bayes_results.mean_curve.V.V_se bayes_results.mean_curve.V.PrM];

%     bayes_table (8,:) = [bayes_results.mean_curve.DV.D bayes_results.mean_curve.DV.PrM];
%     bayes_table (9,:) = [bayes_results.mean_curve.DV.V bayes_results.mean_curve.DV.PrM];
% 
%     bayes_table (10,:) = [bayes_results.mean_curve.DAV.D bayes_results.mean_curve.DAV.PrM];
%     bayes_table (11,:) = [bayes_results.mean_curve.DAV.A bayes_results.mean_curve.DAV.PrM];
%     bayes_table (12,:) = [bayes_results.mean_curve.DAV.V bayes_results.mean_curve.DAV.PrM];
% 
%     bayes_table (13,:) = [bayes_results.mean_curve.DRV.D bayes_results.mean_curve.DRV.PrM];
%     bayes_table (14,:) = [bayes_results.mean_curve.DRV.R bayes_results.mean_curve.DRV.PrM];
%     bayes_table (15,:) = [bayes_results.mean_curve.DRV.V bayes_results.mean_curve.DRV.PrM];

else
    
    bayes_table (1,:)  = [NaN NaN NaN];
    bayes_table (2,:)  = [NaN NaN NaN];
    bayes_table (3,:)  = [NaN NaN NaN];
    bayes_table (4,:)  = [NaN NaN NaN];
    bayes_table (5,:)  = [NaN NaN NaN];
    bayes_table (6,:)  = [NaN NaN NaN];
    bayes_table (7,:)  = [NaN NaN NaN];
%     bayes_table (8,:)  = [NaN NaN];
%     bayes_table (9,:)  = [NaN NaN];
%     bayes_table (10,:) = [NaN NaN];
%     bayes_table (11,:) = [NaN NaN];
%     bayes_table (12,:) = [NaN NaN];
%     bayes_table (13,:) = [NaN NaN];
%     bayes_table (14,:) = [NaN NaN];
%     bayes_table (15,:) = [NaN NaN];
    
end 



% Collecting outputs

table = bayes_table;






end

