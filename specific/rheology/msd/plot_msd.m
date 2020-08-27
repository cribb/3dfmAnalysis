function h = plot_msd(d_in, h, optstring)
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

if nargin < 1 || isempty(d_in.tau)
    logentry('No data to plot.  Exiting now.');
    close(h);
    h = [];
    return;
end

% calculate statistical measures for msd and plant into data structure
d = msdstat(d_in);

% creating the plot
figure(h);
    
if strcmpi(optstring, 'u')
    d.mean_logmsd = d.mean_logmsd + 12;
    d.msd = d.msd * 1e12;
end

gray = [0.65, 0.65, 0.65];
black = [0 0 0];

if strcmpi(optstring, 'a')
    plot(d.logtau, d.logmsd, 'Color', gray);
elseif strcmpi(optstring, 'm')
    plot(d.mean_logtau, d.mean_logmsd, black);
elseif strcmpi(optstring, 'am')
    hold on;
    plot(d.logtau, d.logmsd, 'Color', gray);
    plot(d.mean_logtau, d.mean_logmsd, 'Color', black, 'LineWidth', 2);
    hold off;
elseif strcmpi(optstring, 'me') || strcmpi(optstring, 'e')
    errorbar(d.mean_logtau, d.mean_logmsd, d.msderr, '.-', 'Color', black, 'LineWidth', 2);
elseif strcmpi(optstring, 'ame')
    plot(log10(d.tau), log10(d.msd), 'Color', gray);
    hold on;
        errorbar(d.mean_logtau, d.mean_logmsd, d.msderr, '.-', 'Color', black, 'LineWidth', 2);
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
% legend('off');
pretty_plot;
refresh(h);    

return;


% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'plot_msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    