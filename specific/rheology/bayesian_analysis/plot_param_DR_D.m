function bar_param_DR_D = plot_param_DR_D(param_struct)
% PLOT_PARAM_DR_D
%
% Plots parameters based on ensemble statistics
%
% Created:       4/4/14, Luke Osborne
% Last modified: 4/4/14, Luke Osborne 
%

DR_D_vector = zeros(length(param_struct),1);
DR_D_error = zeros(length(param_struct),1);
labels{length(param_struct),1} = [];

for k = 1:length(param_struct)
    
    DR_D_vector(k,1) = param_struct(k,1).DR_D_mean;
    DR_D_error(k,1)  = param_struct(k,1).DR_D_se;
    labels{k,:}   = param_struct(k,1).name;
        
end 

bar_param_DR_D = figure;
barwitherr(DR_D_error, DR_D_vector)
title('DR Diffusion Coefficient vs Condition')
ylim([0 0.08])
ylabel('D [um^2/s]');
set(gca, 'XTickLabel', labels);
pretty_plot;

end