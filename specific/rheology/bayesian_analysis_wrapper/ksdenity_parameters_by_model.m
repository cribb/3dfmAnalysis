function [N_N, D_D, V_V, DV_D, DV_V, DR_D, DR_R, DA_D, DA_A, DRV_D, DRV_R, DRV_V, DAV_D, DAV_A, DAV_V] = ksdenity_parameters_by_model(filename)
%
% ksdensity_parameters_by_model
% yingzhou\desktop\MSD Bayes\Panoptes Functions
% last modified 07/10/13 (yingzhou) 2:58pm -Code is in the process of being
% modified
%
% ksdensity_parameters_by_model plots the distribution function of the
% paramter
% values (not currently, need to add this feature)
% at a given tau=1s of the MOST PREVALENT MODELS (accounting for >15% of
% the data) in the data set. Separate figures for each parameter need to
% be created. 
%
% where 
%   "filename" is the name of the outs_bayes structure saved by
%   Bayesian_analysis, e.g. 'Bayes_results_T24.mat'
%

[N, D, V, DV, DR, DA, DRV, DAV] = model_constants;

load(filename);

N_count = sum(outs_bayes.prob(:,N)>=0.5);
D_count = sum(outs_bayes.prob(:,D)>=0.5);
V_count = sum(outs_bayes.prob(:,V)>=0.5);
DV_count = sum(outs_bayes.prob(:,DV)>=0.5);
DR_count = sum(outs_bayes.prob(:,DR)>=0.5);
DA_count = sum(outs_bayes.prob(:,DA)>=0.5);
DRV_count = sum(outs_bayes.prob(:,DRV)>=0.5);
DAV_count = sum(outs_bayes.prob(:,DAV)>=0.5);

num_trackers = length(outs_bayes.idlist);

N_N=[];
D_D=[];
V_V=[];
DV_D=[];
DV_V=[];
DR_D=[];
DR_R=[];
DA_D=[];
DA_A=[];
DRV_D=[];
DRV_R=[];
DRV_V=[];
DAV_D=[];
DAV_A=[];
DAV_V=[];

if N_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,N)>=0.5))
        idx = outs_bayes.idlist(i)
% d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         
        N_N = [N_N outs_bayes.N(i,N)] %records the N-parameter value if this was the 'N' model had probability higher than 50%.
    end
end

if D_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,D)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');         
        D_D = [D_D outs_bayes.D(i,D)]
    end
end

if V_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,V)>=0.5))
    	idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         
         V_V = [V_V outs_bayes.V(i,V)]
    end
end

if DV_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DV)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         
         DV_D = [DV_D outs_bayes.D(i,DV)]
         DV_V = [DV_V outs_bayes.V(i,DV)]
    end
end

if DR_count/num_trackers> 0.15
     for i = transpose(find(outs_bayes.prob(:,DR)>=0.5))
         idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         DR_D = [DR_D outs_bayes.D(i,DR)]
         DR_R = [DR_R outs_bayes.Rc(i,DR)]
    end
end

if DA_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DA)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         DA_D = [DA_D outs_bayes.D(i,DA)]
         DA_A = [DA_A outs_bayes.A(i,DA)]
    end
end

if DRV_count/num_trackers> 0.15
    for  i = transpose(find(outs_bayes.prob(:,DRV)>=0.5))
         idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         DRV_D = [DRV_D outs_bayes.D(i,DRV)]
         DRV_R = [DRV_R outs_bayes.Rc(i,DRV)]
         DRV_R = [DRV_V outs_bayes.Rc(i,DRV)]
    end
end

if DAV_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DAV)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         DAV_D = [DAV_D outs_bayes.D(i,DAV)]
         DAV_A = [DAV_A outs_bayes.A(i,DAV)]
         DAV_V = [DAV_V outs_bayes.V(i,DAV)]
    end
end

