function v = plot_cap_nsweep(strain, modulus, h, mytitle)

if nargin < 4 || isempty(mytitle)
    mytitle= '';
end

if nargin < 3 || isempty(h)
    h = figure; 
end

if nargin < 2
    error('No data specified.');
end

% Create axes
axes('Parent',     h, ...
     'YScale',     'log', ...
     'YMinorTick', 'on', ...
     'XScale',     'log',...
     'XMinorTick', 'on');
 
box('on');
hold('all');

% Create multiple lines using matrix input to loglog
G = loglog(strain, modulus,'Marker','diamond','Color',[0.502 0.502 0.502]);
set(G(1), 'MarkerFaceColor',[0.502 0.502 0.502], ...
          'DisplayName','G''');
set(G(2), 'MarkerEdgeColor',[0.502 0.502 0.502], ...
          'DisplayName','G''''');

set(h, 'Name', 'nsweep');      
xlabel('shear strain, \gamma');
ylabel('modulus, G'', G'''' [Pa]');
legend('toggle');
title(mytitle);
pretty_plot;

v = 0;

