function F = thinningexpt_reqs(gammadot, appvisc, d, plot_title)
% 3DFM function  
% Rheology/DMBR
% last modified 09-Sep-2008 (jcribb)
%  
% This function generates the figure/calibration that is used to examine 
% the required forces 'F' needed to obtain maximum shear rates 'gammadot' 
% around an actuated sphere with radius 'a'.  
%
% The material around the sphere is assumed to be a shear-thinning material
% with a zero-shear viscosity 'eta0' and an infinite-shear viscosity
% 'etainf'.  The infinite-shear value is assumed to be zero if none is
% defined.
%
%  
%  [F] = thinningexpt_reqs(gammadot, appvisc, d, plot_title)
%   
%  where "F" contains the correspondence between force, shear rate, and viscosity
%        "gammadot" is strain-rate in units of [1/s] 
%        "appvisc" is the applied viscosity in [Pa s]
%        "d" is bead diameter(s). can be a vector.
%        "plot_title" is string used as the title for the outputted figure
%


d = d(:);
d = sort(d);

[eta0, etainf, lambda, m, n, R_square, appviscfit] = carreau_model_fit(gammadot, appvisc, 'y');

F = thinning_force(gammadot, d./2, lambda, eta0, etainf, m, n);



plotF = fliplr(F);

bead_diameters = [num2str(flipud(d/1e-6)) repmat(' \mum', length(d), 1)];

h = figure;

figure(h);
subplot(2,1,1);
loglog(gammadot, appvisc, 'k.', gammadot, appviscfit, 'r');
title(plot_title);
xlabel('strain rate [1/s]');
ylabel('apparent viscosity, \eta_{app}');
grid on;
grid minor;

figure(h);
subplot(2,1,2);
loglog(gammadot, plotF*1e12);
xlabel('strain rate [1/s]');
ylabel('Required Force [pN]');
grid on;
grid minor;
legend(bead_diameters);
title('3dfm/HTS Requirements');
pretty_plot;

