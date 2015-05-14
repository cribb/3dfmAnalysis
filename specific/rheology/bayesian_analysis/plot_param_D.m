function bar_param_D = plot_param_D(param_struct)
% PLOT_PARAM_D
%
% Plots parameters based on ensemble statistics
%
% Created:       4/4/14, Luke Osborne
% Last modified: 4/4/14, Luke Osborne 
%

D_vector = zeros(length(param_struct),1);
D_error = zeros(length(param_struct),1);
labels{length(param_struct),1} = [];

for k = 1:length(param_struct)
    
    D_vector(k,1) = param_struct(k,1).D_mean;
    D_error(k,1)  = param_struct(k,1).D_se;
    labels{k,:}   = param_struct(k,1).name;
        
end 

bar_param_D = figure;
barwitherr(D_error, D_vector)
title('Diffusion Coefficient vs Condition')
ylim([0 0.08])
ylabel('D [um^2/s]');
set(gca, 'XTickLabel', labels);
pretty_plot;

end