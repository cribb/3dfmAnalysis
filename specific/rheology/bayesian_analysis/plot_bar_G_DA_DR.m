function bar_G_DA_DR = plot_bar_G_DA_DR(bayes_output, bayes_model_output)

spec_tau = 1;

for k = 1:length(bayes_output)

    if ~isempty(bayes_model_output(k,1).DADR_curve_struct)
        vmsd = bayes_model_output(k,1).DADR_curve_struct;
        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');
        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
    else
        vmsd = NaN;
        v.gp = NaN;
        v.error.gp = NaN;
        minloc = 1;        
    end
  
    G(k)     = v.gp(minloc);
    G_err(k) = v.error.gp(minloc); 
    
    clist{k,:} = bayes_output(k,1).name;
         
end

    bar_G_DA_DR = figure;
    barwitherr(G_err, G)
    title('Stiffness at \tau = 1 sec for DA and DR models')
    ylim([0 1])
    set(gca, 'XTickLabel', clist);
    ylabel('G [Pa]');
    pretty_plot;
        
end
