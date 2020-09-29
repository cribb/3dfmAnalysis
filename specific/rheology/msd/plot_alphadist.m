function h = plot_alphadist(alpha, h)
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

if nargin < 2 || isempty(h)
    h = figure;
end


% creating the plot
figure(h);
histogram(alpha(:));

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

 