function outs = vst_summarize_run(DataIn)

    T = join(DataIn.TrackingTable(:,{'Fid', 'Frame', 'ID'}), ...
             DataIn.VidTable(:,{'Fid', 'SampleName', 'SampleInstance', 'FovID'}));
    
    [gL1, g1SampleName] = findgroups(T.SampleName);
             
    empty_SampleNames = setdiff(unique(DataIn.VidTable.SampleName), g1SampleName);
    zeroset = zeros(length(empty_SampleNames), 1);

%     foo = splitapply(@(x1,x2,x3,x4,x5)summarize_samplename(x1,x2,x3,x4,x5), ...
%           T.SampleName, T.SampleInstance, T.FovID, T.Frame, T.ID, gL1);

    % I want the number of Instances for each SampleName (like how many replicate 
    % *wells* or number of different samplevolumes for each SampleName)
    NInstances = splitapply(@(x1)length(unique(x1, 'rows')), T.SampleInstance, gL1);

    % The number of Fields of View for all Instances of one SampleName
    NFov = splitapply(@(x1)length(unique(x1, 'rows')), [T.SampleInstance, T.FovID], gL1);

    % NFrames
    NFrames = splitapply(@(x1)length(unique(x1, 'rows')), [T.SampleInstance, T.FovID, categorical(T.Frame)], gL1);
    
    % NTrackers
    NTrackers = splitapply(@(x1)length(unique(x1, 'rows')), [T.SampleInstance, T.FovID, categorical(T.ID)], gL1);
    
    % First, pass along the SampleNames to the output
    s1.SampleName = [g1SampleName ; empty_SampleNames];    
    s1.NInstances = [NInstances; zeroset];
    s1.NFov = [NFov; zeroset];
    s1.NFrames = [NFrames; zeroset];
    s1.NTrackers = [NTrackers; zeroset];
    
    s1 = sortrows(struct2table(s1));
    
    
    % % %
    % Now, we're going to dig to level 2, the SampleInstance level....
    [gL2, g2SampleName, g2SampleInstance] = findgroups(T.SampleName, T.SampleInstance);
        
%     foo = splitapply(@(x1,x2,x3,x4,x5)summarize_samplename(x1,x2,x3,x4,x5), ...
%           T.SampleName, T.SampleInstance, T.FovID, T.Frame, T.ID, gL2);
      
    empty_SampleNames = setdiff(unique(DataIn.VidTable.SampleName), g2SampleName);    
    zeroset = zeros(length(empty_SampleNames), 1);
    
    s2.SampleName = g2SampleName;
    s2.SampleInstance = g2SampleInstance;
    s2.NFov = foo(:,2);
    s2.NFrames = foo(:,3);
    s2.NTrackers = foo(:,4);
    
    s2 = struct2table(s2);
    
    [gL3, g3SampleName, g3SampleInstance, g3FovID] = findgroups(T.SampleName, T.SampleInstance, T.FovID);

    s3.SampleName = g3SampleName;
    s3.SampleInstance = g3SampleInstance;
    s3.NFov = gFovID;
    s3.NFrames = foo(:,3);
    s3.NTrackers = foo(:,4);
    
    return

function outs = summarize_samplename(samplename, sampleinstance, fovid, frame, id)

    NInstances = length(unique(sampleinstance, 'rows'));
    NFov = length(unique(fovid, 'rows'));
    NFrames = length(unique(frame, 'rows'));
    NTrackers = length(unique(id, 'rows'));

    outs = [NInstances, NFov, NFrames, NTrackers];

return
% function TrackingSummary = vst_summarize_traj(TrackingTable)
% 
%     idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
%     [gid, idGroups] = findgroups(idGroupsTable);
%     glist = unique(gid);
% 
%     % Identifying the trajectory groups
%     traj.gid = glist(:);
% 
%     % consider table2array
%     traj.Fid = idGroups.Fid;
%     traj.ID  = idGroups.ID;
%     
%     % calculating trajectory lengths
%     traj.Length = histc(gid, glist);
% 
%     % maximum intensity in the path
%     traj.MinIntensity = splitapply(@min, TrackingTable.CenterIntensity, gid);
%     traj.MeanIntensity = splitapply(@mean, TrackingTable.CenterIntensity, gid);
%     traj.MedianIntensity = splitapply(@median, TrackingTable.CenterIntensity, gid);
%     traj.MaxIntensity = splitapply(@max, TrackingTable.CenterIntensity, gid);
% 
%     % calculating average/median sensitivity
%     traj.MinSens = splitapply(@min, TrackingTable.Sensitivity, gid);
%     traj.MeanSens = splitapply(@mean, TrackingTable.Sensitivity, gid);
%     traj.MedianSens = splitapply(@median, TrackingTable.Sensitivity, gid);
%     traj.MaxSens = splitapply(@max, TrackingTable.Sensitivity, gid);
%     
%     % end-to-end distances and angles
%     [traj.EndDist, traj.EndAngl] = splitapply(@eedistangle, [TrackingTable.X TrackingTable.Y], gid);
% 
%     TrackingSummary = struct2table(traj);
% 
%     return
%     
% 
% 
%     Fid = TrackingSummary.Fid;
%     flist = unique(Fid);
% 
%     g = findgroups(Fid);
%     glist = unique(g);
%     
%     file.Fid = flist;
%     
%     % Number of trajectories in each file (fid)
%     file.Ntraj = splitapply(@(x)length(unique(x)), TrackingSummary.ID, g);
%     
%     % calculating average trajectory lengths
%     file.meantrajLength = splitapply(@mean, TrackingSummary.Length, g);
%     file.mintrajLength = splitapply(@min, TrackingSummary.Length, g);
%     file.maxtrajLength = splitapply(@max, TrackingSummary.Length, g);
%     file.mean_eedist = splitapply(@nanmean, TrackingSummary.EndDist, g);
%     file.stderr_eedist = splitapply(@stderr, TrackingSummary.EndDist, g);
%     file.mean_eeangl = splitapply(@mean, TrackingSummary.EndAngl, g);
%     file.stderr_eeangl = splitapply(@stderr, TrackingSummary.EndAngl, g);
% 
%     FileSummary = struct2table(file);
% 
%     
% return