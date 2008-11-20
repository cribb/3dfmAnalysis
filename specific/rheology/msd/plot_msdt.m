function v = plot_msdt(d, h, optstring)
% PLOT_MSDT plots the graph of mean square displacement versus tau for an aggregate number of beads 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)

% % % % %
% % % % % This function plots the graph of mean square displacement versus tau for an aggregate number
% % % % % of beads.
% % % % %
% % % % % plot_msd(d)
% % % % %
% % % % % where "d" is the input structure and should contain the mean square displacement, the tau 
% % % % %       value (window size), and the number of beads in a given window.
% % % % %       "h" is the figure handle in which to put the plot.  If h is not
% % % % %       used, a new figure is generated.
% % % % %      "optstring" is a string containing 'a' to plot individual paths, 'm'
% % % % %      to plot the mean msd function, and 'e' to include errorbars on mean.
% % % % %
% % % % 
% % % % if nargin < 3 || isempty(optstring)
% % % %     optstring = 'me';
% % % % end
% % % % 
% % % % if nargin < 2 || isempty(h)
% % % %     h = figure;
% % % % end
% % % % 
% % % % % renaming input structure
% % % % tau = d.tau;
% % % % msd = d.msd;
% % % % 
% % % % if isfield(d, 'n');
% % % %     sample_count = d.n;
% % % % else
% % % %     sample_count = sum(~isnan(msd),2);
% % % %     idx = find(sample_count > 0);
% % % %     sample_count = sample_count(idx);
% % % % end
% % % % 
% % % % 
% % % % % setting up axis transforms for the figure plotted below.  You cannot plot
% % % % % errorbars on a loglog plot, it seems, so we have to set it up here.
% % % % logtau = log10(tau);
% % % % logmsd = log10(msd);
% % % % 
% % % % mean_logtau = nanmean(logtau');
% % % % mean_logmsd = nanmean(logmsd');
% % % % 
% % % % ste_logtau = nanstd(logtau') ./ sqrt(sample_count');
% % % % ste_logmsd = nanstd(logmsd') ./ sqrt(sample_count');
% % % % 
% % % % % creating the plot
% % % % figure(h);
% % % % 
% % % % if strcmpi(optstring, 'a')
% % % %     plot(logtau, logmsd, 'b');
% % % % elseif strcmpi(optstring, 'm')
% % % %     plot(mean_logtau, mean_logmsd, 'k.-');
% % % % elseif strcmpi(optstring, 'am')
% % % %     plot(logtau, logmsd, 'b', mean_logtau, mean_logmsd, 'k.-');
% % % % elseif strcmpi(optstring, 'me') || strcmpi(optstring, 'e')
% % % %     errorbar(mean_logtau, mean_logmsd, ste_logmsd, 'k.-');
% % % % elseif strcmpi(optstring, 'ame')
% % % %     plot(logtau, logmsd, 'b-');
% % % %     hold on;
% % % %         errorbar(mean_logtau, mean_logmsd, ste_logmsd, 'k.-');
% % % %     hold off;
% % % % end
% % % % 
% % % % xlabel('log_{10}(\tau) [s]');
% % % % ylabel('log_{10}(MSD) [m^2]');
% % % % grid on;
% % % % pretty_plot;
% % % % refresh(h);    
