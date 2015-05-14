function [ensemble_table] = bayes_summary_ensemble(bayes_output)
%BAYES_SUMMARY_ENSEMBLE
%
% Created:       3/7/14, Luke Osborne 
% Last modified: 3/7/14, Luke Osborne 
%
% inputs:         
% outputs:              
%
% this function is responsible for 
%   - 


% msd_params = {'N', 'D', 'DA', 'DR', 'V'};
% msd_params = {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};


% determining the indices of the structure for each model type 

    N_row_index   = strcmp(bayes_output.model(:), 'N');
    D_row_index   = strcmp(bayes_output.model(:), 'D');
    DA_row_index  = strcmp(bayes_output.model(:), 'DA');
    DR_row_index  = strcmp(bayes_output.model(:), 'DR');
    V_row_index   = strcmp(bayes_output.model(:), 'V');

    
% generating a MIT Bayesian code substructure for each model type. Each 
% elements within a model structure is the bayesian output from a single
% curve.

    N_results   = bayes_output.results(N_row_index);
    D_results   = bayes_output.results(D_row_index);
    DA_results  = bayes_output.results(DA_row_index);
    DR_results  = bayes_output.results(DR_row_index);
    V_results   = bayes_output.results(V_row_index);
 

% generating a list of structure of values for parameters within each model.
% "mean_curve" here is the mean curve for the n substrajectories that the
% orginal curve was split into.

    param_N    =[];
    param_D    =[];
    param_DA_D =[];
    param_DA_A =[];
    param_DR_R =[];
    param_V    =[];

    if isempty(N_results) == 0
        for i = 1:length(N_results)
        param_N(i,1) = N_results(i,1).mean_curve.N.C;
        end
    else
        param_N = NaN;
    end

    if isempty(D_results) == 0
        for i = 1:length(D_results)
        param_D(i,1) = D_results(i,1).mean_curve.D.D;
        end
    else
        param_D = NaN;
    end
    
    if isempty(DA_results) == 0
        for i = 1:length(DA_results)
        param_DA_D(i,1) = DA_results(i,1).mean_curve.DA.D;
        param_DA_A(i,1) = DA_results(i,1).mean_curve.DA.A;
        end
    else
        param_DA_D = NaN;
        param_DA_A = NaN;
    end
        
    if isempty(DR_results) == 0
        for i = 1:length(DR_results)
        param_DR_D(i,1) = DR_results(i,1).mean_curve.DR.D;
        param_DR_R(i,1) = DR_results(i,1).mean_curve.DR.R;
        end
    else
        param_DR_D = NaN;
        param_DR_R = NaN;
    end

    if isempty(V_results) == 0
        for i = 1:length(V_results)
        param_V(i,1) = V_results(i,1).mean_curve.V.V;
        end
    else
        param_V = NaN;
    end
  
   
% computing statistics for each model parameter list

    mean_N    = mean(param_N);
    mean_D    = mean(param_D);
    mean_DA_D = mean(param_DA_D);
    mean_DA_A = mean(param_DA_A);
    mean_DR_D = mean(param_DR_D);
    mean_DR_R = mean(param_DR_R);
    mean_V    = mean(param_V);

    std_N    = std(param_N);
    std_D    = std(param_D);
    std_DA_D = std(param_DA_D);
    std_DA_A = std(param_DA_A);
    std_DR_D = std(param_DR_D);
    std_DR_R = std(param_DR_R);
    std_V    = std(param_V);
       
    count_N    = length(param_N);
    count_D    = length(param_D);
    count_DA_D = length(param_DA_D);
    count_DA_A = length(param_DA_A);
    count_DR_D = length(param_DR_D);
    count_DR_R = length(param_DR_R);
    count_V    = length(param_V);
    
    se_N    = std_N / sqrt(count_N);
    se_D    = std_D / sqrt(count_D);
    se_DA_D = std_DA_D / sqrt(count_DA_D);
    se_DA_A = std_DA_A / sqrt(count_DA_A);
    se_DR_D = std_DR_D / sqrt(count_DR_D);
    se_DR_R = std_DR_R / sqrt(count_DR_R);
    se_V    = std_V / sqrt(count_V);
    
        
% creating a table with all of the statistics    
    

% Generating a matrix of table headings

    table_headings (:,1)  = {'condition'};
    table_headings (:,2)  = {'C (N model) [um^2]'};
    table_headings (:,3)  = {'C error [um^2]'};
    table_headings (:,4)  = {'D (D model) [um^2/s]'};
    table_headings (:,5)  = {'D error [um^2/s]'};
    table_headings (:,6)  = {'D (DA model) [um^2/s]'};
    table_headings (:,7)  = {'D error [um^2/s]'};
    table_headings (:,8)  = {'alpha (DA model)'};
    table_headings (:,9)  = {'D (DR model) [um^2/s]'};
    table_headings (:,10) = {'D error [um^2/s]'};
    table_headings (:,11) = {'R (DR model) [um]'};
    table_headings (:,12) = {'V [um/s]'};
    table_headings (:,13) = {'V error [um/s]'};
    table_headings (:,14) = {'count'};

    parameters = [mean_N se_N mean_D se_D mean_DA_D se_DA_D ... 
                  mean_DA_A se_DA_A mean_DR_D se_DR_D ...
                  mean_DR_R se_DR_R mean_V se_V];
   

    ensemble_table.headings   = table_headings;
    ensemble_table.parameters = parameters;
    

end


