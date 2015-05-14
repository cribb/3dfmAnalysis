function bar_eta_DA_DR = plot_bar_eta_DA_DR(bayes_output, bayes_model_output)

spec_tau = 1;

for k = 1:length(bayes_output)

    if ~isempty(bayes_model_output(k,1).DADR_curve_struct)
        vmsd = bayes_model_output(k,1).DADR_curve_struct;
        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');
        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
    else
        vmsd = NaN;
        v.np = NaN;
        v.error.np = NaN;
        minloc = 1;        
    end
    
    eta(k)     = v.np(minloc);
    eta_err(k) = v.error.np(minloc); 
    
    clist{k,:} = bayes_output(k,1).name;
         
end

    bar_eta_DA_DR = figure;
    barwitherr(eta_err, eta)
    title('Viscosity at \tau = 1 sec for DA and DR models')
    ylim([0 1])
    set(gca, 'XTickLabel', clist);
    ylabel('\eta [Pa s]');
    pretty_plot;
        
end
