function msd_by_model_type(filename, filename_original, expt_type, models)

% msd_by_model_type
% yingzhou\desktop\MSD Bayes\Panoptes Functions
% last modified 08/22/13 (yingzhou)
%
% msd_by_model_type will plot the MSDs of each curve depending on the model
% type identified by Bayes code.
%
% where 
    % "filename" is the name of the initial data file in evt_GUI format
    %
    % "filename_original" is the LAST PART of the original unbroken
    % single trajectories, e.g. 'T24.vrpn.evt.mat'
    %
    % "expt_type" is the type of experiment that was done.
    %
    % "models" are the models that were input into the Bayes analysis.
    % If no models vector is provided, the default includes all eight model types: constant, purely diffusive,
    % flow, diffussive with flow, confined diffusion, anomalous diffusion,
    % confined diffusion with drift, and anomalous diffusion plus flow.


load(filename);

[N, D, V, DV, DR, DA, DRV, DAV] = model_constants;

m = figure;
set(0,'DefaultAxesFontSize',24)
title([num2str(expt_type) 'MSD Behavior by Model Type'])
hold on

idlist = outs_bayes.idlist;

for i = 1:length(idlist) 
    
    for p = 1:length(models);
        %vector of probabilities for each model type
%         model_prob=[outs_bayes.prob(i,N) outs_bayes.prob(i,D) outs_bayes.prob(i,V) outs_bayes.prob(i,DV) outs_bayes.prob(i,DR) outs_bayes.prob(i,DA) outs_bayes.prob(i,DRV) outs_bayes.prob(i,DAV)];
        msd_params.models
        
        if sum(ismember(models, 'N'))==1
            model_prob = [outs_bayes.prob(i,N)];
        end
        
        
        
        idx = find(model_prob>=.5);

        if sum(ismember(models, 'N'))==1&&idx==N-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'r')
            
        elseif sum(ismember(models, 'D'))==1&&idx==D-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'k')
               
        elseif sum(ismember(models, 'V'))==1&&idx==V-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, '[1,0.4,0.6]')

        elseif sum(ismember(models, 'DV'))==1&&idx==DV-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'g')

        elseif sum(ismember(models, 'DR'))==1&&idx==DR-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'm')            
            
        elseif sum(ismember(models, 'DA'))==1&&idx==DA-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'b')
            
        elseif sum(ismember(models, 'DRV'))==1&&idx==DRV-1
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'c')           
            
        else 
            vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename_original)], 40, 30, 0.152, 'n');
            loglog(vmsd.tau, vmsd.msd, 'y')
        end    
    end    
end

hold off

return