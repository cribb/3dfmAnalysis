function h = plot_cap_temp(temp, visc, h, mytitle)
% 3DFM function  
% Rheology/cone_and_plate 
% last modified 16-09-2008 (jcribb)
%  
% Plots temperature flow curves for cone and plate data.
%  
%  h = plot_cap_creep(t, J, h, mytitle)  
%   
%  where "h" is the input/output figure handle
%  "temp" is a vector containing temperatures in [oC]
%  "visc" is a vector containing viscosity values in [Pa s]
%  "mytitle" is a string with title for figure
%

if nargin < 4 || isempty(mytitle)
    mytitle= '';
end

if nargin < 3 || isempty(h)
    h = figure; 
end

if nargin < 2
    error('No data specified.');
end


plot(temp, visc, 'o-','Color','b');
xlabel('temperature [oC]');
ylabel('apparent viscosity [Pa s]');
title(mytitle);
pretty_plot;

return;


