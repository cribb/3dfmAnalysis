function h = plot_msdhist_at_tau(msd_at_tau, h)
% PLOT_MSDHIST_AT_TAU generates a simple histogram of msd values at a specific tau
%
% 3DFM function
% specific\rheology\msd
%
%
% plot_msdhist_at_tau(msd_at_tau)
%
% where "msd_at_tau" contains the msd values for a particular tau       
%       "h" is the figure handle in which to put the plot.  If h is not
%       used, a new figure is generated.
%
% Note: tau should become an input so the time scale can be placed upon the
% figure legend.
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

if nargin < 2 || isempty(h);
    h = figure;
end


% creating the plot
figure(h);
hist(msd_at_tau(:),25);

ch = get(gca, 'Children');
for k = 1:length(ch)
    set(ch(k), 'DisplayName', num2str(length(ch)-k));
end

xlabel('MSD [m^2]');
ylabel('counts');

grid on;
pretty_plot;
refresh(h);    

return;

 