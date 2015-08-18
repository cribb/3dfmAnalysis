function [bayes_model_output] = bayes_model_analysis(bayes_output)
%BAYES_MODEL_ANALYSIS
%
% Created:       2/5/13, Luke Osborne 
% Last modified: 2/5/14, Luke Osborne 
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

msd_params.models = {'N', 'D', 'DA', 'DR', 'V'};
%msd_params = {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};

bayes_model_output = struct;

for k = 1:length(bayes_output) 

    name = bayes_output(k,1).name;
    filename = bayes_output(k,1).filename;
    
    
    if ~isempty(bayes_output(k,1).original_curve_data)
        
        % determining the indices of the structure for each model type 

        N_row_index   = strcmp(bayes_output(k,1).model(:), 'N');
        D_row_index   = strcmp(bayes_output(k,1).model(:), 'D');
        DA_row_index  = strcmp(bayes_output(k,1).model(:), 'DA');
        DR_row_index  = strcmp(bayes_output(k,1).model(:), 'DR');
        V_row_index   = strcmp(bayes_output(k,1).model(:), 'V');


        % generating a list of original curves structures (taus, msds, n, ns, window) for each model type

        N_curves   = bayes_output(k,1).original_curve_data(N_row_index, 1);
        D_curves   = bayes_output(k,1).original_curve_data(D_row_index, 1);
        DA_curves  = bayes_output(k,1).original_curve_data(DA_row_index, 1);
        DR_curves  = bayes_output(k,1).original_curve_data(DR_row_index, 1);
        V_curves   = bayes_output(k,1).original_curve_data(V_row_index, 1);

        
        for i = 1:length(N_curves)
            N_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,N_row_index');
            N_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,N_row_index');
            N_curve_struct.well      = bayes_output(k,1).agg_data.well(1,N_row_index');
            N_curve_struct.area      = bayes_output(k,1).agg_data.area(1,N_row_index');
            N_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,N_row_index');
            N_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,N_row_index');
            N_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,N_row_index');
            N_curve_struct.n         = bayes_output(k,1).agg_data.n;
            N_curve_struct.ns        = bayes_output(k,1).agg_data.ns(:,N_row_index');
            N_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(D_curves)
            D_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,D_row_index');
            D_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,D_row_index');
            D_curve_struct.well      = bayes_output(k,1).agg_data.well(1,D_row_index');
            D_curve_struct.area      = bayes_output(k,1).agg_data.area(1,D_row_index');
            D_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,D_row_index');            
            D_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,D_row_index');
            D_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,D_row_index');
            D_curve_struct.n         = bayes_output(k,1).agg_data.n;
            D_curve_struct.ns        = bayes_output(k,1).agg_data.ns(:,D_row_index');
            D_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(DA_curves)
            DA_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,DA_row_index');
            DA_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,DA_row_index');
            DA_curve_struct.well      = bayes_output(k,1).agg_data.well(1,DA_row_index');
            DA_curve_struct.area      = bayes_output(k,1).agg_data.area(1,DA_row_index');
            DA_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,DA_row_index'); 
            DA_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,DA_row_index');
            DA_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,DA_row_index');
            DA_curve_struct.n         = bayes_output(k,1).agg_data.n;
            DA_curve_struct.ns        = bayes_output(k,1).agg_data.ns(:,DA_row_index');
            DA_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(DR_curves)
            DR_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,DR_row_index');
            DR_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,DR_row_index');
            DR_curve_struct.well      = bayes_output(k,1).agg_data.well(1,DR_row_index');
            DR_curve_struct.area      = bayes_output(k,1).agg_data.area(1,DR_row_index');
            DR_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,DR_row_index');             
            DR_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,DR_row_index');
            DR_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,DR_row_index');
            DR_curve_struct.n         = bayes_output(k,1).agg_data.n;
            DR_curve_struct.ns        = bayes_output(k,1).agg_data.ns(:,DR_row_index');
            DR_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(V_curves)
            V_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,V_row_index');
            V_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,V_row_index');
            V_curve_struct.well      = bayes_output(k,1).agg_data.well(1,V_row_index');
            V_curve_struct.area      = bayes_output(k,1).agg_data.area(1,V_row_index');
            V_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,V_row_index');             
            V_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,V_row_index');
            V_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,V_row_index');
            V_curve_struct.n         = bayes_output(k,1).agg_data.n;
            V_curve_struct.ns        = bayes_output(k,1).agg_data.ns(:,V_row_index');
            V_curve_struct.window    = bayes_output(k,1).agg_data.window;
            %V_curve_struct.window(:,i) = bayes_output(k,1).agg_data.window;
        end


% commented 6/3/14 this is residue from when 

%         if isempty(N_curves) == 0 && length(N_curves)>= 4                               % isempty(A) returns 1 if A is empty, 0 if A has stuff in it
%     %         N_bayes   = msd_curves_bayes(N_curve_struct.tau(:,1), N_curve_struct.msd*1E12, msd_params);        % Assumption: MIT Bayesian code needs 4 MSD curves to compute covariance matrix
%         else
%             N_bayes = [];
%             N_curve_struct = [];
%         end
% 
%         if isempty(D_curves) == 0 && length(D_curves)>= 4 
%     %         D_bayes   = msd_curves_bayes(D_curve_struct.tau(:,1), D_curve_struct.msd*1E12, msd_params);
%         else
%             D_bayes = [];
%             D_curve_struct = [];
%         end
% 
%         if isempty(DA_curves) == 0 && length(DA_curves)>= 4 
%     %         DA_bayes   = msd_curves_bayes(DA_curve_struct.tau(:,1), DA_curve_struct.msd*1E12, msd_params);
%         else
%             DA_bayes = [];
%             DA_curve_struct = [];
%         end
% 
%         if isempty(DR_curves) == 0 && length(DR_curves)>= 4
%     %         DR_bayes   = msd_curves_bayes(DR_curve_struct.tau(:,1), DR_curve_struct.msd*1E12, msd_params);
%         else
%             DR_bayes = [];
%             DR_curve_struct = [];
%         end
% 
%         if isempty(V_curves) == 0 && length(V_curves)>= 4
%     %         V_bayes   = msd_curves_bayes(V_curve_struct.tau(:,1), V_curve_struct.msd*1E12, msd_params);
%         else
%             V_bayes = [];
%             V_curve_struct = [];
%         end
    
        if isempty(N_curves)
            N_curve_struct = [];
        end
        if isempty(D_curves)
            D_curve_struct = [];
        end
        if isempty(DA_curves)
            DA_curve_struct = [];
        end
        if isempty(DR_curves)
            DR_curve_struct = [];
        end
        if isempty(V_curves)
            V_curve_struct = [];
        end
        
        % creating the DA DR structure by concatenating the indiv structures

        if isempty(DA_curve_struct)
            DADR_curve_struct = DR_curve_struct;
        elseif isempty(DR_curve_struct)
            DADR_curve_struct = DA_curve_struct;
        else
            DADR_curve_struct.trackerID = horzcat(DA_curve_struct.trackerID, DR_curve_struct.trackerID);
            DADR_curve_struct.pass = horzcat(DA_curve_struct.pass, DR_curve_struct.pass);
            DADR_curve_struct.well = horzcat(DA_curve_struct.well, DR_curve_struct.well);
            DADR_curve_struct.area = horzcat(DA_curve_struct.area, DR_curve_struct.area);
            DADR_curve_struct.sens = horzcat(DA_curve_struct.sens, DR_curve_struct.sens);
            DADR_curve_struct.tau = horzcat(DA_curve_struct.tau, DR_curve_struct.tau);
            DADR_curve_struct.msd = horzcat(DA_curve_struct.msd, DR_curve_struct.msd);
            DADR_curve_struct.n = DA_curve_struct.n;
            DADR_curve_struct.ns = horzcat(DA_curve_struct.ns, DR_curve_struct.ns);
            DADR_curve_struct.window = DA_curve_struct.window;
        end


        bayes_model_output(k,1).name     = name;
        bayes_model_output(k,1).filename = filename;

        bayes_model_output(k,1).N_curve_struct   = N_curve_struct;
        bayes_model_output(k,1).D_curve_struct   = D_curve_struct;
        bayes_model_output(k,1).DA_curve_struct  = DA_curve_struct;
        bayes_model_output(k,1).DR_curve_struct  = DR_curve_struct;
        bayes_model_output(k,1).V_curve_struct   = V_curve_struct;

        bayes_model_output(k,1).DADR_curve_struct   = DADR_curve_struct;



    else   % isempty bayes_output(k,1).original_curve_data
    bayes_model_output(k,1).name     = name;
    bayes_model_output(k,1).filename = filename;

    bayes_model_output(k,1).N_curve_struct   = [];
    bayes_model_output(k,1).D_curve_struct   = [];
    bayes_model_output(k,1).DA_curve_struct  = [];
    bayes_model_output(k,1).DR_curve_struct  = [];
    bayes_model_output(k,1).V_curve_struct   = [];

    bayes_model_output(k,1).DADR_curve_struct   = [];
    end    % isempty bayes_output(k,1).original_curve_data


clear N_curve_struct;
clear D_curve_struct;
clear DA_curve_struct;
clear DR_curve_struct;
clear V_curve_struct;

clear DADR_curve_struct;
   
end % for loop

end % function





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Backup code from 2014.04.02 | made switch to ensemble analysis
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %


    % generating a list of original curves msds for each model type (each curve
    % is a column in the matrix. This is used as an input for the MIT code.)

    % preallocating the msd curves arrays to increase speed
    %     N_msds  = zeros(length(N_curves));
    %     D_msds  = zeros(length(D_curves));
    %     DA_msds = zeros(length(DA_curves));
    %     DR_msds = zeros(length(DR_curves));
    %     V_msds  = zeros(length(V_curves));

%     for i = 1:length(N_curves)
%     N_msds(:,i) = N_curves(i,1).msd;
%     end
%     
%     for i = 1:length(D_curves)
%     D_msds(:,i) = D_curves(i,1).msd;
%     end
%     
%     for i = 1:length(DA_curves)
%     DA_msds(:,i) = DA_curves(i,1).msd;
%     end
%     
%     for i = 1:length(DR_curves)
%     DR_msds(:,i) = DR_curves(i,1).msd;
%     end
%     
%     for i = 1:length(V_curves)
%     V_msds(:,i) = V_curves(i,1).msd;
%     end
    
% %     for i = 1:length(N_curves)
% %     N_curve_struct.tau(:,i)    = N_curves(i,1).tau;
% %     N_curve_struct.msd(:,i)    = N_curves(i,1).msd;
% %     N_curve_struct.n(:,i)      = N_curves(i,1).n;
% %     N_curve_struct.ns(:,i)     = N_curves(i,1).ns;
% %     N_curve_struct.window(:,i) = N_curves(i,1).window;
% %     end
% %     
% %     for i = 1:length(D_curves)
% %     D_curve_struct.tau(:,i)    = D_curves(i,1).tau;
% %     D_curve_struct.msd(:,i)    = D_curves(i,1).msd;
% %     D_curve_struct.n(:,i)      = D_curves(i,1).n;
% %     D_curve_struct.ns(:,i)     = D_curves(i,1).ns;
% %     D_curve_struct.window(:,i) = D_curves(i,1).window;
% %     end
% %     
% %     for i = 1:length(DA_curves)
% %     DA_curve_struct.tau(:,i)    = DA_curves(i,1).tau;
% %     DA_curve_struct.msd(:,i)    = DA_curves(i,1).msd;
% %     DA_curve_struct.n(:,i)      = DA_curves(i,1).n;
% %     DA_curve_struct.ns(:,i)     = DA_curves(i,1).ns;
% %     DA_curve_struct.window(:,i) = DA_curves(i,1).window;
% %     end
% %     
% %     for i = 1:length(DR_curves)
% %     DR_curve_struct.tau(:,i)    = DR_curves(i,1).tau;
% %     DR_curve_struct.msd(:,i)    = DR_curves(i,1).msd;
% %     DR_curve_struct.n(:,i)      = DR_curves(i,1).n;
% %     DR_curve_struct.ns(:,i)     = DR_curves(i,1).ns;
% %     DR_curve_struct.window(:,i) = DR_curves(i,1).window;
% %     end
% %     
% %     for i = 1:length(V_curves)
% %     V_curve_struct.tau(:,i)    = V_curves(i,1).tau;
% %     V_curve_struct.msd(:,i)    = V_curves(i,1).msd;
% %     V_curve_struct.n(:,i)      = V_curves(i,1).n;
% %     V_curve_struct.ns(:,i)     = V_curves(i,1).ns;
% %     V_curve_struct.window(:,i) = V_curves(i,1).window;
% %     end




    % running each model structure through the MIT Bayesian code (only if it is
    % an structure with contents --> there are beads of that model type
    % AND if there are at least 4 curves in that model type)

%     if isempty(N_curves) == 0 && length(N_curves)>= 4                               % isempty(A) returns 1 if A is empty, 0 if A has stuff in it
%         N_bayes   = msd_curves_bayes(N_curves(1,1).tau, N_msds*1E12, msd_params);        % Assumption: MIT Bayesian code needs 4 MSD curves to compute covariance matrix
%     else
%         N_bayes = [];
%     end
% 
%     if isempty(D_curves) == 0 && length(D_curves)>= 4 
%         D_bayes   = msd_curves_bayes(D_curves(1,1).tau, D_msds*1E12, msd_params);
%     else
%         D_bayes = [];
%     end
% 
%     if isempty(DA_curves) == 0 && length(DA_curves)>= 4 
%         DA_bayes   = msd_curves_bayes(DA_curves(1,1).tau, DA_msds*1E12, msd_params);
%     else
%         DA_bayes = [];
%     end
% 
%     if isempty(DR_curves) == 0 && length(DR_curves)>= 4
%         DR_bayes   = msd_curves_bayes(DR_curves(1,1).tau, DR_msds*1E12, msd_params);
%     else
%         DR_bayes = [];
%     end
% 
%     if isempty(V_curves) == 0 && length(V_curves)>= 4
%         V_bayes   = msd_curves_bayes(V_curves(1,1).tau, V_msds*1E12, msd_params);
%     else
%         V_bayes = [];
%     end



  %  DR_msds = bayes_output(k,1).agg_data.msd(:,DR_row_index');






% clear N_msds;  % this is needed to prevent collisions between datasets
% clear D_msds;
% clear DA_msds;
% clear DR_msds;
% clear V_msds;



% % Generating a matrix of table headings
% 
%         table_headings (1,:)  = {'N' 'C'};
%         table_headings (2,:)  = {'D' 'D'};
%         table_headings (3,:)  = {'DA' 'D'};
%         table_headings (4,:)  = {' ' 'A'};
%         table_headings (5,:)  = {'DR' 'D'};
%         table_headings (6,:)  = {' ' 'R'};
%         table_headings (7,:)  = {'V' 'V'};


% generating a table of model parameter values and probabilities for each
    % model structure.  This is overkill, and will be made more concise later.
    % Ultimately we probably just want the model parameter for the given model.

%     b_model_out.N   = bayes_create_table(N_bayes);
%     b_model_out.D   = bayes_create_table(D_bayes);
%     b_model_out.DA  = bayes_create_table(DA_bayes);
%     b_model_out.DR  = bayes_create_table(DR_bayes);
%     b_model_out.V   = bayes_create_table(V_bayes);
% 
%     b_model_out.headings = table_headings;

    
    


% bayes_model_output(k,1).headings = b_model_out.headings;
% 
% bayes_model_output(k,1).N   = b_model_out.N;
% bayes_model_output(k,1).D   = b_model_out.D;
% bayes_model_output(k,1).DA  = b_model_out.DA;
% bayes_model_output(k,1).DR  = b_model_out.DR;
% bayes_model_output(k,1).V   = b_model_out.V;


















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

    
% generating a MIT Bayesian code substructure for each model type    
    
%     N_results   = bayes_output.results(N_row_index);
%     D_results   = bayes_output.results(D_row_index);
%     DA_results  = bayes_output.results(DA_row_index);
%     DR_results  = bayes_output.results(DR_row_index);
%     V_results   = bayes_output.results(V_row_index);
%     DV_results  = bayes_output.results(DV_row_index);
%     DAV_results = bayes_output.results(DAV_row_index);
%     DRV_results = bayes_output.results(DRV_row_index);
 


%     DV_curves  = bayes_output.original_curve_data(DV_row_index, 1);
%     DAV_curves = bayes_output.original_curve_data(DAV_row_index, 1);
%     DRV_curves = bayes_output.original_curve_data(DRV_row_index, 1);



%     for i = 1:length(DV_curves)
%     DV_msds(:,i) = DV_curves(i,1).msd;
%     end
%     
%     for i = 1:length(DAV_curves)
%     DAV_msds(:,i) = DAV_curves(i,1).msd;
%     end
%     
%     for i = 1:length(DRV_curves)
%     DRV_msds(:,i) = DRV_curves(i,1).msd;
%     end




% if isempty(DV_curves) == 0 && length(DV_curves)>= 4
%     DV_bayes   = msd_curves_bayes(DV_curves(1,1).tau, DV_msds*1E12, msd_params);
% else
%     DV_bayes = [];
% end
% 
% if isempty(DAV_curves) == 0 && length(DAV_curves)>= 4
%     DAV_bayes   = msd_curves_bayes(DAV_curves(1,1).tau, DAV_msds*1E12, msd_params);
% else
%     DAV_bayes = [];
% end
% 
% if isempty(DRV_curves) == 0 && length(DRV_curves)>= 4
%     DRV_bayes   = msd_curves_bayes(DRV_curves(1,1).tau, DRV_msds*1E12, msd_params);
% else
%     DRV_bayes = [];
% end



% DV_table  = bayes_create_table(DV_bayes);
% DAV_table = bayes_create_table(DAV_bayes);
% DRV_table = bayes_create_table(DRV_bayes);


% model_table.DV  = DV_table;
% model_table.DAV = DAV_table;
% model_table.DRV = DRV_table;


