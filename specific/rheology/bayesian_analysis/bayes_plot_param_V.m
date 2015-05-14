function bar_param_V = bayes_plot_param_V(bayes_model_output)
%BAYES_PLOT_PARAM_V 
%
%
% Created:       3/8/14, Luke Osborne
% Last modified: 3/8/14, Luke Osborne 
%
% inputs:   
%          
% outputs:  
%
% 

% initializing the D parameter list
condition_list = {};
V_param_list = [];
V_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list     = [condition_list, bayes_model_output(k,1).name];
    V_param_list       = [V_param_list bayes_model_output(k,1).V(7,1)];
    V_param_error_list = [V_param_error_list bayes_model_output(k,1).V(7,2)];
    
end

bar_param_V = figure;
barwitherr(V_param_error_list, V_param_list)
title('Flow Velocity vs Condition')
ylim([0 1])
ylabel('V [um/s]');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end
