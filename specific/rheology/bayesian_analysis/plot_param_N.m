function bar_param_N = plot_param_N(param_struct)
% PLOT_PARAM_N
%
% Plots parameters based on ensemble statistics
%
% Created:       4/4/14, Luke Osborne
% Last modified: 4/4/14, Luke Osborne 
%

N_vector = zeros(length(param_struct),1);
N_error = zeros(length(param_struct),1);
labels{length(param_struct),1} = [];

for k = 1:length(param_struct)
    
    N_vector(k,1) = param_struct(k,1).N_mean;
    N_error(k,1)  = param_struct(k,1).N_se;
    labels{k,:}   = param_struct(k,1).name;
        
end 

bar_param_N = figure;
barwitherr(N_error, N_vector)
title('Null Model vs Condition')
ylim([0 0.001])
ylabel('N [um^2]');
set(gca, 'XTickLabel', labels);
pretty_plot;

end

