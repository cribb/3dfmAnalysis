function bar_RMS_D = plot_RMS_D(bayes_output, bayes_model_output)

spec_tau = 1;

for k = 1:length(bayes_model_output)

    vmsd = bayes_model_output(k,1).D_curve_struct;
    msd_struct = msdstat(vmsd);
    
    [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                          - log10(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
            
    logmsdvalue = msd_struct.mean_logmsd(minloc(1));
            
    msdvalue = 10.^( msd_struct.mean_logmsd(minloc(1)) );                   % pulls out MSD value for tau of interest, casts into meters
    msderr = msd_struct.msderr(minloc(1));                                  % pulls out MSD error
    
    RMS_vector(k) = sqrt(msdvalue)*1E9;                                         % loads RMS_vector by taking sqrt of MSD value
    RMS_err(k) = sqrt(10.^(logmsdvalue + msderr))*1E9 - RMS_vector(k);          % calculates the RMS error
    
    clist{k,:} = bayes_output(k,1).name;
        
end

    %condition_list = clist';

    bar_RMS_D = figure;
    barwitherr(RMS_err, RMS_vector)
    title('Trajectories belonging to D model')
    ylim([0 120])
    set(gca, 'XTickLabel', clist);
    ylabel('RMS Disp. at \tau = 1 sec [nm]');
    pretty_plot;
        
end
