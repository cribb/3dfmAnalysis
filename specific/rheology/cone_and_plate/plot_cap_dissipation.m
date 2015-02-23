function h = plot_cap_dissipation(t, theta, h, mytitle)
% PLOT_CAP_CREEP Plots creep compliance curves for cone and plate data
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
%  
%  
%  h = plot_cap_creep(t, d, h, mytitle)  
%   
%  where "h" is the input/output figure handle
%  "t" is a vector containing time points in [s]
%  "d" is a vector containing displacement values in [rad]
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


plot(t, theta*1000, 'bo-');
xlabel('time, t [s]');
ylabel('displacement, \theta [mrad]');
grid on;
title(mytitle);

pretty_plot;

return;


