function v = plot_cap_creep(t, J, h, mytitle)

if nargin < 4 || isempty(mytitle)
    mytitle= '';
end

if nargin < 3 || isempty(h)
    h = figure; 
end

if nargin < 2
    error('No data specified.');
end

h = figure; 
set(h, 'Name', 'creep');
plot(t, J, 'o-','Color',[0.502 0.502 0.502]);
xlabel('time, t [s]');
ylabel('compliance, J(t) [1/Pa]');
grid on;
title(mytitle);

pretty_plot;

v = 0;

