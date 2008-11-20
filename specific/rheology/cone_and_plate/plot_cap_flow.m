function h = plot_cap_flow(srate, visc, h, mytitle)
% PLOT_CAP_FLOW Plots viscometry (flow) curves for cone and plate data.
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
%  
%  
%  h = plot_cap_creep(t, J, h, mytitle)  
%   
%  where "h" is the input/output figure handle
%  "srate" is a vector containing shear rates in [1/s]
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


loglog(srate, visc, 'o-','Color','b');
xlabel('shear rate [1/s]');
ylabel('apparent viscosity [Pa s]');
title(mytitle);
pretty_plot;

return;


