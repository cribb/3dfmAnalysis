function bar_param_D = bayes_plot_param_D(bayes_model_output)
%BAYES_PLOT_PARAM_D 
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
D_param_list = [];
D_param_error_list = [];


for k = 1:length(bayes_model_output)
    
    condition_list     = [condition_list, bayes_model_output(k,1).name];
    D_param_list       = [D_param_list bayes_model_output(k,1).D(2,1)];
    D_param_error_list = [D_param_error_list bayes_model_output(k,1).D(2,2)];
    
end

bar_param_D = figure;
barwitherr(D_param_error_list, D_param_list)
title('Diffusion Coefficient vs Condition')
ylim([0 0.08])
ylabel('D [um^2/s]');
set(gca, 'XTickLabel', condition_list);
pretty_plot;

end



