function [TrackingTableOut,ComTable] = vst_common_motion(TrackingTableIn)

    idGroupsTable = TrackingTableIn(:,{'Fid', 'ID'});
    [gid,~] = findgroups(idGroupsTable);    

% if isempty(TrackingTableIn)
%    return
% end
    dxy = splitapply(@(x1,x2,x3,x4){compute_dxy(x1,x2,x3,x4)}, ...
                                             TrackingTableIn.ID, ...
                                             TrackingTableIn.Frame, ...
                                             TrackingTableIn.Xo, ...
                                             TrackingTableIn.Yo, ...
                                             gid);
    dxy = cell2mat(dxy);
%     N = size(dxy, 1);


    TrackingTableIn.dXo = dxy(:,1);
    TrackingTableIn.dYo = dxy(:,2);
    
    
    idFramesTable = TrackingTableIn(:,{'Fid', 'Frame'});
    [ngf,ComTable] = findgroups(idFramesTable);
    
    cm = splitapply(@(x1,x2,x3,x4){compute_cm(x1,x2,x3,x4)}, ...
                                             TrackingTableIn.ID, ...
                                             TrackingTableIn.Frame, ...
                                             TrackingTableIn.dXo, ...
                                             TrackingTableIn.dYo, ...
                                             ngf);
    cm = cell2mat(cm);

    cm = cumsum(cm);
                            
    ComTable.Xcom  = cm(:,1);
    ComTable.Properties.VariableDescriptions{'Xcom'} = 'X-component in [pixels] of common trajectory motion (instantaneous center-of-mass).';
    ComTable.Properties.VariableUnits{'Xcom'} = '[pixels]';


    ComTable.Ycom  = cm(:,2);
    ComTable.Properties.VariableDescriptions{'Ycom'} = 'X-component in [pixels] of common trajectory motion (instantaneous center-of-mass).';
    ComTable.Properties.VariableUnits{'Ycom'} = '[pixels]';

    TrackingTableOut = innerjoin(TrackingTableIn, ComTable, 'Keys', {'Fid', 'Frame'});

return


function dxy = compute_dxy(id, frames, x, y)

    dx = CreateGaussScaleSpace(x, 1, 0.5);
    dy = CreateGaussScaleSpace(y, 1, 0.5);
    
    dxy = [dx(:), dy(:)];
    
return


function cm = compute_cm(id, frames, dx, dy)

    cm = [mean(dx), mean(dy)];
    
return