function [TrackingTableOut,ComTableOut] = vst_common_motion(TrackingTableIn)

% TrackingTable = DataIn.TrackingTable;

[ngid,nglist] = findgroups(TrackingTableIn.Fid, TrackingTableIn.ID);    

global cnt
cnt = 0;

% if ~isempty(TrackingTableIn)
    dxy = splitapply(@(x1,x2,x3,x4){compute_dxy(x1,x2,x3,x4)}, ...
                                             TrackingTableIn.ID, ...
                                             TrackingTableIn.Frame, ...
                                             TrackingTableIn.X, ...
                                             TrackingTableIn.Y, ...
                                             ngid);
    dxy = cell2mat(dxy);
    N = size(dxy, 1);


    TrackingTableIn.dX = dxy(:,1);
    TrackingTableIn.dY = dxy(:,2);
    
    [ngf,ngf_fid, ngf_frame] = findgroups(TrackingTableIn.Fid, TrackingTableIn.Frame);
    
    cm = splitapply(@(x1,x2,x3,x4){compute_cm(x1,x2,x3,x4)}, ...
                                             TrackingTableIn.ID, ...
                                             TrackingTableIn.Frame, ...
                                             TrackingTableIn.dX, ...
                                             TrackingTableIn.dY, ...
                                             ngf);
    cm = cell2mat(cm);

                                        
ComTableOut.Fid   = ngf_fid;
ComTableOut.Frame = ngf_frame;
ComTableOut.Xcom  = cm(:,1);
ComTableOut.Ycom  = cm(:,2);

ComTableOut = struct2table(ComTableOut);

TrackingTableOut = innerjoin(TrackingTableIn, ComTableOut, 'Keys', {'Fid', 'Frame'});

return;


function dxy = compute_dxy(id, frames, x, y)

    dx = CreateGaussScaleSpace(x, 1, 0.5);
    dy = CreateGaussScaleSpace(y, 1, 0.5);
    
    dxy = [dx(:), dy(:)];
    
return


function cm = compute_cm(id, frames, dx, dy)

    cm = [mean(dx), mean(dy)];
%     cm = repmat(cm, length(id(:)), 1);
    
return