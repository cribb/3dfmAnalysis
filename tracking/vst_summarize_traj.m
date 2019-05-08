function TrackingSummary = vst_summarize_traj(TrackingTable)

    % Identifying the trajectory groups
    idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
    [gid, TrackingSummary] = findgroups(idGroupsTable);
    glist = unique(gid);
    
    % Calculate the Length (in frames) of each group (trajectory)
    TrackingSummary.Length = histc(gid, glist);
    TrackingSummary.Properties.VariableDescriptions{'Length'} = 'Length (in frames) of each trajectory.';

    % Pull out starting & ending locations in t, x, & y for each trajectory
    tmp = splitapply(@(x1,x2,x3){fxystartend(x1,x2,x3)}, TrackingTable.Frame, TrackingTable.X, TrackingTable.Y, gid);
    tmp = cell2mat(tmp);
    
    TrackingSummary.FrameStart = tmp(:,1);
    TrackingSummary.Properties.VariableDescriptions{'FrameStart'} = 'Starting frame number for each trajectory.';

    TrackingSummary.FrameEnd = tmp(:,2);
    TrackingSummary.Properties.VariableDescriptions{'FrameEnd'} = 'Last frame number for each trajectory.';

    TrackingSummary.Xstart = tmp(:,3);
    TrackingSummary.Properties.VariableDescriptions{'Xstart'} = 'Starting unfiltered-x position for each trajectory.';
    TrackingSummary.Properties.VariableUnits{'Xstart'} = 'pixels';
    
    TrackingSummary.Xend   = tmp(:,4);
    TrackingSummary.Properties.VariableDescriptions{'Xend'} = 'Last unfiltered-x position for each trajectory.';
    TrackingSummary.Properties.VariableUnits{'Xend'} = 'pixels';

    TrackingSummary.Ystart = tmp(:,5);
    TrackingSummary.Properties.VariableDescriptions{'Ystart'} = 'Starting unfiltered-y position for each trajectory.';
    TrackingSummary.Properties.VariableUnits{'Ystart'} = 'pixels';

    TrackingSummary.Yend   = tmp(:,6);
    TrackingSummary.Properties.VariableDescriptions{'Yend'} = 'Last unfiltered-y position for each trajectory.';
    TrackingSummary.Properties.VariableUnits{'Yend'} = 'pixels';

    
    % Intensity stats for each trajectory
    TrackingSummary.MinIntensity = splitapply(@min, TrackingTable.CenterIntensity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MinIntensity'} = 'Minimum intensity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MinIntensity'} = '[]';
    
    TrackingSummary.MeanIntensity = splitapply(@mean, TrackingTable.CenterIntensity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MeanIntensity'} = 'Mean intensity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MeanIntensity'} = '[]';

    TrackingSummary.MedianIntensity = splitapply(@median, TrackingTable.CenterIntensity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MedianIntensity'} = 'Median intensity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MedianIntensity'} = '[]';

    TrackingSummary.MaxIntensity = splitapply(@max, TrackingTable.CenterIntensity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MaxIntensity'} = 'Max intensity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MaxIntensity'} = '[]';

    % Sensitivity stats for each trajectory 
    TrackingSummary.MinSens = splitapply(@min, TrackingTable.Sensitivity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MinSens'} = 'Minimum sensitivity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MinSens'} = '[]';

    TrackingSummary.MeanSens = splitapply(@mean, TrackingTable.Sensitivity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MeanSens'} = 'Mean sensitivity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MeanSens'} = '[]';

    TrackingSummary.MedianSens = splitapply(@median, TrackingTable.Sensitivity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MedianSens'} = 'Median sensitivity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MedianSens'} = '[]';

    TrackingSummary.MaxSens = splitapply(@max, TrackingTable.Sensitivity, gid);
    TrackingSummary.Properties.VariableDescriptions{'MaxSens'} = 'Max sensitivity value of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'MaxSens'} = '[]';

   
    % end-to-end distances and angles
    [TrackingSummary.EndDist, TrackingSummary.EndAngl] = splitapply(@eedistangle, [TrackingTable.X TrackingTable.Y], gid);
    TrackingSummary.Properties.VariableDescriptions{'EndDist'} = 'End-to-end distance of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'EndDist'} = 'pixels';
    TrackingSummary.Properties.VariableDescriptions{'EndAngl'} = 'End-to-end angle of each trajectory.';
    TrackingSummary.Properties.VariableUnits{'EndAngl'} = 'radians';
    
    return
    

    function FXYout = fxystartend(frame, x,y)
        
        FXYout = [frame(1) frame(end) x(1) x(end) y(1) y(end)];
        
        return