function bar_param_DA_A = bayes_plot_param_DA_A(bayes_model_output)
%BAYES_PLOT_PARAM_DA_A 
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

% initializing the DA_A parameter list
condition_list = {};
DA_A_param_list = [];
DA_A_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list        = [condition_list, bayes_model_output(k,1).name];
    DA_A_param_list       = [DA_A_param_list bayes_model_output(k,1).DA(4,1)];
    DA_A_param_error_list = [DA_A_param_error_list bayes_model_output(k,1).DA(4,2)];
    
end

bar_param_DA_A = figure;
barwitherr(DA_A_param_error_list, DA_A_param_list)
title('Alpha vs Condition')
ylim([0 1])
ylabel('alpha');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end