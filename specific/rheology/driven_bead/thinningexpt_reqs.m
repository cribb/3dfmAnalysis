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

fprintf(' eta0=%12g2 \n eta_inf=%12g2 \n lambda=%12g2 \n m=%12g2 \n n=%12g2 \n R^2=%12g2 \n\n', eta0, etainf, lambda, m, n, R_square);

report_string = { ['\eta_0 = ' num2str(eta0)], ...
                  ['\eta_\infty = ' num2str(etainf)], ...
                  ['\lambda = ' num2str(lambda)], ...
                  ['m = ', num2str(m)], ...
                  ['n = ', num2str(n)], ...
                  ['R^2 = ', num2str(R_square)] };
              
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
    ax = gca;
    xax = get(ax, 'XLim'); xmin = xax(1); xmax = xax(2);
    yax = get(ax, 'YLim'); ymin = yax(1); ymax = yax(2);
    xloc = xmin + 0.2*(xmax-xmin);
    yloc = ymin + 0.2*(ymax-ymin);
    text(xloc, yloc, report_string);
pretty_plot;    

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

