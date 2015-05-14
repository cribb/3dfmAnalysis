function bar_MSD_DADR = plot_MSD_DADR(bayes_output, bayes_model_output)

spec_tau = 1;

for k = 1:length(bayes_model_output)

    vmsd = bayes_model_output(k,1).DADR_curve_struct;
    msd_struct = msdstat(vmsd);
    
    [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                          - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
            
    logmsdvalue = msd_struct.mean_logmsd(minloc(1));
            
    msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
    msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
    
    MSD_DADR(k) = msdvalue; % leaves MSD in m^2
    MSD_DADR_se(k) = 10.^(logmsdvalue + msderr) - 10.^(logmsdvalue);
            
    clist{k,:} = bayes_output(k,1).name;
        
end

    %condition_list = clist';

    bar_MSD_DADR = figure;
    barwitherr(MSD_DADR_se, MSD_DADR)
    title('Traj. of DA and DR models')
    ylim([0 0.5E-14])
    set(gca, 'XTickLabel', clist);
    ylabel('MSD [m^2] at \tau = 1 sec');
    pretty_plot;
        
end