function [MSD_N, MSD_D, MSD_V, MSD_DV, MSD_DR, MSD_DA, MSD_DRV, MSD_DAV, MSD_prominent_models] = ksdensity_main_MT_MSDs(filename, filename_original, expt_type, tau)
%
% ksdensity_main_MT_MSDs
% yingzhou\desktop\MSD Bayes\Panoptes Functions
% last modified 07/10/13 (yingzhou) 2:58pm -Code is in the process of being
% modified
%
% ksdensity_main_MT_MSDs plots the distribution function of the MSD values
% at a given tau of the MOST PREVALENT MODELS (accounting for >15% of the
% data) in the data set. Default value of tau=1s.
%
% where 
    % "filename" is the name of the outs_bayes structure saved by
    % Bayesian_analysis, e.g. 'Bayes_results_T24.mat'
    % where "filename_original" is the LAST PART of the original unbroken
    % single trajectories, e.g. 'T24.vrpn.evt.mat'

[N, D, V, DV, DR, DA, DRV, DAV] = model_constants;

vmsd = video_msd(['single_curve_ID010_' num2str(filename_original)], 40, 30, 0.152, 'n');

time = min(find(vmsd.tau>tau));                                 %gives the minimum index for which tau is greater than or equal to the input tau.
window = vmsd.tau(time);

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

MSD_N=[];
MSD_D=[];
MSD_V=[];
MSD_DV=[];
MSD_DR=[];
MSD_DA=[];
MSD_DRV=[];
MSD_DAV=[];

if N_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,N)>=0.5))
        idx = outs_bayes.idlist(i);
        vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
        MSD_N=[MSD_N vmsd.msd(time)];
    end
end

if D_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,D)>=0.5))
        idx = outs_bayes.idlist(i);
        vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
        MSD_D=[MSD_D vmsd.msd(time)];
    end
end

if V_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,V)>=0.5))
    	idx = outs_bayes.idlist(i);
        vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
        MSD_V=[MSD_V vmsd.msd(time)]
    end
end

if DV_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DV)>=0.5))
        idx = outs_bayes.idlist(i);
        vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
        MSD_DV=[MSD_DV vmsd.msd(time)];
    end
end

if DR_count/num_trackers> 0.15
     for i = transpose(find(outs_bayes.prob(:,DR)>=0.5))
         idx = outs_bayes.idlist(i);
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         MSD_DR=[MSD_DR vmsd.msd(time)];
    end
end

if DA_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DA)>=0.5))
        idx = outs_bayes.idlist(i);
        vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
        MSD_DA=[MSD_DA vmsd.msd(time)];
    end
end

if DRV_count/num_trackers> 0.15
    for  i = transpose(find(outs_bayes.prob(:,DRV)>=0.5))
         idx = outs_bayes.idlist(i);
         vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
         MSD_DRV=[MSD_DRV vmsd.msd(time)];
    end
end

if DAV_count/num_trackers> 0.15
    for i = transpose(find(outs_bayes.prob(:,DAV)>=0.5))
        idx = outs_bayes.idlist(i);
        vmsd = video_msd(['single_curve_ID'  num2str(idx, '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
        MSD_DAV=[MSD_DAV vmsd.msd(time)];
    end
end

MSD_prominent_models=[MSD_N MSD_D MSD_V MSD_DV MSD_DR MSD_DA MSD_DRV MSD_DAV];
 

% This was one attempt to find a way to represent the data in a density
% figure format. 
% 
% gaussian density plots for MSDs of prominent modes of motion

if  ~isempty(MSD_N)
    n = figure;
    x = log10(MSD_N);
    mean_x = mean(log10(MSD_N));
    std_x = std(log10(MSD_N));
    plot(log(MSD_N), 'color', 'r');
    title(['Normalized MSDs for Null Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

if  ~isempty(MSD_D)
    x = log10(MSD_D);
    mean_x = mean(log10(MSD_D));
    std_x = std(log10(MSD_D));
    plot(log(MSD_D), 'color', 'k');
    title(['Normalized MSDs for Pure Diffusion Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

if  ~isempty(MSD_V)
    x = log10(MSD_V);
    mean_x = mean(log10(MSD_V));
    std_x = std(log10(MSD_V));
    plot(log(MSD_V), 'color', '[1,0.4,0.6]');
    title(['Normalized MSDs for Flow Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

if  ~isempty(MSD_DV)
    x = log10(MSD_DV);
    mean_x = mean(log10(MSD_DV));
    std_x = std(log10(MSD_DV));
    plot(log(MSD_DV), 'color', 'g');
    title(['Normalized MSDs for Diffusion plus Flow Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

if  ~isempty(MSD_DR)
    x = log10(MSD_DR);
    mean_x = mean(log10(MSD_DR));
    std_x = std(log10(MSD_DR));
    plot(log(MSD_DR), 'color', 'b');
    title(['Normalized MSDs for Confined Diffusion Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

if  ~isempty(MSD_DA)
    x = log10(MSD_DA);
    mean_x = mean(log10(MSD_DA));
    std_x = std(log10(MSD_DA));
    plot(log(MSD_DA), 'color', 'm');
    title(['Normalized MSDs for Anomalous Diffusion Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end
if  ~isempty(MSD_DRV)
    x = log10(MSD_DRV);
    mean_x = mean(log10(MSD_DRV));
    std_x = std(log10(MSD_DRV));
    plot(log(MSD_DRV), 'color', 'c');
    title(['Normalized MSDs for Confined Diffusion with Flow Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

if  ~isempty(MSD_DAV)
    x = log10(MSD_DAV);
    mean_x = mean(log10(MSD_DAV));
    std_x = std(log10(MSD_DAV));
    plot(log(MSD_DAV), 'color', 'y');
    title(['Normalized MSDs for Confined Diffusion Model at tau=' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
end

prominent_models = figure;
x = log10(MSD_prominent_models);
mean_x = mean(log10(MSD_prominent_models));
std_x = std(log10(MSD_prominent_models));
plot(log(MSD_prominent_models), 'color', 'b');                             %need to change this to plot a gaussian instead
title(['PDF' num2str(window) 's'],'FontSize',24); xlabel('log(MSD) [m^2]')
return
