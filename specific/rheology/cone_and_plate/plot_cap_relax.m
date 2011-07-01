function h = plot_cap_relax(time, Gt, h, mytitle)
% PLOT_CAP_RELAX  Plots stress relaxation curves for TA cone and plate data.
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 06/17/2011  (jcribb)
%  
%  
%  h = plot_cap_relax(t, Gt, h, mytitle)  
%   
%  where "h" is the input/output figure handle
%  "time" is a vector containing time values in [s]
%  "Gt" is a vector containing modulus values in [Pa]
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

plot(log10(time), log10(Gt), 'o','Color','b');
xlabel('log_{10}(time) [s]');
ylabel('log_{10}(G(t)) [Pa]');
title(mytitle);
pretty_plot;

return;


