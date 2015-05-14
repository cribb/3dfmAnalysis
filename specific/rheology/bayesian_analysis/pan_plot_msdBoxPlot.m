function plot_msdBoxPlot = pan_plot_msdBoxPlot( bayes_model_output, LOG10_msdDA_matrix )






distributions = LOG10_msdDA_matrix;

for i = 1:length(bayes_model_output)
    labels{i,:} = bayes_model_output(i,1).name;
end

plot_msdBoxPlot = figure;
boxplot(distributions, 'labels', labels, 'notch', 'on');
title('DA model MSD Distributions')
ylim([-16, -12])    
set(gca, 'YTick', [-16; -15; -14; -13; -12])    
ylabel('log_{10} MSD [m^2] at \tau = 1 sec');
pretty_plot;

end

