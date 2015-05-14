function [bayes_output] = bayes_on_orig_data(filename)
% BAYES_ON_ORIG_DATA
%
% Last modified: 2/4/14, Luke Osborne 
%
% inputs:   filename         this is a video, which may have multiple trackers
%           %
% outputs:  bayes_output     matrix of tracker IDs and model types
% 
%
%
% this function is responsible for 
%   - loading aggregate data set
%   - performing Bayesian analysis


video_tracking_constants;                                                   % TIME,ID,FRAME,X,Y... for column headers


%%% loose ends: these are things I suspect need to be inputs to this
%%% function or should be outputs that of another function that
%%% bayes_sub_master calls.
frame_rate = 30;
msd_params = {'N', 'D', 'V', 'DV', 'DR', 'DA', 'DRV', 'DAV'};


data = load_video_tracking(filename, frame_rate, 'm', 0.152, ...
                           'absolute', 'no', 'table');                      % loads aggregate data set


data_msdcalc = video_msd(data, 35, frame_rate, 0.152, 'n');

plot_msd(data_msdcalc, [], 'ame');                       
                       
                       


bayes_results = msd_curves_bayes(data_msdcalc.tau(:,1), ...
                                     data_msdcalc.msd*1E12, msd_params);         % computes Bayesian statistics on MSDs of orginal video
    

% These are included for code development purposes; will be removed
% eventually.

bayes_table (1,:) = [bayes_results.mean_curve.N.C bayes_results.mean_curve.N.PrM];
bayes_table (2,:) = [bayes_results.mean_curve.D.D bayes_results.mean_curve.D.PrM];

bayes_table (3,:) = [bayes_results.mean_curve.DA.D bayes_results.mean_curve.DA.PrM];
bayes_table (4,:) = [bayes_results.mean_curve.DA.A bayes_results.mean_curve.DA.PrM];

bayes_table (5,:) = [bayes_results.mean_curve.DR.D bayes_results.mean_curve.DR.PrM];
bayes_table (6,:) = [bayes_results.mean_curve.DR.R bayes_results.mean_curve.DR.PrM];

bayes_table (7,:) = [bayes_results.mean_curve.V.V bayes_results.mean_curve.V.PrM];

bayes_table (8,:) = [bayes_results.mean_curve.DV.D bayes_results.mean_curve.DV.PrM];
bayes_table (9,:) = [bayes_results.mean_curve.DV.V bayes_results.mean_curve.DV.PrM];

bayes_table (10,:) = [bayes_results.mean_curve.DAV.D bayes_results.mean_curve.DAV.PrM];
bayes_table (11,:) = [bayes_results.mean_curve.DAV.A bayes_results.mean_curve.DAV.PrM];
bayes_table (12,:) = [bayes_results.mean_curve.DAV.V bayes_results.mean_curve.DAV.PrM];

bayes_table (13,:) = [bayes_results.mean_curve.DRV.D bayes_results.mean_curve.DRV.PrM];
bayes_table (14,:) = [bayes_results.mean_curve.DRV.R bayes_results.mean_curve.DRV.PrM];
bayes_table (15,:) = [bayes_results.mean_curve.DRV.V bayes_results.mean_curve.DRV.PrM];


bayes_output.results = bayes_results;
bayes_output.table = bayes_table;






% bayes_table (1,:) = [bayes_results.mean_curve.N.C bayes_results.mean_curve.N.C_se bayes_results.mean_curve.N.PrM];
% bayes_table (2,:) = [bayes_results.mean_curve.D.D bayes_results.mean_curve.D.D_se bayes_results.mean_curve.D.PrM];
% 
% bayes_table (3,:) = [bayes_results.mean_curve.DA.D bayes_results.mean_curve.DA.D_se bayes_results.mean_curve.DA.PrM];
% bayes_table (4,:) = [bayes_results.mean_curve.DA.A bayes_results.mean_curve.DA.A_se bayes_results.mean_curve.DA.PrM];
% 
% bayes_table (5,:) = [bayes_results.mean_curve.DR.D bayes_results.mean_curve.DR.D_se bayes_results.mean_curve.DR.PrM];
% bayes_table (6,:) = [bayes_results.mean_curve.DR.R bayes_results.mean_curve.DR.R_se bayes_results.mean_curve.DR.PrM];
% 
% bayes_table (7,:) = [bayes_results.mean_curve.V.V bayes_results.mean_curve.V.V_se bayes_results.mean_curve.V.PrM];
% 
% bayes_table (8,:) = [bayes_results.mean_curve.DV.D bayes_results.mean_curve.DV.D_se bayes_results.mean_curve.DV.PrM];
% bayes_table (9,:) = [bayes_results.mean_curve.DV.V bayes_results.mean_curve.DV.V_se bayes_results.mean_curve.DV.PrM];
% 
% bayes_table (10,:) = [bayes_results.mean_curve.DAV.D bayes_results.mean_curve.DAV.D_se bayes_results.mean_curve.DAV.PrM];
% bayes_table (11,:) = [bayes_results.mean_curve.DAV.A bayes_results.mean_curve.DAV.A_se bayes_results.mean_curve.DAV.PrM];
% bayes_table (12,:) = [bayes_results.mean_curve.DAV.V bayes_results.mean_curve.DAV.V_se bayes_results.mean_curve.DAV.PrM];
% 
% bayes_table (13,:) = [bayes_results.mean_curve.DRV.D bayes_results.mean_curve.DRV.D_se bayes_results.mean_curve.DRV.PrM];
% bayes_table (14,:) = [bayes_results.mean_curve.DRV.R bayes_results.mean_curve.DRV.R_se bayes_results.mean_curve.DRV.PrM];
% bayes_table (15,:) = [bayes_results.mean_curve.DRV.V bayes_results.mean_curve.DRV.V_se bayes_results.mean_curve.DRV.PrM];








end
