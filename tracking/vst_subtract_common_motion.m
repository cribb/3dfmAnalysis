function outs = vst_subtract_common_motion(TrackingTable, FileSummary)

    [ngid,nglist] = findgroups(TrackingTable.Fid);    

    common_modes = splitapply(@(x1,x2,x3,x4,x5){subtract_common_mode(x1,x2,x3,x4,x5)}, ...
                                         TrackingTable.ID, ...
                                         TrackingTable.Frame, ...
                                         TrackingTable.X, ...
                                         TrackingTable.Y, ...
                                         common_mode, ...
                                         ngid);

    outs.Fid = nglist;
    outs.COM = common_modes;

    outs = struct2table(outs);

return;


function df = subtract_common_mode(id, frames, x, y, common_mode)

    video_tracking_constants;       

    vidtable = NaN(size(id,1), size(NULLTRACK,2));
    
    vidtable(:,ID)    = id;
    vidtable(:,FRAME) = frames;
    vidtable(:,X)     = x;
    vidtable(:,Y)     = y;

    df = traj_subtract_common_motion(vidtable, common_mode);
    
    return