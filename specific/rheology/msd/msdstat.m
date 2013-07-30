function msdout = msdstat(msdin)

if nargin < 1 || isempty(msdin)
    msdout.logtau = NaN;
    msdout.logmsd = NaN;
    msdout.mean_logtau = NaN;
    msdout.mean_logmsd = NaN;
    msdout.msderr = NaN;
    
    return;
end

if isempty(msdin.tau)
    logentry('Error:  No data to perform statistics on.  Exiting now.');
    
    msdout = msdin;
    msdout.logtau = NaN(size(msdin.window));
    msdout.logmsd = NaN(size(msdin.window));
    msdout.mean_logtau = NaN(size(msdin.window));
    msdout.mean_logmsd = NaN(size(msdin.window));
    msdout.msderr = NaN(size(msdin.window));
    
    return;
end

% renaming input structure
tau    = msdin.tau;
msd    = msdin.msd;
counts = msdin.ns;

if isfield(msdin, 'n');
    sample_count = msdin.n;
else
    sample_count = sum(~isnan(msd),2);
    idx = find(sample_count > 0);
    sample_count = sample_count(idx);
    msdin.n = sample_count;
end

clip = find(sum(~isnan(counts),2) <= 1);
tau(clip,:) = [];
msd(clip,:) = [];
counts(clip,:) = [];
sample_count(clip,:) = [];

if isempty(tau) && isempty(msd) && isempty(counts) && isempty(sample_count)
    msdout = msdin;
    msdout.logtau = NaN(size(msdin.window));
    msdout.logmsd = NaN(size(msdin.window));
    msdout.mean_logtau = NaN(size(msdin.window));
    msdout.mean_logmsd = NaN(size(msdin.window));
    msdout.msderr = NaN(size(msdin.window));
    return;
end


% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);

numbeads = size(logmsd,2);

% weighted mean for logmsd
baseline = repmat(nansum(counts,2), 1, size(counts,2));
weights = counts ./ baseline;

mean_logtau = nanmean(logtau,2);
mean_logmsd = nansum(weights .* logmsd, 2);

% if the mean_logmsd is exactly equal to zero, then assume that every entry
% in that row for logmsd (computed just above) was zero and the 'nansum' was then zero
mean_logmsd( mean_logmsd == 0) = NaN;

% computing error for logmsd
Vishmat = nansum(weights .* (repmat(mean_logmsd, 1, numbeads) - logmsd).^2, 2);
msderr =  sqrt(Vishmat ./ sample_count);

% generating output structure
msdout = msdin;

% hacked the outputs to ensure a NaN vector when no data exist.  Probably
% should be figured out more fundamentally than this, that is, as an
% automatic output generated during the original computations and
% variable/parameter value checks.
msdout.logtau = logtau;
msdout.logmsd = logmsd;

if isempty(mean_logtau)
    msdout.mean_logtau = NaN(size(msdin.tau,1),1);
else
    msdout.mean_logtau = mean_logtau;
end

if isempty(mean_logmsd)
    msdout.mean_logmsd = NaN(size(msdin.msd,1),1);
else
    msdout.mean_logmsd = mean_logmsd;
end

if isempty(msderr)
    msdout.msderr = NaN(size(msderr,1),1);
else    
    msdout.msderr = msderr;
end

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
     headertext = [logtimetext 'msdstat: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;
