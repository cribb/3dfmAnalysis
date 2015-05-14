function plot_alphaBoxPlot = pan_plot_alphaBoxPlot( bayes_model_output, alpha_matrix )






distributions = alpha_matrix;

for i = 1:length(bayes_model_output)
    labels{i,:} = bayes_model_output(i,1).name;
end

plot_alphaBoxPlot = figure;
boxplot(distributions, 'labels', labels, 'notch', 'on');
title('Alpha Distributions vs Condition')
ylim([0,0.85])    
set(gca, 'YTick', [0; 0.1; 0.2; 0.3; 0.4; 0.5; 0.6; 0.7; 0.8])    
ylabel('alpha of DA model');
pretty_plot;

end

