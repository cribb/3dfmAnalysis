function MSDs_dominant_modes_only(filename, filename_original, expt_type)

%
% MSDs_dominant_modes_only
% yingzhou\desktop\MSD Bayes\Panoptes Functions
% last modified 07/10/13 (yingzhou) 
%
%
%ksdensity_main_MT_MSDs plots the distribution function of the MSD values
%at tau=1s of the MOST PREVALENT MODELS (accounting for >15% of the data) in the data set.
% where "filename" is the name of the outs_bayes structure saved by
% Bayesian_analysis, e.g. 'Bayes_results_T24.mat'
% where "filename_original" is the LAST PART of the original unbroken
% single trajectories, e.g. 'T24.vrpn.evt.mat'

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

m = figure;
set(0,'DefaultAxesFontSize',28)
hold on

if N_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,N)>=0.5))
        idx = outs_bayes.idlist(i)
% d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'r')
    end
end

if D_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,D)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'k')
    end
end

if V_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,V)>=0.5))
    	idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, '[1,0.4,0.6]')
    end
end

if DV_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DV)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'g')
    end
end

if DR_count/num_trackers> 0.15
     for i = transpose(find(outs_bayes.prob(:,DR)>=0.5))
         idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'b')
    end
end

if DA_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DA)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'm')
    end
end

if DRV_count/num_trackers> 0.15
    for  i = transpose(find(outs_bayes.prob(:,DRV)>=0.5))
         idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'c')
    end
end

if DAV_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DAV)>=0.5))
        idx = outs_bayes.idlist(i)
%      d = load_video_tracking(['single_curve_ID'  num2str(i, '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         loglog(vmsd.tau, vmsd.msd, 'y')
    end
end

title([num2str(expt_type) 'MSD Behavior by Model Type'])
hold off

return
