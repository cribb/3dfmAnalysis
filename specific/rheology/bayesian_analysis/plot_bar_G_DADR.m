function bar_G_DADR = plot_bar_G_DADR(bayes_output, bayes_model_output)

spec_tau = 1;

for k = 1:length(bayes_output)

    vmsd = bayes_model_output(k,1).DADR_curve_struct;
    
    v = ve(vmsd, 1E-6, 'f', 'n');
    
    [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value
    
    
    G(k)     = v.gp(minloc);
    G_err(k) = v.error.gp(minloc); 
    
    clist{k,:} = bayes_output(k,1).name;
         
end

    bar_G_DADR = figure;
    barwitherr(G_err, G)
    title('Stiffness at \tau = 1 sec for DA and DR models vs Condition')
    ylim([0 0.5])
    set(gca, 'XTickLabel', clist);
    ylabel('G [Pa]');
    pretty_plot;
        
end
