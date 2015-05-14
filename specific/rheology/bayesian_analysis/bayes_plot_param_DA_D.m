function bar_param_DA_D = bayes_plot_param_DA_D(bayes_model_output)
%BAYES_PLOT_PARAM_DA_D 
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

% initializing the DA_D parameter list
condition_list = {};
DA_D_param_list = [];
DA_D_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list        = [condition_list, bayes_model_output(k,1).name];
    DA_D_param_list       = [DA_D_param_list bayes_model_output(k,1).DA(3,1)];
    DA_D_param_error_list = [DA_D_param_error_list bayes_model_output(k,1).DA(3,2)];
    
end

bar_param_DA_D = figure;
barwitherr(DA_D_param_error_list, DA_D_param_list)
title('D from DA model vs Condition')
ylim([0 0.08])
ylabel('D [um^2/s]');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end