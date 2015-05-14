function RMS_struct = bayes_calc_RMS(bayes_output, bayes_model_output)

spec_tau = 1;


for k = 1:length(bayes_model_output)

    if ~isempty(bayes_output(k,1).agg_data)
        vmsd = bayes_output(k,1).agg_data;
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                          - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value        
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
        MSD_agg(k,1) = msdvalue; % leaves MSD in m^2
        MSD_agg_se(k,1) = 10.^(logmsdvalue + msderr) - 10.^(logmsdvalue);
        RMS_agg(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_agg_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_agg(k);          % calculates the RMS error
        clist{k,:} = bayes_output(k,1).name;
        count_agg(k,1) = length(bayes_output(k,1).agg_data.tau(1,:));
    else
        MSD_agg(k,1) = NaN;
        MSD_agg_se(k,1) = NaN;
        RMS_agg(k,1) = NaN;
        RMS_agg_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
        count_agg(k,1) = NaN;
    end
    
    if ~isempty(bayes_model_output(k,1).N_curve_struct)
        vmsd = bayes_model_output(k,1).N_curve_struct;
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                              - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
        RMS_N(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_N_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_N(k);          % calculates the RMS error
        clist{k,:} = bayes_model_output(k,1).name;
        count_N(k,1) = length(bayes_model_output(k,1).N_curve_struct.tau(1,:));
    else
        RMS_N(k,1) = NaN;
        RMS_N_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
        count_N(k,1) = NaN;
    end
    
      if ~isempty(bayes_model_output(k,1).D_curve_struct)
        vmsd = bayes_model_output(k,1).D_curve_struct;
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                              - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
        RMS_D(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_D_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_D(k);          % calculates the RMS error
        clist{k,:} = bayes_model_output(k,1).name;
        count_D(k,1) = length(bayes_model_output(k,1).D_curve_struct.tau(1,:));
    else
        RMS_D(k,1) = NaN;
        RMS_D_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
        count_D(k,1) = NaN;
    end
    
    if ~isempty(bayes_model_output(k,1).DA_curve_struct)
        vmsd = bayes_model_output(k,1).DA_curve_struct;
        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                              - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1)); % pulls out MSD error
        MSD_DA(k,1) = msdvalue; % leaves MSD in m^2
        MSD_DA_se(k,1) = 10.^(logmsdvalue + msderr) - 10.^(logmsdvalue);
        RMS_DA(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_DA_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_DA(k);          % calculates the RMS error
        
        G_DA(k,1)     = v.gp(minloc);
        G_DA_se(k,1) = v.error.gp(minloc);
        eta_DA(k,1)     = v.np(minloc);
        eta_DA_se(k,1) = v.error.np(minloc); 
        
        clist{k,:} = bayes_model_output(k,1).name;
        count_DA(k,1) = length(bayes_model_output(k,1).DA_curve_struct.tau(1,:));
    else
        MSD_DA(k,1) = NaN;
        MSD_DA_se(k,1) = NaN;
        RMS_DA(k,1) = NaN;
        RMS_DA_se(k,1) = NaN;
        G_DA(k,1)     = NaN;
        G_DA_se(k,1) = NaN;
        eta_DA(k,1)     = NaN;
        eta_DA_se(k,1) = NaN; 
        clist{k,:} = bayes_output(k,1).name;
        count_DA(k,1) = NaN;
    end
    
    if ~isempty(bayes_model_output(k,1).DR_curve_struct)
        vmsd = bayes_model_output(k,1).DR_curve_struct;
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                              - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
        RMS_DR(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_DR_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_DR(k);          % calculates the RMS error
        clist{k,:} = bayes_model_output(k,1).name;
        count_DR(k,1) = length(bayes_model_output(k,1).DR_curve_struct.tau(1,:));
    else
        RMS_DR(k,1) = NaN;
        RMS_DR_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
        count_DR(k,1) = NaN;
    end
    
    if ~isempty(bayes_model_output(k,1).V_curve_struct)
        vmsd = bayes_model_output(k,1).V_curve_struct;
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                              - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
        RMS_V(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_V_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_V(k);          % calculates the RMS error
        clist{k,:} = bayes_model_output(k,1).name;
        count_V(k,1) = length(bayes_model_output(k,1).V_curve_struct.tau(1,:));
    else
        RMS_V(k,1) = NaN;
        RMS_V_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
        count_V(k,1) = NaN;
    end
    
    
    if ~isempty(bayes_output(k,1).agg_data)
        vmsd = bayes_output(k,1).agg_data;
        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');
        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );               % minloc gives index of min diff, minval gives the value
        G_agg(k,1)     = v.gp(minloc);
        G_agg_se(k,1) = v.error.gp(minloc); 
        clist{k,:} = bayes_output(k,1).name;
    else
        G_agg(k,1) = NaN;
        G_agg_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
    end
        
    if ~isempty(bayes_output(k,1).agg_data)
        vmsd = bayes_output(k,1).agg_data;
        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');
        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );               % minloc gives index of min diff, minval gives the value
        eta_agg(k,1)     = v.np(minloc);
        eta_agg_se(k,1) = v.error.np(minloc); 
        clist{k,:} = bayes_output(k,1).name;
    else
        eta_agg(k,1) = NaN;
        eta_agg_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
    end
      
    
    if ~isempty(bayes_model_output(k,1).DADR_curve_struct)
        vmsd = bayes_model_output(k,1).DADR_curve_struct;
        msd_struct = msdstat(vmsd);
        [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                          - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        logmsdvalue = msd_struct.mean_logmsd(minloc(1));
        msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
        msderr = msd_struct.msderr(minloc(1)); % pulls out MSD error
        MSD_DADR(k,1) = msdvalue; % leaves MSD in m^2
        MSD_DADR_se(k,1) = 10.^(logmsdvalue + msderr) - 10.^(logmsdvalue);
        RMS_DADR(k,1) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
        RMS_DADR_se(k,1) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_DADR(k);          % calculates the RMS error
        clist{k,:} = bayes_output(k,1).name;
        count_DADR(k,1) = length(bayes_model_output(k,1).DADR_curve_struct.tau(1,:));
    else
        MSD_DADR(k,1) = NaN;
        MSD_DADR_se(k,1) = NaN;
        RMS_DADR(k,1) = NaN;
        RMS_DADR_se(k,1) = NaN;
        clist{k,:} = bayes_output(k,1).name;
        count_DADR(k,1) = NaN;
    end
    
    
    if ~isempty(bayes_model_output(k,1).DADR_curve_struct)
        vmsd = bayes_model_output(k,1).DADR_curve_struct;
        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');
        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
        G_DADR(k,1)     = v.gp(minloc);
        G_DADR_se(k,1) = v.error.gp(minloc); 
        eta_DADR(k,1)     = v.np(minloc);
        eta_DADR_se(k,1) = v.error.np(minloc); 
        clist{k,:} = bayes_output(k,1).name;
     else
        G_DADR(k,1) = NaN;
        G_DADR_se(k,1) = NaN;
        eta_DADR(k,1)     = NaN;
        eta_DADR_se(k,1) = NaN; 
        clist{k,:} = bayes_output(k,1).name;
    end
    
    
    
% collecting outputs:  RMS disp. and SEM at 1 sec for trajectories inside
% each model
    
    
RMS_struct(k,1).name = clist{k,:};

RMS_struct(k,1).MSD_agg    = MSD_agg(k);
RMS_struct(k,1).MSD_agg_se = MSD_agg_se(k);

RMS_struct(k,1).agg        = RMS_agg(k);
RMS_struct(k,1).agg_se     = RMS_agg_se(k);
RMS_struct(k,1).G_agg      = G_agg(k);
RMS_struct(k,1).G_agg_se   = G_agg_se(k);
RMS_struct(k,1).eta_agg    = eta_agg(k);
RMS_struct(k,1).eta_agg_se = eta_agg_se(k);
RMS_struct(k,1).count_agg  = count_agg(k);


RMS_struct(k,1).N  = RMS_N(k);

RMS_struct(k,1).D  = RMS_D(k);
RMS_struct(k,1).DA = RMS_DA(k);
RMS_struct(k,1).DR = RMS_DR(k);
RMS_struct(k,1).V  = RMS_V(k);

RMS_struct(k,1).N_se  = RMS_N_se(k);
RMS_struct(k,1).D_se  = RMS_D_se(k);
RMS_struct(k,1).DA_se = RMS_DA_se(k);
RMS_struct(k,1).DR_se = RMS_DR_se(k);
RMS_struct(k,1).V_se  = RMS_V_se(k);

RMS_struct(k,1).N_count  = count_N(k);
RMS_struct(k,1).D_count  = count_D(k);
RMS_struct(k,1).DA_count = count_DA(k);
RMS_struct(k,1).DR_count = count_DR(k);
RMS_struct(k,1).V_count  = count_V(k);

RMS_struct(k,1).MSD_DA_DR       = MSD_DADR(k);
RMS_struct(k,1).MSD_DA_DR_se    = MSD_DADR_se(k);    
RMS_struct(k,1).RMS_DA_DR       = RMS_DADR(k);
RMS_struct(k,1).RMS_DA_DR_se    = RMS_DADR_se(k);
RMS_struct(k,1).G_DA_DR         = G_DADR(k);
RMS_struct(k,1).G_DA_DR_se      = G_DADR_se(k);
RMS_struct(k,1).eta_DA_DR       = eta_DADR(k);
RMS_struct(k,1).eta_DA_DR_se    = eta_DADR_se(k);
RMS_struct(k,1).count_DA_DR     = count_DADR(k);

RMS_struct(k,1).MSD_DA = MSD_DA(k);
RMS_struct(k,1).MSD_DA_se = MSD_DA_se(k);
RMS_struct(k,1).G_DA = G_DA(k);
RMS_struct(k,1).G_DA_se = G_DA_se(k);
RMS_struct(k,1).eta_DA = eta_DA(k);
RMS_struct(k,1).eta_DA_se = eta_DA_se(k);


end






end