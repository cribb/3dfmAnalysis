function [TrackingTableOut,ComTableOut] = vst_common_motion(TrackingTableIn)

% TrackingTable = DataIn.TrackingTable;

[ngid,nglist] = findgroups(TrackingTableIn.Fid);    

global cnt
cnt = 0;

% if ~isempty(TrackingTableIn)
    common_modes = splitapply(@(x1,x2,x3,x4){common_mode(x1,x2,x3,x4)}, ...
                                             TrackingTableIn.ID, ...
                                             TrackingTableIn.Frame, ...
                                             TrackingTableIn.X, ...
                                             TrackingTableIn.Y, ...
                                             ngid);
    N = size(cell2mat(common_modes),1);
% else
%     common_modes = common_mode(TrackingTableIn.ID, TrackingTableIn.Frame, TrackingTableIn.X, TrackingTableIn.Y);
% end

% [all_fid, all_framelist] = deal(NaN(0,1));
% all_cm = NaN(0,2);
% all_fid = categorical(all_fid);

for k = 1:length(nglist)
    this_cm  = common_modes{k};
    this_fid = repmat(nglist(k), size(this_cm,1),1);
    this_framelist = transpose(1:size(this_cm,1));
    
    all_fid =       [all_fid; this_fid];
    all_framelist = [all_framelist; this_framelist];
    all_cm =        [all_cm; this_cm];
end

ComTableOut.Fid   = all_fid;
ComTableOut.Frame = all_framelist;
ComTableOut.Xcom  = all_cm(:,1);
ComTableOut.Ycom  = all_cm(:,2);

ComTableOut = struct2table(ComTableOut);

TrackingTableOut = innerjoin(TrackingTableIn, ComTableOut, 'Keys', {'Fid', 'Frame'});

return;


function common_mode = common_mode(id, frames, x, y)

    global cnt;
    cnt = cnt + 1;

    video_tracking_constants;       
    
    vidtable = NaN(size(id,1), size(NULLTRACK,2));
    
    vidtable(:,ID)    = id;
    vidtable(:,FRAME) = frames;
    vidtable(:,X)     = x;
    vidtable(:,Y)     = y;

    common_mode = traj_common_motion(vidtable, 'n');
    
    return
