function msdout = msd_at_tau(msdin, timescale)
% using linear interp in logspace between available taus to generate an MSD value at a
% specific tau not necessarily computed exactly. This operation should be
% ok since the MSD curves for material tends to be smooth and well behaved.
% A better way to handle this might be bicubic splines, but I leave that
% for another day.

% expect an msd structure as the input
taus = msdin.tau(:,1);
msds = msdin.msd;
Nestimates = msdin.Nestimates;
Ncols = size(msds,2);

% interp and re-route data structure to output.
if isfield(msdin, 'pass')
    msdout.pass   = msdin.pass;
end

if isfield(msdin, 'well')
    msdout.well   =  msdin.well;
end

if isfield(msdin, 'trackerID')
    msdout.trackerID = msdin.trackerID;
end

if isfield(msdin, 'tau')
    msdout.tau = repmat(timescale, 1, Ncols);
end

if isfield(msdin, 'msd')
    msdout.msd = interp1(taus, msds, timescale, 'linear');
end

if isfield(msdin, 'Nestimates')
    msdout.Nestimates = floor(interp1(taus, Nestimates, timescale, 'linear'));
end

return;