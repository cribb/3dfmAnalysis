function bar_G = plot_bar_G(bayes_output)

spec_tau = 1;

for k = 1:length(bayes_output)

    if ~isempty(bayes_output(k,1).agg_data)
        vmsd = bayes_output(k,1).agg_data;

        v = ve(vmsd, bayes_output(k,1).bead_radius, 'f', 'n');

        [minval, minloc] = min( sqrt((v.tau -(spec_tau)).^2) );         % minloc gives index of min diff, minval gives the value


        G(k)     = v.gp(minloc);
        G_err(k) = v.error.gp(minloc); 

        clist{k,:} = bayes_output(k,1).name;
        
    else
        G(k)     = NaN;
        G_err(k) = NaN; 

        clist{k,:} = bayes_output(k,1).name;
    end   % if statement
         
end  % for loop

    bar_G = figure;
    barwitherr(G_err, G)
    title('Stiffness at \tau = 1 sec vs Condition')
    ylim([0 1])
    set(gca, 'XTickLabel', clist);
    ylabel('G [Pa]');
    pretty_plot;
        
end