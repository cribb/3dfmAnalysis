function avgMSD_DR = bayes_plot_avgMSD_DR(bayes_model_output)
% BAYES_PLOT_MSD_BY_COLOR
%
% Plots msd trajectores by model, where each model is a different color
%
% Created:       4/7/14, Luke Osborne
% Last modified: 4/7/14, Luke Osborne 
%

avgMSD_DR = figure;
hold on;

for k = 1:length(bayes_model_output)
    
    DR(k,1) = bayes_model_output(k,1).DR_curve_struct;
    
    % Compute the MSD statistics quantities used for plotting
   
    DRstat(k,1) = msdstat(DR(k,1));
   
    % Generate the plot
   
    errorbar(DRstat(k,1).mean_logtau, DRstat(k,1).mean_logmsd, DRstat(k,1).msderr, 'r');
        
end 

    hold off;  
  
xlabel('log_{10}(\tau) [s]');
ylabel('log_{10}(MSD) [m^2]');

ylim([-17,-11])
xlim([-2,2])

grid on;
box on;
pretty_plot;


return;