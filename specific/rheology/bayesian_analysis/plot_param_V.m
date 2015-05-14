function bar_param_V = plot_param_V(param_struct)
% PLOT_PARAM_V
%
% Plots parameters based on ensemble statistics
%
% Created:       4/4/14, Luke Osborne
% Last modified: 4/4/14, Luke Osborne 
%

V_vector = zeros(length(param_struct),1);
V_error = zeros(length(param_struct),1);
labels{length(param_struct),1} = [];

for k = 1:length(param_struct)
    
    V_vector(k,1) = param_struct(k,1).V_mean;
    V_error(k,1)  = param_struct(k,1).V_se;
    labels{k,:}   = param_struct(k,1).name;
        
end 

bar_param_V = figure;
barwitherr(V_error, V_vector)
title('Flow Velocity vs Condition')
ylim([0 1])
ylabel('V [um/s]');
set(gca, 'XTickLabel', labels);
pretty_plot;

end