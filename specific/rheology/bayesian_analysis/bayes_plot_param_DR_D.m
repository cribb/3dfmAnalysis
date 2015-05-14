function bar_param_DR_D = bayes_plot_param_DR_D(bayes_model_output)
%BAYES_PLOT_PARAM_DR_D 
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

% initializing the DR_D parameter list
condition_list = {};
DR_D_param_list = [];
DR_D_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list        = [condition_list, bayes_model_output(k,1).name];
    DR_D_param_list       = [DR_D_param_list bayes_model_output(k,1).DR(5,1)];
    DR_D_param_error_list = [DR_D_param_error_list bayes_model_output(k,1).DR(5,2)];
    
end

bar_param_DR_D = figure;
barwitherr(DR_D_param_error_list, DR_D_param_list)
title('D from DR model vs Condition')
ylim([0 0.08])
ylabel('D [um^2/s]');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end