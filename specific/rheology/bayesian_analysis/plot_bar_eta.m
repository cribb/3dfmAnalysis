function bar_eta = plot_bar_eta(bayes_output)

spec_tau = 1;

for k = 1:length(bayes_output)

    if ~isempty(bayes_output(k,1).agg_data)
        vmsd = bayes_output(k,1).agg_data;

        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');

        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value


        eta(k)     = v.np(minloc);
        eta_err(k) = v.error.np(minloc); 

        clist{k,:} = bayes_output(k,1).name;
        
    else
        eta(k)     = NaN;
        eta_err(k) = NaN; 

        clist{k,:} = bayes_output(k,1).name;
    end  % if statement
         
end  % for loop

    bar_eta = figure;
    barwitherr(eta_err, eta)
    title('Viscosity at \tau = 1 sec vs Condition')
    ylim([0 1])
    set(gca, 'XTickLabel', clist);
    ylabel('\eta [Pa s]');
    pretty_plot;
        
end