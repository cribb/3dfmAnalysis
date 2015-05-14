function h = plot_bayes_model_bar(d, h)
%PLOT_BAYES_BIN_MODEL plots the bar graph of count versus Bayesian model for MSD trajectories
%
% Bayesian code function
% \specific\rheology\bayesian_analysis_wrapper
% last modified 11/20/13 (osborne)
%
% where
%   "d" is the input structure and should contain XXX
%   "h" is the figure handle in which to put the plot. If he is not used, a
%   new figure is generated.


% generates bar graph of count versus model
figure;
bar(model_count_list)
set(gca, 'XTickLabel', d.models);
ylabel('count');
xlabel('model type');
pretty_plot;


end