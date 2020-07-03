function outs_bayes = Bayes_out_struct (filename, idlist, models)

% restructured Bayes Results Function
% yingzhou/desktop/MSD Bayes/Panoptes Functions
% last modified 08/20/13 (yingzhou)
%
%BAYES_OUT_STRUCT 
%
%Bayes_out_struct reformats the data from Monnier et al.'s (2012) Bayesian code to
%this format:
%outs_bayes
    %.idlist
    %.models
    %.prob
    %.C
    %.D
    %.V
    %.Rc 
    %.Alpha
    %.C_se
    %.D_se
    %.V_se
    %.Rc_se
    %.Alpha_se
    
% where 
    % "filename" is the LAST PART of the filename for the file that contains the trajectory, e.g. 'T24.vrpn.evt.mat'
    % "idlist" is a column vector of matrix values 
    % "models" is a vector of the string names of the model types that you
    % wish to analyze the data with.

msd_params.models = models;

[N, D, V, DV, DR, DA, DRV, DAV] = model_constants(models); 

nummodels = length(msd_params.models)+1;

num_trackers = length(idlist);

Prob = NaN(num_trackers, nummodels);
Prob(:,1) = idlist;

C_param = NaN(num_trackers,nummodels);
C_param(:,1) = idlist;

D_param = NaN(num_trackers,nummodels);
D_param(:,1) = idlist;

V_param = NaN(num_trackers,nummodels);
V_param(:,1) = idlist;

Alpha_param = NaN(num_trackers,nummodels);
Alpha_param(:,1) = idlist;

Rc_param = NaN(num_trackers,nummodels);
Rc_param(:,1) = idlist;

SE_C= NaN(num_trackers, nummodels);
SE_C(:,1) = idlist;

SE_D = NaN(num_trackers,nummodels);
SE_D(:,1) = idlist;

SE_V = NaN(num_trackers,nummodels);
SE_V(:,1) = idlist;

SE_Alpha = NaN(num_trackers,nummodels);
SE_Alpha(:,1) = idlist;

SE_Rc = NaN(num_trackers,nummodels);
SE_Rc(:,1) = idlist;

for i = 1:length(idlist)
    
    d = load_video_tracking(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'matrix');
    
    if size(d,1)>=792
        
        vmsd = video_msd(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename)], 40, 30, 0.152, 'n');
        results = msd_curves_bayes(vmsd.tau(:,1), vmsd.msd*1e12, msd_params);  
        
        
        %probabilities:
        if sum(ismember(msd_params.models, 'N'))>0
            Prob (i, N) = results.mean_curve.N.PrM;
            C_param (i, N) = results.mean_curve.N.C;
            SE_C (i, N) = results.mean_curve.N.C_se;
        end
        
        if sum(ismember(msd_params.models, 'D'))>0
            Prob (i, D) = results.mean_curve.D.PrM;
            D_param (i, D) = results.mean_curve.D.D;
            SE_D (i, D) = results.mean_curve.D.D_se;
        end
        
        if sum(ismember(msd_params.models, 'V'))>0
            Prob (i, V) = results.mean_curve.V.PrM;
            V_param (i, V) = results.mean_curve.V.V;
            SE_V (i, V) = results.mean_curve.V.V_se;
        end 
           
        if sum(ismember(msd_params.models, 'DV'))>0
            Prob (i, DV) = results.mean_curve.DV.PrM;
            D_param (i, DV) = results.mean_curve.DV.D;
            V_param (i, DV) = results.mean_curve.DV.V;
            SE_D (i, DV) = results.mean_curve.DV.D_se;
            SE_V (i, DV) = results.mean_curve.DV.V_se;
        end    
            
        if sum(ismember(msd_params.models, 'DA'))>0
            Prob (i, DA) = results.mean_curve.DA.PrM;
            D_param (i, DA) = results.mean_curve.DA.D;
            Alpha_param (i, DA) = results.mean_curve.DA.A;
            SE_D (i, DA) = results.mean_curve.DA.D_se;
            SE_Alpha (i, DA) = results.mean_curve.DA.A_se;
        end
        
        if sum(ismember(msd_params.models, 'DR'))>0
            Prob (i, DR) = results.mean_curve.DR.PrM;
            D_param (i, DR) = results.mean_curve.DR.D;
            Rc_param (i, DR) = results.mean_curve.DR.R;
            SE_D (i, DR) = results.mean_curve.DR.D_se;
            SE_Rc (i, DR) = results.mean_curve.DR.R_se;
        end
        
        if sum(ismember(msd_params.models, 'DRV'))>0    
            Prob (i, DRV) = results.mean_curve.DRV.PrM;
            D_param (i, DRV) = results.mean_curve.DRV.D;
            V_param (i, DRV) = results.mean_curve.DRV.V;
            Rc_param (i, DRV) = results.mean_curve.DRV.R;
            SE_D (i, DRV) = results.mean_curve.DRV.D_se;
            SE_V (i, DRV) = results.mean_curve.DRV.V_se;
            SE_Rc (i, DRV) = results.mean_curve.DRV.R_se;
        end
        
        if sum(ismember(msd_params.models, 'DAV'))>0    
            Prob (i, DAV) = results.mean_curve.DAV.PrM;
            D_param (i, DAV) = results.mean_curve.DAV.D;
            V_param (i, DAV) = results.mean_curve.DAV.V;
            Alpha_param (i, DAV) = results.mean_curve.DAV.A;
            SE_D (i, DAV) = results.mean_curve.DAV.D_se;
            SE_V (i, DAV) = results.mean_curve.DAV.V_se;
            SE_Alpha (i, DAV) = results.mean_curve.DAV.A_se;
        end      
    end
end

%outputs the information into the out_bayes structure
outs_bayes.idlist = idlist;
outs_bayes.models = models;
outs_bayes.prob = Prob;
outs_bayes.C = C_param;
outs_bayes.D = D_param;
outs_bayes.V = V_param;
outs_bayes.Rc = Rc_param;
outs_bayes.Alpha = Alpha_param;
outs_bayes.C_se = SE_C;
outs_bayes.D_se = SE_D;
outs_bayes.V_se = SE_V;
outs_bayes.Rc_se = SE_Rc;
outs_bayes.Alpha_se = SE_Alpha;

return