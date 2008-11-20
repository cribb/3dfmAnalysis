function plot_msdhist(d, h, optstring)
% PLOT_MSDHIST plots the graph of mean square displacement versus tau for an aggregate number of beads 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%
%
% plot_msdhist(d)
%
% where "d" is the input structure and should contain the mean square displacement, the tau 
%       value (window size), and the number of beads in a given window.
%       "h" is the figure handle in which to put the plot.  If h is not
%       used, a new figure is generated.
%      "optstring" is a string containing 's' to plot surface histogram, 'p'
%      to plot histogram as scaled image. 
%

if nargin < 3 || isempty(optstring)
    optstring = 'c';
end

if nargin < 2 || isempty(h)
    h = figure;
end

mytau = d.htau;
myhist = d.hist;
mybins = d.bins;

% creating the plot
figure(h);

if strcmpi(optstring, 's')
    
    surf(log10(mytau), mybins, log10(myhist));
    set(gca, 'YDir', 'normal');
    colormap(hot(256));

    xlabel('log_{10}(\tau [s])');
    ylabel('log_{10}(r^2)');
    zlabel('count');
    colorbar;

elseif strcmpi(optstring, 'p')

    imagesc(log10(mytau), mybins, (myhist));
    set(gca, 'YDir', 'normal');
    colormap(hot(256));

    xlabel('log_{10}(\tau [s])');
    ylabel('log_{10}(r^2)');
    zlabel('count');
    colorbar;

elseif strcmpi(optstring, 'ac')
end

% plot(bins, myhist, '.-');
% xlabel('log_{10}(\tau) [s]');
% ylabel('log_{10}(MSD) [m^2]');

grid on;
pretty_plot;
refresh(h);    

return;

