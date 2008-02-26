function v = msdhist(tau, msd)
% 3DFM function
% Rheology
% last modified 07/06/07
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

if nargin < 3 || isempty(optstring)
    optstring = 'c';
end

if nargin < 2 || isempty(h)
    h = figure;
end

% renaming input structure
tau = d.tau;
r2  = d.r2;
msd = d.msd;

if isfield(d, 'n');
    sample_count = d.n;
else
    sample_count = sum(~isnan(msd),2);
    idx = find(sample_count > 0);
    sample_count = sample_count(idx);
end

logr = log10(r2);
logr = logr(~isnan(logr));
logr = logr(~isinf(logr));

minr = min(logr(:));
maxr = max(logr(:));

num_bins = 51;
ranger = (maxr - minr) / num_bins;

mybins = [minr : ranger : (maxr - ranger)];

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);

mean_logtau = nanmean(logtau');
mean_logmsd = nanmean(logmsd');

ste_logtau = nanstd(logtau') ./ sqrt(sample_count');
ste_logmsd = nanstd(logmsd') ./ sqrt(sample_count');



% creating the plot
figure(h);

if strcmpi(optstring, 'a')
    
    % window, beadID, frame
    for k = 1:size(r2,1)
        data = log10(r2(k, :, :));
        data = data(:);
        data = data(~isnan(data));
        data = data(~isinf(data));


        [myhist(:,k), bins] = hist(data, num_bins);
    %     pause;
    end

    myhist = myhist ./ repmat(d.n', size(myhist,1),1);
    mytau = mean(tau,2);
    
%     plot(bins, myhist);
%     xlabel('sq. dist');
%     ylabel('count');
    
%     imagesc(log10(mytau), mybins, (myhist));
    surf(log10(mytau), mybins, (myhist));
    set(gca, 'YDir', 'normal');
    colormap(hot(256));

    xlabel('log_{10}(\tau [s])');
    ylabel('log_{10}(disp^2)');
    colorbar;

elseif strcmpi(optstring, 'c')
    
    for k = 1:size(r2,2)
        data = log10(r2(:, k, :));
        data = data(:);
        data = data(~isnan(data));
        data = data(~isinf(data));


        [myhist(:,k), bins] = hist(data, num_bins);
    %     pause;
    end

    plot(bins, myhist, '.-');

elseif strcmpi(optstring, 'ac')
%     plot(logtau, logmsd, 'b', mean_logtau, mean_logmsd, 'k.-');
end

% xlabel('log_{10}(\tau) [s]');
% ylabel('log_{10}(MSD) [m^2]');
grid on;
pretty_plot;
refresh(h);    

return;


% taubins = mean(tau, 2);

% v = hist(msd(1,:));

% return


