function outs = vst_subtract_common_motion(TrackingTable)

    TrackingTable.Fid = double(TrackingTable.Fid); 
    TrackingTable.ID  = double(TrackingTable.ID);

    [g,gFid,gID] = findgroups(TrackingTable.Fid, TrackingTable.ID);
    
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

%     tmp.Fid = categorical(drift_free(:,1));
    tmp.Fid = drift_free(:,1);
    tmp.Frame = drift_free(:,2);
    tmp.ID = drift_free(:,3);
    tmp.X = drift_free(:,4);
    tmp.Y = drift_free(:,5);

    
    tmpT = struct2table(tmp);

%     TrackingTable.Fid = categorical(TrackingTable.Fid);
%     TrackingTable.ID  = categorical(TrackingTable.ID);
    TrackingTable.X   = [];
    TrackingTable.Y   = [];
    
    outs = join(tmpT, TrackingTable);

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