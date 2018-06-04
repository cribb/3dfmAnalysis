function TrackingTableOut = vst_common_motion(TrackingTableIn)

% TrackingTable = DataIn.TrackingTable;

[ngid,nglist] = findgroups(TrackingTableIn.Fid);    

common_modes = splitapply(@(x1,x2,x3,x4){common_mode(x1,x2,x3,x4)}, ...
                                         TrackingTableIn.ID, ...
                                         TrackingTableIn.Frame, ...
                                         TrackingTableIn.X, ...
                                         TrackingTableIn.Y, ...
                                         ngid);
N = size(cell2mat(common_modes),1);
all_common_modes = NaN(0,4);
for k = 1:length(nglist)
    this_cm  = common_modes{k};
    this_fid = repmat(nglist(k), size(this_cm,1),1);
    this_framelist = transpose(1:size(this_cm,1));
    
    this_com_table = [this_fid, this_framelist, this_cm];
    all_common_modes = [all_common_modes; this_com_table];
end

tmp.Fid   = all_common_modes(:,1);
tmp.Frame = all_common_modes(:,2);
tmp.Xcom  = all_common_modes(:,3);
tmp.Ycom  = all_common_modes(:,4);

tmp = struct2table(tmp);

TrackingTableOut = join(TrackingTableIn, tmp, 'Keys', {'Fid', 'Frame'});

return;


function common_mode = common_mode(id, frames, x, y)

    video_tracking_constants;       

    vidtable = NaN(size(id,1), size(NULLTRACK,2));
    
    vidtable(:,ID)    = id;
    vidtable(:,FRAME) = frames;
    vidtable(:,X)     = x;
    vidtable(:,Y)     = y;

    common_mode = traj_common_motion(vidtable, 'n');
    
    return
