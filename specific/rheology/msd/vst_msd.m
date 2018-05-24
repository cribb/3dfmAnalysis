function vmsd = vst_msd(VidTable, taulist, make_plot)
% VIDEO_MSD computes mean square displacements of an aggregate number of video tracked beads via the Stokes-Einstein relation 
%
% CISMM function
% specific\rheology\msd
%
% This function computes the mean square displacements of an aggregate number of video 
% tracked beads via the Stokes-Einstein relation and allows for the option of plotting
% MSD vs. taus size (tau).
%
% [vmsd] = video_msd(VidTable, taus, make_plot, xtra_output)
%
% where "VidTable"
%       "taus" is a scalar denoting the number of taus sizes desired from 
%                the minimum and maximum available (with repeats filtered out), 
%                or is a vector containing the exact taus sizes of tau when 
%                computing the MSD. 
%       "make_plot" gives the option of producing a plot of MSD versus tau.
%       "xtra_output" is 'r2' to output r-squared values, or 'r' to output
%                     sign-preserved displacements.
%

% initializing arguments
if (nargin < 1) || isempty(VidTable) || ~istable(VidTable)
    logentry('No Vidtable or VidTable is not a matlab table datatype. Exiting now.')
    
    if length(taulist) > 1
        empty_set = NaN(size(taulist));
    elseif length(taulist) == 1
        empty_set = NaN(taulist,1);
    end
    
    vmsd.trackerID = empty_set;
    vmsd.tau = empty_set;
    vmsd.msd = empty_set;
%     vmsd.n = empty_set;
    vmsd.Nestimates = empty_set;
    vmsd.taus = empty_set;
    return;
end;

if (nargin < 2) || isempty(taulist)  
    taulist = 50;  
end;

fids = unique(VidTable.Fid);

for f = 1:length(fids)

    v = vst_load_tracking(VidTable(VidTable.Fid==fids(f),:));

    % We want to identify a set of strides to step across for a given set of 
    % images (frames).  We would like them to be spread evenly across the 
    % available frames (times) in the log scale sense.  To do this we generate
    % a logspace range, eliminate any repeated values and round them 
    % appropriately, getting a list of strides that may not be as long as we
    % asked but pretty close. 
    if length(taulist) == 1
       percent_duration = 1;
       taulist = msd_gen_taus(max(v.Frame), taulist, percent_duration);
    end

    % for every bead
    beadIDs = unique(v.ID)';

    tau    = NaN(length(taulist), length(beadIDs));
    mymsd  = NaN(length(taulist), length(beadIDs));
    Nestimates = NaN(length(taulist), length(beadIDs));

    for k = 1 : length(beadIDs);

        b = v( v.ID == beadIDs(k) , : );    

        mytime = b.Frame ./ VidTable.Fps(f);

        % call up the MSD kernel-function to compute the MSD for each bead    
        [tau_, msd_, nest_]    = msd(mytime, [b.X,b.Y], taulist(~isnan(taulist)));

        tau(1:length(tau_),k) = tau_; 
        mymsd(1:length(msd_),k) = msd_;
        Nestimates(1:length(nest_),k) = nest_;

    end

end
% trim the data by removing taus sizes that returned no data
% sample_count = sum(~isnan(mymsd),2);

% idx = find(sample_count > 0);
% tau = tau(idx,:);
% mymsd = mymsd(idx,:);
% Nestimates = Nestimates(idx,:);
% sample_count = sample_count(idx);


% output structure
vmsd.trackerID = reshape(beadIDs, 1, length(beadIDs));
vmsd.tau = tau;
vmsd.msd = mymsd;
vmsd.Nestimates = Nestimates;
vmsd.taus = taulist;

% creation of the plot MSD vs. tau
if (nargin < 3) || isempty(make_plot) || strncmp(make_plot,'y',1)  
    plot_msd(vmsd, [], 'me'); 
end;

% fprintf('size(vmsd): %i,  %i\n',size(vmsd.msd));
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
     headertext = [logtimetext 'video_msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    