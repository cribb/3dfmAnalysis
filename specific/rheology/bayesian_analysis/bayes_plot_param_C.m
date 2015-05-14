function bar_param_C = bayes_plot_param_C(bayes_model_output)
%BAYES_PLOT_PARAM_C 
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

% initializing the C parameter list
condition_list = {};
C_param_list = [];
C_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list     = [condition_list, bayes_model_output(k,1).name];
    C_param_list       = [C_param_list bayes_model_output(k,1).N(1,1)];
    C_param_error_list = [C_param_error_list bayes_model_output(k,1).N(1,2)];
    
end

bar_param_C = figure;
barwitherr(C_param_error_list, C_param_list)
title('Null Model vs Condition')
ylim([0 0.001])
ylabel('N [um^2]');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end