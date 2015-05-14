function bar_param_DR_R = bayes_plot_param_DR_R(bayes_model_output)
%BAYES_PLOT_PARAM_DR_R 
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

% initializing the DR_R parameter list
condition_list = {};
DR_R_param_list = [];
DR_R_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list        = [condition_list, bayes_model_output(k,1).name];
    DR_R_param_list       = [DR_R_param_list bayes_model_output(k,1).DR(6,1)];
    DR_R_param_error_list = [DR_R_param_error_list bayes_model_output(k,1).DR(6,2)];
    
end

bar_param_DR_R = figure;
barwitherr(DR_R_param_error_list, DR_R_param_list)
title('Radius of Confinement vs Condition')
ylim([0 1])
ylabel('R [um]');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end