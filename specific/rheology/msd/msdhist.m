function v = msdhist(d, num_bins)
% 3DFM function
% Rheology
% last modified 02/24/08
%
% This function plots the graph of mean square displacement versus tau for an aggregate number
% of beads.
%
% plot_msdhist(d)
%
% where "d" is the input structure and should contain the mean square displacement, the tau 
%       value (window size), and the number of beads in a given window.
%       "h" is the figure handle in which to put the plot.  If h is not
%       used, a new figure is generated.
%      "optstring" is a string containing 'a' to plot overlaid individual histograms, 'c'
%      to plot the cumulative msd histogram
%

if nargin < 2 || isempty(num_bins)
    num_bins = 51;
end

% renaming input structure
tau = d.tau;
r2  = d.r2;
msd = d.msd;

if isfield(d, 'n');
    n = d.n;
else
    n = sum(~isnan(msd),2);
    idx = find(sample_count > 0);
    n = n(idx);
end

logr = log10(r2);
logr = logr(~isnan(logr));
logr = logr(~isinf(logr));

minr = min(logr(:));
maxr = max(logr(:));

ranger = (maxr - minr) / num_bins;

mybins = [minr : ranger : (maxr - ranger)];

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);

mean_logtau = nanmean(logtau');
mean_logmsd = nanmean(logmsd');

% ste_logtau = nanstd(logtau') ./ sqrt(sample_count');
% ste_logmsd = nanstd(logmsd') ./ sqrt(sample_count');

    
% window, beadID, frame
for w = 1:size(r2,1)
    data = log10(r2(w, :, :));
    data = data(:);
    data = data(~isnan(data));
    data = data(~isinf(data));


    [myhist(:,w), bins] = hist(data, num_bins);
end

idx = find(sum(abs(myhist),1) == 0);
myhist(:,idx) = [];

myhist = myhist ./ repmat(n', size(myhist,1),1);
mytau = mean(tau,2);

d.hist = myhist;
d.htau = mytau;
d.bins = mybins;

v = d;

return;

