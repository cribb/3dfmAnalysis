function bar_G_DA_norm = plot_bar_G_DA_norm(bayes_output, bayes_model_output, k_norm)

spec_tau = 1;

for k = 1:length(bayes_output)

    if ~isempty(bayes_model_output(k,1).DA_curve_struct)
        vmsd = bayes_model_output(k,1).DA_curve_struct;
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
   
end  % for loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% normalizing G' bar plot  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:length(bayes_output)
    
    G_norm(k)     = G(k) ./ G(k_norm);
    G_err_norm(k) = G_err(k) .* G_norm(k); 
    
end  % for loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plotting 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bar_G_DA_norm = figure;
barwitherr(G_err_norm, G_norm)
title('Norm. stiffness at \tau = 1 sec for DA model')
ylim([0 1.5])
set(gca,'YTick',[0 0.25 0.5 0.75 1 1.25 1.5])
set(gca, 'XTickLabel', clist);
ylabel('Normalized G');
pretty_plot;
        
end  % function
