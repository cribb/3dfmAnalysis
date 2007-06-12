function plot_msd(d)
% 3DFM function
% Rheology
% last modified 07/06/07 (blcarste)
%
% This function plots the graph of mean square displacement versus tau for an aggregate number
% of beads.
%
% plot_msd(d)
%
% where "d" is the input structure and should contain the mean square displacement, the tau 
%       value (window size), and the number of beads in a given window.
%     


% renaming input structure
tau = d.tau;
msd = d.msd;

if isfield(d, 'n');
    sample_count = d.n;
else
    sample_count = sum(~isnan(msd),2);
    idx = find(sample_count > 0);
    sample_count = sample_count(idx);
end


% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);

mean_logtau = nanmean(logtau');
mean_logmsd = nanmean(logmsd');

ste_logtau = nanstd(logtau') ./ sqrt(sample_count');
ste_logmsd = nanstd(logmsd') ./ sqrt(sample_count');


% creating the plot
    figure;
	errorbar(mean_logtau, mean_logmsd, ste_logmsd, '.-');
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;
    
