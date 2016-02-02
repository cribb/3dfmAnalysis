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
    
    
    if ~isempty(bayes_output(k,1).original_curve_msd)
        
        % determining the indices of the structure for each model type 

        N_row_index   = strcmp(bayes_output(k,1).model(:), 'N');
        D_row_index   = strcmp(bayes_output(k,1).model(:), 'D');
        DA_row_index  = strcmp(bayes_output(k,1).model(:), 'DA');
        DR_row_index  = strcmp(bayes_output(k,1).model(:), 'DR');
        V_row_index   = strcmp(bayes_output(k,1).model(:), 'V');


        % generating a list of original curves structures (taus, msds, n, ns, window) for each model type

        N_curves   = bayes_output(k,1).original_curve_msd(N_row_index, 1);
        D_curves   = bayes_output(k,1).original_curve_msd(D_row_index, 1);
        DA_curves  = bayes_output(k,1).original_curve_msd(DA_row_index, 1);
        DR_curves  = bayes_output(k,1).original_curve_msd(DR_row_index, 1);
        V_curves   = bayes_output(k,1).original_curve_msd(V_row_index, 1);

        
        for i = 1:length(N_curves)
            N_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,N_row_index');
            N_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,N_row_index');
            N_curve_struct.well      = bayes_output(k,1).agg_data.well(1,N_row_index');
%             N_curve_struct.firstposX = bayes_output(k,1).agg_data.firstposX(1, N_row_index');
%             N_curve_struct.firstposY = bayes_output(k,1).agg_data.firstposY(1, N_row_index');
            N_curve_struct.area      = bayes_output(k,1).agg_data.area(1,N_row_index');
            N_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,N_row_index');
            N_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,N_row_index');
            N_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,N_row_index');
%             N_curve_struct.Ntrackers = bayes_output(k,1).agg_data.Ntrackers;
            N_curve_struct.Nestimates= bayes_output(k,1).agg_data.Nestimates(:,N_row_index');
            N_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(D_curves)
            D_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,D_row_index');
            D_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,D_row_index');
            D_curve_struct.well      = bayes_output(k,1).agg_data.well(1,D_row_index');
%             D_curve_struct.firstposX = bayes_output(k,1).agg_data.firstposX(1, D_row_index');
%             D_curve_struct.firstposY = bayes_output(k,1).agg_data.firstposY(1, D_row_index');
            D_curve_struct.area      = bayes_output(k,1).agg_data.area(1,D_row_index');
            D_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,D_row_index');            
            D_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,D_row_index');
            D_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,D_row_index');
%             D_curve_struct.Ntrackers = bayes_output(k,1).agg_data.Ntrackers;
            D_curve_struct.Nestimates= bayes_output(k,1).agg_data.Nestimates(:,D_row_index');
            D_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(DA_curves)
            DA_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,DA_row_index');
            DA_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,DA_row_index');
            DA_curve_struct.well      = bayes_output(k,1).agg_data.well(1,DA_row_index');
%             DA_curve_struct.firstposX = bayes_output(k,1).agg_data.firstposX(1, DA_row_index');
%             DA_curve_struct.firstposY = bayes_output(k,1).agg_data.firstposY(1, DA_row_index');            
            DA_curve_struct.area      = bayes_output(k,1).agg_data.area(1,DA_row_index');
            DA_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,DA_row_index'); 
            DA_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,DA_row_index');
            DA_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,DA_row_index');
%             DA_curve_struct.Ntrackers = bayes_output(k,1).agg_data.Ntrackers;
            DA_curve_struct.Nestimates= bayes_output(k,1).agg_data.Nestimates(:,DA_row_index');
            DA_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(DR_curves)
            DR_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,DR_row_index');
            DR_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,DR_row_index');
            DR_curve_struct.well      = bayes_output(k,1).agg_data.well(1,DR_row_index');
%             DR_curve_struct.firstposX = bayes_output(k,1).agg_data.firstposX(1, DR_row_index');
%             DR_curve_struct.firstposY = bayes_output(k,1).agg_data.firstposY(1, DR_row_index');            
            DR_curve_struct.area      = bayes_output(k,1).agg_data.area(1,DR_row_index');
            DR_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,DR_row_index');             
            DR_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,DR_row_index');
            DR_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,DR_row_index');
%             DR_curve_struct.Ntrackers = bayes_output(k,1).agg_data.Ntrackers;
            DR_curve_struct.Nestimates= bayes_output(k,1).agg_data.Nestimates(:,DR_row_index');
            DR_curve_struct.window    = bayes_output(k,1).agg_data.window;
        end

        for i = 1:length(V_curves)
            V_curve_struct.trackerID = bayes_output(k,1).agg_data.trackerID(1,V_row_index');
            V_curve_struct.pass      = bayes_output(k,1).agg_data.pass(1,V_row_index');
            V_curve_struct.well      = bayes_output(k,1).agg_data.well(1,V_row_index');
%             V_curve_struct.firstposX = bayes_output(k,1).agg_data.firstposX(1, V_row_index');
%             V_curve_struct.firstposY = bayes_output(k,1).agg_data.firstposY(1, V_row_index');            
            V_curve_struct.area      = bayes_output(k,1).agg_data.area(1,V_row_index');
            V_curve_struct.sens      = bayes_output(k,1).agg_data.sens(1,V_row_index');             
            V_curve_struct.tau       = bayes_output(k,1).agg_data.tau(:,V_row_index');
            V_curve_struct.msd       = bayes_output(k,1).agg_data.msd(:,V_row_index');
%             V_curve_struct.Ntrackers = bayes_output(k,1).agg_data.Ntrackers;
            V_curve_struct.Nestimates= bayes_output(k,1).agg_data.Nestimates(:,V_row_index');
            V_curve_struct.window    = bayes_output(k,1).agg_data.window;
            %V_curve_struct.window(:,i) = bayes_output(k,1).agg_data.window;
        end


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
%             DADR_curve_struct.firstposX = horzcat(DA_curve_struct.firstposX, DR_curve_struct.firstposX);
%             DADR_curve_struct.firstposY = horzcat(DA_curve_struct.firstposY, DR_curve_struct.firstposY);
            DADR_curve_struct.area = horzcat(DA_curve_struct.area, DR_curve_struct.area);
            DADR_curve_struct.sens = horzcat(DA_curve_struct.sens, DR_curve_struct.sens);
            DADR_curve_struct.tau = horzcat(DA_curve_struct.tau, DR_curve_struct.tau);
            DADR_curve_struct.msd = horzcat(DA_curve_struct.msd, DR_curve_struct.msd);
%             DADR_curve_struct.Ntrackers = DA_curve_struct.Ntrackers;
            DADR_curve_struct.Nestimates = horzcat(DA_curve_struct.Nestimates, DR_curve_struct.Nestimates);
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



    else   % isempty bayes_output(k,1).original_curve_msd
        bayes_model_output(k,1).name     = name;
        bayes_model_output(k,1).filename = filename;

        bayes_model_output(k,1).N_curve_struct   = [];
        bayes_model_output(k,1).D_curve_struct   = [];
        bayes_model_output(k,1).DA_curve_struct  = [];
        bayes_model_output(k,1).DR_curve_struct  = [];
        bayes_model_output(k,1).V_curve_struct   = [];

        bayes_model_output(k,1).DADR_curve_struct   = [];
    end    % isempty bayes_output(k,1).original_curve_msd


clear N_curve_struct;
clear D_curve_struct;
clear DA_curve_struct;
clear DR_curve_struct;
clear V_curve_struct;

clear DADR_curve_struct;
   
end % for loop

end % function

