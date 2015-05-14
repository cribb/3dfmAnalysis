function bar_param_DA_A = plot_param_DA_A(param_struct)
% PLOT_PARAM_DA_A
%
% Plots parameters based on ensemble statistics
%
% Created:       4/4/14, Luke Osborne
% Last modified: 4/4/14, Luke Osborne 
%

DA_A_vector = zeros(length(param_struct),1);
DA_A_error = zeros(length(param_struct),1);
labels{length(param_struct),1} = [];

for k = 1:length(param_struct)
    
    DA_A_vector(k,1) = param_struct(k,1).DA_A_mean;
    DA_A_error(k,1)  = param_struct(k,1).DA_A_se;
    labels{k,:}   = param_struct(k,1).name;
        
end 

bar_param_DA_A = figure;
barwitherr(DA_A_error, DA_A_vector)
title('Alpha vs Condition')
ylim([0 1])
ylabel('alpha');
set(gca, 'XTickLabel', labels);
pretty_plot;

end