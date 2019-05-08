function outs = vst_subtract_common_motion(TrackingTable)

    idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
    [g,~] = findgroups(idGroupsTable);
    
    if ~isempty(TrackingTable)
        drift_free = splitapply(@(x1,x2,x3,x4,x5,x6,x7){subtract_common_mode(x1,x2,x3,x4,x5,x6,x7)}, ...
                                             TrackingTable.Fid, ...
                                             TrackingTable.Frame, ...
                                             TrackingTable.ID, ...
                                             TrackingTable.X, ...
                                             TrackingTable.Y, ...
                                             TrackingTable.Xcom, ...
                                             TrackingTable.Ycom, ...
                                             g);    
    else
        outs = [];
        return
    end

    drift_free = cell2mat(drift_free);
    drift_free = num2cell(drift_free, 1);
    
    tmpT = table(drift_free{:},'VariableNames', {'Fid', 'Frame', 'ID', 'X', 'Y'});

    TrackingTable.X   = [];
    TrackingTable.Y   = [];
    
    outs = join(tmpT, TrackingTable);

    outs.Properties.VariableDescriptions{'X'} = 'x-location';
    outs.Properties.VariableUnits{'X'} = 'pixels';
    outs.Properties.VariableDescriptions{'Y'} = 'y-location';
    outs.Properties.VariableUnits{'Y'} = 'pixels';
    
return;


function outs = subtract_common_mode(fid, frame, id, x, y, xcom, ycom)

        xy = [x(:) y(:)];
        common_xy = [xcom(:) ycom(:)];

        xy_offset = xy(1,:);
        c_offset = common_xy(1,:);
        
        xy = xy - xy_offset;        
        common_xy = common_xy - c_offset;
        
        new_xy = xy - common_xy;
        
        new_xy = new_xy + xy_offset;
        
        outs = [fid, frame, id, new_xy];
return