function bar_param_DR_R = plot_param_DR_R(param_struct)
% PLOT_PARAM_DR_R
%
% Plots parameters based on ensemble statistics
%
% Created:       4/4/14, Luke Osborne
% Last modified: 4/4/14, Luke Osborne 
%

DR_R_vector = zeros(length(param_struct),1);
DR_R_error = zeros(length(param_struct),1);
labels{length(param_struct),1} = [];

for k = 1:length(param_struct)
    
    DR_R_vector(k,1) = param_struct(k,1).DR_R_mean;
    DR_R_error(k,1)  = param_struct(k,1).DR_R_se;
    labels{k,:}   = param_struct(k,1).name;
        
end 

bar_param_DR_R = figure;
barwitherr(DR_R_error, DR_R_vector)
title('Radius of Confinement vs Condition')
ylim([0 0.3])
ylabel('R [um]');
set(gca, 'XTickLabel', labels);
pretty_plot;

end