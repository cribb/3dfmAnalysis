function outs = vst_summarize_run(DataIn)

    T = join(DataIn.TrackingTable(:,{'Fid', 'Frame', 'ID'}), ...
             DataIn.VidTable(:,{'Fid', 'SampleName', 'SampleInstance', 'FovID'}));
    
    [gL1, gSampleName] = findgroups(T.SampleName);
             
    sd = setdiff(unique(DataIn.VidTable.SampleName), gSampleName);
    emptyset = zeros(length(sd), 1);

%     foo = splitapply(@(x1,x2,x3,x4,x5)summarize_samplename(x1,x2,x3,x4,x5), ...
%       T.SampleName, T.SampleInstance, T.FovID, T.Frame, T.ID, gL1);
         
    % I want the number of Instances for each SampleName (like how many replicate 
    % *wells* or number of different samplevolumes for each SampleName)
    NInstances = splitapply(@(x1)length(unique(x1)), T.SampleInstance, gL1);
    sn.NInstances = NInstances;

    [gL2, gSampleName, gSampleInstance] = findgroups(T.SampleName, T.SampleInstance);
    
    % The number of Fields of View for all Instances of one SampleName
    NFov = splitapply(@(x1,x2)length(unique(join(x1,x2))), string(T.SampleInstance), string(T.FovID), gL1);

    % First, pass along the SampleNames to the output
    sn.SampleName = [gSampleName ; sd];
    
%     sn.NInstances = [foo(:,1); emptyset];
%     sn.NFov = [foo(:,2); emptyset];
%     sn.NFrames = [foo(:,3); emptyset];
%     sn.NTrackers = [foo(:,4); emptyset];
    
    sn = sortrows(struct2table(sn));
        
    [gL2, gSampleName, gSampleInstance] = findgroups(T.SampleName, T.SampleInstance);
    
    
    foo = splitapply(@(x1,x2,x3,x4,x5)summarize_samplename(x1,x2,x3,x4,x5), ...
          T.SampleName, T.SampleInstance, T.FovID, T.Frame, T.ID, gL2);
      
    sd = setdiff(unique(DataIn.VidTable.SampleName), gSampleName);
    emptyset = zeros(length(sd), 1);
    
    si.SampleName = gSampleName;
    si.SampleInstance = gSampleInstance;
    si.NFov = foo(:,2);
    si.NFrames = foo(:,3);
    si.NTrackers = foo(:,4);
    
    si = struct2table(si);
    
    [gL3, gSampleName, gSampleInstance, gFovID] = findgroups(T.SampleName, T.SampleInstance, T.FovID);

    sf.SampleName = gSampleName;
    sf.SampleInstance = gSampleInstance;
    sf.NFov = gFovID;
    sf.NFrames = foo(:,3);
    sf.NTrackers = foo(:,4);
    
    return

function outs = summarize_samplename(samplename, sampleinstance, fovid, frame, id)

    NInstances = length(unique(sampleinstance));
    NFov = length(unique(fovid));
    NFrames = length(unique(frame));
    NTrackers = length(unique(id));

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