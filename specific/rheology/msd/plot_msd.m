function h = plot_msd(d, h, optstring)
% PLOT_MSD plots the graph of mean square displacement versus tau for an aggregate number of beads 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%
%
% plot_msd(d)
%
% where "d" is the input structure and should contain the mean square displacement, the tau 
%       value (window size), and the number of beads in a given window.
%       "h" is the figure handle in which to put the plot.  If h is not
%       used, a new figure is generated.
%      "optstring" is a string containing 'a' to plot all individual paths, 'm'
%      to plot the mean msd function, and 'e' to include errorbars on mean,
%      'u' to plot msd in units of um^2
%

if nargin < 3 || isempty(optstring)
    optstring = 'me';
end

if nargin < 2 || isempty(h)
    h = figure;
end

% calculate statistical measures for msd and plant into data structure
d = msdstat(d);

% creating the plot
figure(h);

if strcmpi(optstring, 'u')
    d.mean_logmsd = d.mean_logmsd + 12;
    d.msd = d.msd * 1e12;
end

if strcmpi(optstring, 'a')
    plot(d.logtau, d.logmsd, 'b');
elseif strcmpi(optstring, 'm')
    plot(d.mean_logtau, d.mean_logmsd, 'k.-');
elseif strcmpi(optstring, 'am')
    plot(d.logtau, d.logmsd, 'b', d.mean_logtau, d.mean_logmsd, 'k.-');
elseif strcmpi(optstring, 'me') || strcmpi(optstring, 'e')
    errorbar(d.mean_logtau, d.mean_logmsd, d.msderr, 'k.-');
elseif strcmpi(optstring, 'ame')
    plot(log10(d.tau), log10(d.msd), 'b-');
    hold on;
        errorbar(d.mean_logtau, d.mean_logmsd, d.msderr, 'k.-');
    hold off;
end

ch = get(gca, 'Children');
for k = 1:length(ch)
    set(ch(k), 'DisplayName', num2str(length(ch)-k));
end

xlabel('log_{10}(\tau) [s]');
if strcmpi(optstring,'u')
    ylabel('log_{10}(MSD) [\mum^2]');
else
    ylabel('log_{10}(MSD) [m^2]');
end
grid on;
pretty_plot;
refresh(h);    

return;
