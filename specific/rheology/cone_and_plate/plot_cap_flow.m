function v = plot_cap_flow(srate, visc, h, mytitle)
if nargin < 4 || isempty(mytitle)
    mytitle= '';
end

if nargin < 3 || isempty(h)
    h = figure; 
end

if nargin < 2
    error('No data specified.');
end

set(h, 'Name', 'flow');
loglog(srate, visc, 'o-','Color',[0.502 0.502 0.502]);
xlabel('shear rate [1/s]');
ylabel('apparent viscosity [Pa s]');
title(mytitle);
grid on;
grid minor;
pretty_plot;

v = 0;

