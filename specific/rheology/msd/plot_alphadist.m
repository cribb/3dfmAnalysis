function h = plot_alphadist(d, h, optstring)
% PLOT_ALPHAVSTAU plots the graph of slope (alpha) of mean square displacement values versus tau for an aggregate number of beads 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%
%
% plot_msd(d)
%
% where "d" is the input structure vrom the ve function and should contain the mean square displacement, the tau 
%       value (window size), and the number of beads in a given window.
%       "h" is the figure handle in which to put the plot.  If h is not
%       used, a new figure is generated.
%      "optstring" is a string containing 'a' to plot all individual paths, 'm'
%      to plot the mean msd function, and 'e' to include errorbars on mean,
%      'u' to plot msd in units of um^2
%


% % % 
% % % if nargin < 2 || isempty(h)
% % %     h = figure;
% % % end
% % % 
% % % if nargin < 1 || isempty(d.tau)
% % %     logentry('No data to plot.  Exiting now.');
% % %     close(h);
% % %     h = [];
% % %     return;
% % % end
% % % 
% % % % calculate statistical measures for msd and plant into data structure
% % % d = msdstat(d);

alpha = d;

% creating the plot
figure(h);
hist(alpha(:),25);

ch = get(gca, 'Children');
for k = 1:length(ch)
    set(ch(k), 'DisplayName', num2str(length(ch)-k));
end

xlabel('alpha');
ylabel('counts');

grid on;
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
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'plot_msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    