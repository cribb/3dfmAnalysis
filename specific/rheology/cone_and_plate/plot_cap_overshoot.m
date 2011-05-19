function h = plot_cap_peakhold(time, visc, h, mytitle)
% PLOT_CAP_TEMP Plots temperature flow curves for cone and plate data.
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
%  
%  
%  h = plot_cap_peakhold(t, visc, h, mytitle)  
%   
%  where "h" is the input/output figure handle
%  "time" is a vector containing time values in [s]
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


plot(log10(time), log10(visc), 'o','Color','b');
% xlabel('log_{10}(time) [s]');
xlabel('log_{10}(time) [s]');
ylabel('log_{10}(apparent viscosity) [Pa s]');
title(mytitle);
pretty_plot;

return;


