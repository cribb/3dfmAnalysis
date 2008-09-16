function h = plot_cap_creep(t, J, h, mytitle)
% 3DFM function  
% Rheology/cone_and_plate 
% last modified 16-09-2008 (jcribb)
%  
% Plots creep compliance curves for cone and plate data.
%  
%  h = plot_cap_creep(t, J, h, mytitle)  
%   
%  where "h" is the input/output figure handle
%  "t" is a vector containing time points in [s]
%  "J" is a vector containing compliance values in [1/Pa]
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


plot(t, J, 'bo-');
xlabel('time, t [s]');
ylabel('compliance, J(t) [1/Pa]');
grid on;
title(mytitle);

pretty_plot;

return;


