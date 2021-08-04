function d = convert_TrackingTable_to_old_matrix(TrackingTable, fps)

    iscolumn = @(TableName, ColumnName)(sum(ismember(ColumnName, TableName.Properties.VariableNames)));

    video_tracking_constants;
    
    d(:,TIME) = (TrackingTable.Frame - 1) / fps;
    d(:,ID) = TrackingTable.ID;
    d(:,FRAME) = TrackingTable.Frame;
    d(:,X) = TrackingTable.X;
    d(:,Y) = TrackingTable.Y;
    d(:,Z) = TrackingTable.Z;
    
    if iscolumn(TrackingTable, 'Roll')        
        d(:,ROLL) = TrackingTable.Roll;
    else
        d(:,ROLL) = 0;
    end
    
    if iscolumn(TrackingTable, 'Pitch')        
        d(:,PITCH) = TrackingTable.Pitch;
    else
        d(:,PITCH) = 0;
    end
    
    if iscolumn(TrackingTable, 'Yaw')        
        d(:,YAW) = TrackingTable.Yaw;
    else
        d(:,YAW) = 0;
    end
        
    if iscolumn(TrackingTable, 'Area')        
        d(:,AREA) = TrackingTable.Area;
    else
        d(:,AREA) = 0;
    end
    
    if iscolumn(TrackingTable, 'Sensitivity')        
        d(:,SENS) = TrackingTable.Sensitivity;
    else
        d(:,SENS) = 0;
    end
    
    if iscolumn(TrackingTable, 'CenterIntensity')        
        d(:,CENTINTS) = TrackingTable.CenterIntensity;
    else
        d(:,CENTINTS) = 0;
    end
    
    if iscolumn(TrackingTable, 'Well')        
        d(:,WELL) = TrackingTable.Well;
    else
        d(:,WELL) = 0;
    end
    
    if iscolumn(TrackingTable, 'Pass')        
        d(:,PASS) = TrackingTable.Pass;
    else
        d(:,PASS) = 0;
    end

    if iscolumn(TrackingTable, 'Fid')
        d(:,FID) = TrackingTable.Fid;
    else
        d(:,FID) = 0;
    end
    
return
