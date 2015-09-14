function msdout = msdstat(msdin)

if nargin < 1 || isempty(msdin) || ~isfield(msdin, 'tau') || isempty(msdin.tau)
    
    if exist('msdin')
        msdout = msdin;
    end
    
    msdout.logtau = NaN;
    msdout.logmsd = NaN;
    msdout.mean_logtau = NaN;
    msdout.mean_logmsd = NaN;
    msdout.msderr = NaN;
    
    logentry('Error:  No data to perform statistics on.  Exiting now.');
    
    return;
end


% Renaming input structure. The 'ns' field refers to the number of
% estimates (differences) of MSD that exist within a given timescale. The 
% 'n' field refers to the number of trackers available within that particular
% timescale.
trackerID = msdin.trackerID;
tau       = msdin.tau;
mymsd     = msdin.msd;
counts    = msdin.ns;

% compatibility issues with old msd.m
if isfield(msdin, 'n');
    sample_count = msdin.n;
else
    sample_count = sum(~isnan(mymsd),2);
    idx = find(sample_count > 0);
    sample_count = sample_count(idx);
    msdin.n = sample_count;
end

clip = find(sum(~isnan(counts),2) <= 1);
tau(clip,:) = [];
mymsd(clip,:) = [];
counts(clip,:) = [];
sample_count(clip,:) = [];

% did we delete out everything? if so, return empty set
if isempty(tau) && isempty(mymsd) && isempty(counts) && isempty(sample_count)
    msdout = msdin;
    msdout.logtau = NaN(length(msdin.window),1);
    msdout.logmsd = NaN(length(msdin.window),1);
    msdout.mean_logtau = NaN(length(msdin.window),1);
    msdout.mean_logmsd = NaN(length(msdin.window),1);
    msdout.msderr = NaN(length(msdin.window),1);
    msdout.rmsdisp = NaN(length(msdin.window),1);
    msdout.logrmsdisp = NaN(length(msdin.window),1);
    msdout.mean_logrmsdisp = NaN(length(msdin.window),1);
    msdout.rmsdisp_err = NaN(length(msdin.window),1);    
    return;
end




% compute rmsdisplacement 
rmsdisp = sqrt(mymsd);

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau     = log10(tau);
logmsd     = log10(mymsd);
logrmsdisp = log10(rmsdisp);
numbeads   = size(logmsd,2);

% weighted mean for logmsd
baseline = repmat(nansum(counts,2), 1, size(counts,2));
weights = counts ./ baseline;

mean_logtau = nanmean(logtau,2);
mean_logmsd = nansum(weights .* logmsd, 2);
mean_logrmsdisp = nansum(weights .* logrmsdisp, 2);

% if the mean_logmsd is exactly equal to zero, then assume that every entry
% in that row for logmsd (computed just above) was zero and the 'nansum' was then zero
mean_logmsd( mean_logmsd == 0) = NaN;
mean_logrmsdisp( mean_logrmsdisp == 0) = NaN;

% computing error for logmsd
Vishmat = nansum(weights .* (repmat(mean_logmsd, 1, numbeads) - logmsd).^2, 2);
msderr =  sqrt(Vishmat ./ sample_count);
Vishmat_rmsdisp = nansum(weights .* (repmat(mean_logrmsdisp, 1, numbeads) - logrmsdisp).^2, 2);
rmsdisp_err = sqrt(Vishmat_rmsdisp ./ sample_count);

%d.logrmsdisp = d.logmsd;
%d.logrmsdisp = sqrt(10.^mymsd);
%rmsdisp_err = sqrt(10.^(mymsd+mymsd_err)) - rmsdisp;\

% generating output structure
msdout = msdin;

% hacked the outputs to ensure a NaN vector when no data exist.  Probably
% should be figured out more fundamentally than this, that is, as an
% automatic output generated during the original computations and
% variable/parameter value checks.
msdout.logtau = logtau;
msdout.logmsd = logmsd;

if isempty(trackerID)
    msdout.trackerID = NaN(size(msdin.trackerID,1),1);
else
    msdout.trackerID = trackerID;
end    

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

if isempty(rmsdisp)
    msdout.rmsdisp = NaN(size(rmsdisp,1),1);
else    
    msdout.rmsdisp = rmsdisp;
end

if isempty(logrmsdisp)
    msdout.logrmsdisp = NaN(size(logrmsdisp,1),1);
else    
    msdout.logrmsdisp = logrmsdisp;
end  

if isempty(mean_logrmsdisp)
    msdout.mean_logrmsdisp = NaN(size(mean_logrmsdisp,1),1);
else    
    msdout.mean_logrmsdisp = mean_logrmsdisp;
end
    
if isempty(rmsdisp_err)
    msdout.rmsdisp_err = NaN(size(rmsdisp_err,1),1);
else    
    msdout.rmsdisp_err = rmsdisp_err;
end

return;



