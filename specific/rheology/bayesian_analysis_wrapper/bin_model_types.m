function bin_model_types(filename, expt_type, models)

% bin_model_types
% yingzhou\desktop\MSD Bayes\Panoptes Functions
% last modified 08/22/13 (yingzhou) 3:44pm
%
% where 
%   "filename" is the name of the outs_bayes struct file that contains the
%   results of the Monnier et al. (2012) Bayes analysis code.
%   "expt_type" is the type of the experiment that was performed (e.g. cell
%   mechanics, rheology, freely diffusing bead, etc.). This will go on the
%   title of the figure.
%   "models" is a vector of the models that the data were fit to.
%
% bin_model_types bins the number of trajectories in each model type (based
% on >50% probability of the tracker behaving as a specific model. 
% Each model type is represented by a different color bar in the histogram.
% 
%

if nargin<3||isempty(models) 
   [N, D, V, DV, DR, DA, DRV, DAV] = model_constants();
else
   msd_params.models = models; 
end

% d = filename;
load (num2str(filename));

N_model=0;
D_model=0;
V_model=0;
DV_model=0;
DA_model=0;
DR_model=0;
DRV_model=0;
DAV_model=0;

model_tot=[];

if exist('N')==1
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,N)>=0.5
            N_model = N_model+1;
        end
    end    
    model_tot = [N_model];
end

if exist('D')==1
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,D)>=0.5
            D_model = D_model+1;
        end
    end
    model_tot = [model_tot D_model];
end

if exist('V')==1
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,V)>=0.5
            V_model = V_model+1;
        end
    end 
    model_tot = [model_tot V_model];
end 

if exist('DV')==1
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,DV)>=0.5
            DV_model = DV_model+1;
        end
    end 
    model_tot = [model_tot DV_model];
end    

if exist('DR')==1
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,DR)>=0.5
            DR_model = DR_model+1;
        end
    end
    model_tot = [model_tot DR_model];
end

if exist('DA')==1
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,DA)>=0.5
            DA_model = DA_model+1;
        end
    end 
    model_tot = [model_tot DA_model];
end

if exist('DRV')==1   
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,DRV)>=0.5
            DRV_model = DRV_model+1;
        end
    end 
    model_tot = [model_tot DRV_model];
end

if exist('DAV')==1  
    for i=1:length(outs_bayes.idlist)
        if outs_bayes.prob(i,DAV)>=0.5
            DAV_model = DAV_model+1;
        end
    end 
    model_tot = [model_tot DAV_model];
end

model_bins = figure;
bar(model_tot)
Labels = msd_params.models;
set(gca, 'XTick', 1:length(Labels), 'XTickLabel', Labels);
title(num2str(expt_type),'FontSize',28);
