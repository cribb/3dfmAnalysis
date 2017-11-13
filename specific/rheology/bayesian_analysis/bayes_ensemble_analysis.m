function param_struct = bayes_ensemble_analysis(bayes_output)
%BAYES_ENSEMBLE_ANALYSIS
%
% Created:       3/2/13, Luke Osborne 
% Last modified: 3/2/14, Luke Osborne 
%
% inputs:   bayes_output    this is the output structure from bayes_sub_master
%           
% outputs:  output          structure of MSD data organized by model             
% 
%
%
% this function is responsible for 
%   - taking in bayes_sub_master structure
%   - sorting through model list
%   - creating structure of MSD data for each model type
%


for k = 1:length(bayes_output)

    % determining the indices of the structure for each model type 

    N_row_index   = strcmp(bayes_output(k,1).model(:), 'N');
    D_row_index   = strcmp(bayes_output(k,1).model(:), 'D');
    DA_row_index  = strcmp(bayes_output(k,1).model(:), 'DA');
    DR_row_index  = strcmp(bayes_output(k,1).model(:), 'DR');
    V_row_index   = strcmp(bayes_output(k,1).model(:), 'V');

    
    % generating a MIT Bayesian code substructure for each model type. Each 
    % elements within a model structure is the bayesian output from a single
    % curve.

    N_results   = bayes_output(k,1).results(N_row_index);
    D_results   = bayes_output(k,1).results(D_row_index);
    DA_results  = bayes_output(k,1).results(DA_row_index);
    DR_results  = bayes_output(k,1).results(DR_row_index);
    V_results   = bayes_output(k,1).results(V_row_index);


    % generating a list of structure of values for parameters within each model.
    % "mean_curve" here is the mean curve for the n substrajectories that the
    % orginal curve was split into.

    
    % pre-allocating the parameter lists
    param_N    = zeros(length(N_results),1);
    param_D    = zeros(length(D_results),1);
    param_DA_D = zeros(length(DA_results),1);
    param_DA_A = zeros(length(DA_results),1);
    param_DR_D = zeros(length(DR_results),1);
    param_DR_R = zeros(length(DR_results),1);
    param_V    = zeros(length(V_results),1);

    if ~isempty(N_results)
        for i = 1:length(N_results)
        param_N(i,1) = N_results(i,1).mean_curve.N.C;
        end
    else
        param_N = NaN;
    end

    if ~isempty(D_results)
        for i = 1:length(D_results)
        param_D(i,1) = D_results(i,1).mean_curve.D.D;
        end
    else
        param_D = NaN;
    end
    
    if ~isempty(DA_results)
        for i = 1:length(DA_results)
        param_DA_D(i,1) = DA_results(i,1).mean_curve.DA.D;
        param_DA_A(i,1) = DA_results(i,1).mean_curve.DA.A;
        end
    else
        param_DA_D = NaN;
        param_DA_A = NaN;
    end
        
    if ~isempty(DR_results)
        for i = 1:length(DR_results)
        param_DR_D(i,1) = DR_results(i,1).mean_curve.DR.D;
        param_DR_R(i,1) = DR_results(i,1).mean_curve.DR.R;
        end
    else
        param_DR_D = NaN;
        param_DR_R = NaN;
    end

    if ~isempty(V_results)
        for i = 1:length(V_results)
        param_V(i,1) = V_results(i,1).mean_curve.V.V;
        end
    else
        param_V = NaN;
    end
  
    
    % computing statistics for each model parameter list

    param_struct(k,1).name = bayes_output(k,1).name;  %#ok<*AGROW>
    
    param_struct(k,1).N_mean    = mean(param_N);
    param_struct(k,1).D_mean    = mean(param_D);
    param_struct(k,1).DA_D_mean = mean(param_DA_D);
    param_struct(k,1).DA_A_mean = mean(param_DA_A);
    param_struct(k,1).DA_A_median = median(param_DA_A);  % median of the alpha distribution
    param_struct(k,1).DA_A_dist = param_DA_A;
    param_struct(k,1).DR_D_mean = mean(param_DR_D);
    param_struct(k,1).DR_R_mean = mean(param_DR_R);
    param_struct(k,1).V_mean    = mean(param_V);

    param_struct(k,1).N_std    = std(param_N);
    param_struct(k,1).D_std    = std(param_D);
    param_struct(k,1).DA_D_std = std(param_DA_D);
    param_struct(k,1).DA_A_std = std(param_DA_A);
    param_struct(k,1).DR_D_std = std(param_DR_D);
    param_struct(k,1).DR_R_std = std(param_DR_R);
    param_struct(k,1).V_std    = std(param_V);
       
    param_struct(k,1).N_count    = length(param_N);
    param_struct(k,1).D_count    = length(param_D);
    param_struct(k,1).DA_count   = length(param_DA_D);
    param_struct(k,1).DR_count   = length(param_DR_D);
    param_struct(k,1).V_count    = length(param_V);
    
    param_struct(k,1).N_se    = param_struct(k,1).N_std / sqrt(param_struct(k,1).N_count);
    param_struct(k,1).D_se    = param_struct(k,1).D_std / sqrt(param_struct(k,1).D_count);
    param_struct(k,1).DA_D_se = param_struct(k,1).DA_D_std / sqrt(param_struct(k,1).DA_count);
    param_struct(k,1).DA_A_se = param_struct(k,1).DA_A_std / sqrt(param_struct(k,1).DA_count);
    param_struct(k,1).DR_D_se = param_struct(k,1).DR_D_std / sqrt(param_struct(k,1).DR_count);
    param_struct(k,1).DR_R_se = param_struct(k,1).DR_R_std / sqrt(param_struct(k,1).DR_count);
    param_struct(k,1).V_se    = param_struct(k,1).V_std / sqrt(param_struct(k,1).V_count);
    
        
   
end % for k loop

end % function




