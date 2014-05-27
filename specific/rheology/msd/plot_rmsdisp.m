function h = plot_rmsdisp(d, h, optstring)
% PLOT_RMSDISP plots the graph of RMS displacement versus tau for an aggregate number of beads 
%
% 3DFM function
% specific\rheology\msd
%
% plot_rmsdisp(d,h,optstring)
%
% where "d" is the input structure and should contain the RMS displacement, the tau 
%       value (window size), and the number of beads in a given window.
%       "h" is the figure handle in which to put the plot.  If h is not
%       used, a new figure is generated.
%      "optstring" is a string containing 'a' to plot all individual paths, 'm'
%      to plot the mean RMS displacement, and 'e' to include errorbars on mean,
%      'u' to plot msd in units of um^2

if nargin < 3 || isempty(optstring)
    optstring = 'me';
end

if nargin < 2 || isempty(h)
    h = figure;
else
    brought_own_figure_handle = 1;
end

if nargin < 1 || isempty(d.tau)
    logentry('No data to plot.  Exiting now.');
    close(h);
    h = [];
    return;
end

if strcmpi(optstring, 'u')
    d.mean_logrmsdisp = d.mean_logrmsdisp + 12;
    d.rmsdisp = d.rmsdisp * 1e12;
end

% calculate statistical measures for msd and plant into data structure
d = msdstat(d);

% creating the plot
if ~exist('brought_own_figure_handle')
    figure(h);
end
    
if strcmpi(optstring, 'a')
    plot(d.logtau, d.logrmsdisp, 'b');
elseif strcmpi(optstring, 'm')
    plot(d.mean_logtau, d.mean_logrmsdisp, 'k.-');
elseif strcmpi(optstring, 'am')
    plot(d.logtau, d.logrmsdisp, 'b', d.mean_logtau, d.mean_logrmsdisp, 'k.-');
elseif strcmpi(optstring, 'me') || strcmpi(optstring, 'e')
    errorbar(d.mean_logtau, d.mean_logrmsdisp, d.rmsdisp_err, '.-', 'Color', 'cyan', 'LineWidth', 2);
elseif strcmpi(optstring, 'ame')
    plot(log10(d.tau), log10(d.rmsdisp), 'b-');
    hold on;
        errorbar(d.mean_logtau, d.mean_logrmsdisp, d.rmsdisp_err, '.-', 'Color', 'cyan', 'LineWidth', 2);
    hold off;
end

ch = get(gca, 'Children');
for k = 1:length(ch)
    set(ch(k), 'DisplayName', num2str(length(ch)-k));
end

xlabel('log_{10}(\tau) [s]');
if strcmpi(optstring,'u')
    ylabel('log_{10}(RMS disp) [\mum]');
else
    ylabel('log_{10}(RMS disp) [m]');
end
grid on;
pretty_plot;
refresh(h); 

