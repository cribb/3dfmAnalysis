function outs = vst_common_motion(TrackingTable)

% TrackingTable = DataIn.TrackingTable;

[ngid,nglist] = findgroups(TrackingTable.Fid);    

common_modes = splitapply(@(x1,x2,x3,x4){vst_common_mode(x1,x2,x3,x4)}, TrackingTable.ID, TrackingTable.Frame, TrackingTable.X, TrackingTable.Y, ngid);

outs.Fid = nglist;
outs.drift = common_modes;

outs = struct2table(outs);


function common_mode = vst_common_mode(id, frames, x, y)

    video_tracking_constants;       

    vidtable = NaN(size(id,1), size(NULLTRACK,2));
    
    vidtable(:,ID)    = id;
    vidtable(:,FRAME) = frames;
    vidtable(:,X)     = x;
    vidtable(:,Y)     = y;

    common_mode = traj_common_motion(vidtable, 'n');
    
    return
