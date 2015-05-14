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

    param_struct(k,1).name = bayes_output(k,1).name;
    
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




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Backup code from 2014.04.04 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %


% msd_params = {'N', 'D', 'DA', 'DR', 'V'};
% msd_params = {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};



% Generating a matrix of table headings

% table_headings (1,:)  = {'N' 'C'};
% table_headings (2,:)  = {'D' 'D'};
% table_headings (3,:)  = {'DA' 'D'};
% table_headings (4,:)  = {' ' 'A'};
% table_headings (5,:)  = {'DR' 'D'};
% table_headings (6,:)  = {' ' 'R'};
% table_headings (7,:)  = {'V' 'V'};
% table_headings (8,:)  = {'DV' 'D'};
% table_headings (9,:)  = {' ' 'V'};
% table_headings (10,:) = {'DAV' 'D'};
% table_headings (11,:) = {' ' 'A'};
% table_headings (12,:) = {' ' 'V'};
% table_headings (13,:) = {'DRV' 'D'};
% table_headings (14,:) = {' ' 'R'};
% table_headings (15,:) = {' ' 'V'};




%     DV_row_index  = strcmp(bayes_output.model(:), 'DV');
%     DAV_row_index = strcmp(bayes_output.model(:), 'DAV');
%     DRV_row_index = strcmp(bayes_output.model(:), 'DRV');    
    
    
%     DV_results  = bayes_output.results(DV_row_index);
%     DAV_results = bayes_output.results(DAV_row_index);
%     DRV_results = bayes_output.results(DRV_row_index);


%     essemble_table.N    = [mean_N std_N count_N];
%     essemble_table.D    = [mean_D std_D count_D];
%     essemble_table.DA_D = [mean_DA_D std_DA_D count_DA_D];
%     essemble_table.DA_A = [mean_DA_A std_DA_A count_DA_A];
%     essemble_table.DR_D = [mean_DR_D std_DR_D count_DR_D];
%     essemble_table.DR_R = [mean_DR_R std_DR_R count_DR_R];
%     essemble_table.V    = [mean_V std_V count_V];



% creating a table with all of the statistics    
    
%     ensemble_table (1,:) = [mean_N std_N se_N count_N];
%     ensemble_table (2,:) = [mean_D std_D se_D count_D];
%     ensemble_table (3,:) = [mean_DA_D std_DA_D se_DA_D count_DA_D];
%     ensemble_table (4,:) = [mean_DA_A std_DA_A se_DA_A count_DA_A];
%     ensemble_table (5,:) = [mean_DR_D std_DR_D se_DR_D count_DR_D];
%     ensemble_table (6,:) = [mean_DR_R std_DR_R se_DR_R count_DR_R];
%     ensemble_table (7,:) = [mean_V std_V se_V count_V];
% 
% 
%     ensemble_table.table = ensemble_table;
%     ensemble_table.headings = table_headings;


% generating a list of structure of values for parameters within each model.
    % "mean_curve" here is the mean curve for the n substrajectories that the
    % orginal curve was split into.

%     param_N    =[];
%     param_D    =[];
%     param_DA_D =[];
%     param_DA_A =[];
%     param_DR_R =[];
%     param_V    =[];
% 
%     if isempty(N_results) == 0
%         for i = 1:length(N_results)
%         param_N(i,1) = N_results(i,1).mean_curve.N.C;
%         end
%     else
%         param_N = NaN;
%     end
% 
%     if isempty(D_results) == 0
%         for i = 1:length(D_results)
%         param_D(i,1) = D_results(i,1).mean_curve.D.D;
%         end
%     else
%         param_D = NaN;
%     end
%     
%     if isempty(DA_results) == 0
%         for i = 1:length(DA_results)
%         param_DA_D(i,1) = DA_results(i,1).mean_curve.DA.D;
%         param_DA_A(i,1) = DA_results(i,1).mean_curve.DA.A;
%         end
%     else
%         param_DA_D = NaN;
%         param_DA_A = NaN;
%     end
%         
%     if isempty(DR_results) == 0
%         for i = 1:length(DR_results)
%         param_DR_D(i,1) = DR_results(i,1).mean_curve.DR.D;
%         param_DR_R(i,1) = DR_results(i,1).mean_curve.DR.R;
%         end
%     else
%         param_DR_D = NaN;
%         param_DR_R = NaN;
%     end
% 
%     if isempty(V_results) == 0
%         for i = 1:length(V_results)
%         param_V(i,1) = V_results(i,1).mean_curve.V.V;
%         end
%     else
%         param_V = NaN;
%     end