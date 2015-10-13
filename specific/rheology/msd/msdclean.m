function msdout = msdclean(msdin)
% This function should be used before msdstat as not to corrupt the stats
% for the msd computations. In fact, maybe it should be used directly
% inside video_msd but I haven't made that strict choice just yet.
%
% need to handle the case where the logmsd returns +/-Infinity. But where?
% This doesn't happen unless the regular msd is 0 across some number of
% timescales, an unlikely event given there's always noise. This case could
% happen if the input is simulated and *literally* has zero MSD over soem tau.


% where in the msd results do we have viable results? Anywhere where the
% outputted msd is exactly ZERO isn't real and needs to be trimmed from the
% dataset.
foo = (msdin.msd > 0);


% keep those columns that only have viable data (where the msd > 0)
cols_to_keep = (sum(foo,1)>0);

% filter and re-route data structure to output.
if isfield(msdin, 'pass')
    msdout.pass   = msdin.pass(:, cols_to_keep);
end

if isfield(msdin, 'well')
    msdout.well   =  msdin.well(:, cols_to_keep);
end

if isfield(msdin, 'trackerID')
    msdout.trackerID = msdin.trackerID(:, cols_to_keep);
end

if isfield(msdin, 'tau')
    msdout.tau = msdin.tau(:, cols_to_keep);
end

if isfield(msdin, 'msd')
    msdout.msd = msdin.msd(:,cols_to_keep);
end

if isfield(msdin, 'Nestimates')
    msdout.Nestimates = msdin.Nestimates(:, cols_to_keep);
end


return;
