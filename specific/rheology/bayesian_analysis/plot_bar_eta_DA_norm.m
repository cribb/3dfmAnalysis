function bar_eta_DA_norm = plot_bar_eta_DA_norm(bayes_output, bayes_model_output, k_norm)

spec_tau = 1;

for k = 1:length(bayes_output)

    if ~isempty(bayes_model_output(k,1).DA_curve_struct)
        vmsd = bayes_model_output(k,1).DA_curve_struct;
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
         
end  % for loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% normalizing eta bar plot  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:length(bayes_output)
    
    eta_norm(k)     = eta(k) ./ eta(k_norm);
    eta_err_norm(k) = eta_err(k) .* eta_norm(k); 
    
end  % for loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plotting  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bar_eta_DA_norm = figure;
barwitherr(eta_err_norm, eta_norm)
title('Norm. viscosity at \tau = 1 sec for DA model')
ylim([0 1.5])
set(gca,'YTick',[0 0.25 0.5 0.75 1 1.25 1.5])
set(gca, 'XTickLabel', clist);
ylabel('Normalized \eta');
pretty_plot;
        
end  % function
