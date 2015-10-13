function [ LOG10_msdDA_matrix ] = gen_msdDA_matrix( bayes_model_output )

spec_tau = 1;

for k = 1:length(bayes_model_output)

    vmsd = bayes_model_output(k,1).DA_curve_struct;
    msd_struct = msdstat(vmsd);
    
    [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                          - log10(spec_tau)).^2) );
    
    if isfield(msd_struct, 'msd')
        new_column_msd  = transpose(msd_struct.msd(minloc(1),:));
        new_column_Nestimates   = transpose(msd_struct.Nestimates(minloc(1),:));
        new_column_trackerID = transpose(msd_struct.trackerID);
%         new_column_firstposX = transpose(msd_struct.firstposX);
%         new_column_firstposY = transpose(msd_struct.firstposY);
        new_column_pass = transpose(msd_struct.pass);
        new_column_well = transpose(msd_struct.well);
        new_column_area = transpose(msd_struct.area);
        new_column_sens = transpose(msd_struct.sens);
        
        if length(new_column_msd) <= 500
            a = 500 - length(new_column_msd);
            dummy_matrix = NaN(a,1);
            new_column_msd  = vertcat(new_column_msd , dummy_matrix);
            new_column_Nestimates   = vertcat(new_column_Nestimates  , dummy_matrix);
            new_column_trackerID = vertcat(new_column_trackerID , dummy_matrix);
%             new_column_firstposX = vertcat(new_column_firstposX , dummy_matrix);
%             new_column_firstposY = vertcat(new_column_firstposY , dummy_matrix);
            new_column_pass = vertcat(new_column_pass, dummy_matrix); 
            new_column_well = vertcat(new_column_well, dummy_matrix); 
            new_column_area = vertcat(new_column_area, dummy_matrix); 
            new_column_sens = vertcat(new_column_sens, dummy_matrix); 
        else
            fprintf('There are more than 500 beads.  Need to change the dummy_matrix limits.');
        end

    else
        new_column_msd  = NaN(500,1);
        new_column_Nestimates   = NaN(500,1);
        new_column_trackerID = NaN(500,1);
%         new_column_firstposX = NaN(500,1);
%         new_column_firstposY = NaN(500,1);
        new_column_pass = NaN(500,1);
        new_column_well = NaN(500,1);
        new_column_area = NaN(500,1);
        new_column_sens = NaN(500,1);
    end
    
        msd_matrix(:,k) = new_column_msd;
         Nestimates_matrix(:,k) = new_column_Nestimates;
  trackerID_matrix(:,k) = new_column_trackerID;
%   firstposX_matrix(:,k) = new_column_firstposX;
%   firstposY_matrix(:,k) = new_column_firstposY;
       pass_matrix(:,k) = new_column_pass;
       well_matrix(:,k) = new_column_well;
       area_matrix(:,k) = new_column_area;
       sens_matrix(:,k) = new_column_sens;
    
end



LOG10_msdDA_matrix.spec_tau = spec_tau;
LOG10_msdDA_matrix.logtau   = log10(minval);
LOG10_msdDA_matrix.logmsd   = log10(msd_matrix);
LOG10_msdDA_matrix.Nestimates = Nestimates_matrix;
LOG10_msdDA_matrix.pass     = pass_matrix;
LOG10_msdDA_matrix.well     = well_matrix;
LOG10_msdDA_matrix.trackerID= trackerID_matrix;
% LOG10_msdDA_matrix.firstposX= firstposX_matrix;
% LOG10_msdDA_matrix.firstposY= firstposY_matrix;
LOG10_msdDA_matrix.channel  = pan_get_channel_id(well_matrix);
LOG10_msdDA_matrix.area     = area_matrix;
LOG10_msdDA_matrix.sens     = sens_matrix;

return;

