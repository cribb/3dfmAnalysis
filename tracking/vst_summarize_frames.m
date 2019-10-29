function DataOut = vst_summarize_frames(TrackingTable)

    % Identifying the Frame groups
    [g, FrameSummary] = findgroups(TrackingTable(:,{'Fid', 'Frame'}));
    FrameSummary.NTrackers = splitapply(@length, TrackingTable.ID, g);

    % Identifying the trajectory groups. The Tmp variable/column created
    % here is just a hack to get the FileSummary output to be a table.
    % Since Matlab demotes a single column to its constituent datatype, it
    % doesn't work the way I want it to.
    FrameSummary.Tmp = zeros(height(FrameSummary),1);    
    [g, FileSummary] = findgroups(FrameSummary(:,{'Fid', 'Tmp'}));
    FileSummary.Tmp  = [];
    
    FileSummary.AvgTrackerCount = splitapply(@mean, FrameSummary.NTrackers, g);
    FileSummary.Properties.VariableDescriptions{'AvgTrackerCount'} = 'Average number of trackers in each frame for File ID.';
    FileSummary.Properties.VariableUnits{'AvgTrackerCount'} = '[#trackers]';

DataOut = FileSummary;