function [TrackingSummary, FileSummary] = vst_summarize(TrackingTable)

    idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
    [gid, idGroups] = findgroups(idGroupsTable);
    glist = unique(gid);

    % Identifying the trajectory groups
    traj.gid = glist(:);

    % consider table2array
    traj.Fid = idGroups.Fid;
    traj.ID  = idGroups.ID;
    
    % calculating trajectory lengths
    traj.Length = histc(gid, glist);

    % maximum intensity in the path
    traj.MinIntensity = splitapply(@min, TrackingTable.CenterIntensity, gid);
    traj.MeanIntensity = splitapply(@mean, TrackingTable.CenterIntensity, gid);
    traj.MedianIntensity = splitapply(@median, TrackingTable.CenterIntensity, gid);
    traj.MaxIntensity = splitapply(@max, TrackingTable.CenterIntensity, gid);

    % calculating average/median sensitivity
    traj.MinSens = splitapply(@min, TrackingTable.Sensitivity, gid);
    traj.MeanSens = splitapply(@mean, TrackingTable.Sensitivity, gid);
    traj.MedianSens = splitapply(@median, TrackingTable.Sensitivity, gid);
    traj.MaxSens = splitapply(@max, TrackingTable.Sensitivity, gid);
    
    % end-to-end distances and angles
    [traj.EndDist, traj.EndAngl] = splitapply(@eedistangle, [TrackingTable.Xo TrackingTable.Yo], gid);

    TrackingSummary = struct2table(traj);

    [fgid, fglist] = findgroups(TrackingSummary.Fid);

    file.gid = fglist(:);
    
    % Number of trajectories in each file (fid)
    file.Ntraj = splitapply(@(x)length(unique(x)), TrackingSummary.ID, fgid);
    
    % calculating average trajectory lengths
    file.meantrajLength = splitapply(@mean, TrackingSummary.Length, fgid);
    file.mintrajLength = splitapply(@min, TrackingSummary.Length, fgid);
    file.maxtrajLength = splitapply(@max, TrackingSummary.Length, fgid);
    file.mean_eedist = splitapply(@nanmean, TrackingSummary.EndDist, fgid);
    file.stderr_eedist = splitapply(@stderr, TrackingSummary.EndDist, fgid);
    file.mean_eeangl = splitapply(@mean, TrackingSummary.EndAngl, fgid);
    file.stderr_eeangl = splitapply(@stderr, TrackingSummary.EndAngl, fgid);
    
    [ngid,nglist] = findgroups(TrackingTable.Fid);
    
    file.common_modes = splitapply(@pan_common_mode, TrackingTable.ID, TrackingTable.Frame, TrackingTable.X, TrackingTable.Y, ngid);

    FileSummary = struct2table(file);

    return
    
function common_mode = pan_common_mode(id, frames, x, y)

    video_tracking_constants;       

    vidtable = NaN(size(id,1), size(NULLTRACK,2));
    
    vidtable(:,ID)    = id;
    vidtable(:,FRAME) = frames;
    vidtable(:,X)     = x;
    vidtable(:,Y)     = y;

    common_mode(1,:) = traj_common_motion(vidtable, 'n');
    
    return
