function TrackingSummary = vst_summarize_traj(TrackingTable)

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

    return
    
