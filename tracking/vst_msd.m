function MsdTable = vst_msd(DataIn, taulist)

    TrackingTable = innerjoin(DataIn.TrackingTable, DataIn.VidTable(:,{'Fid', 'Calibum', 'Fps'}));
    [g,~] = findgroups(TrackingTable.Fid, TrackingTable.ID);


    % HERE, LENGTH SCALES ARE CONVERTED INTO [PIXELS] INTO [UM]
    XYXoYo_pix =  [TrackingTable.X, TrackingTable.Y, ...
                  TrackingTable.Xo, TrackingTable.Yo];
    XYXoYo_um =  XYXoYo_pix .* repmat(TrackingTable.Calibum,1,4);

%     tau_s = TrackingTable.Tau ./ TrackingTable.Fps;

    msdset = splitapply(@(x1,x2,x3){split_apply_msd(x1,x2,x3,taulist)}, ...
                                         TrackingTable.Fid, ...
                                         TrackingTable.ID, ...
                                         XYXoYo_um, ...
                                         g);    
    
    mymsd = cell2mat(msdset);
    
    MsdTable.Fid = mymsd(:,1);
    MsdTable.ID = mymsd(:,2);
    MsdTable.Tau = mymsd(:,3);
    MsdTable.MsdX = mymsd(:,4);
    MsdTable.MsdY = mymsd(:,5);    
    MsdTable.MsdXo = mymsd(:,6);
    MsdTable.MsdYo = mymsd(:,7);
    MsdTable.N = mymsd(:,8);
        
    MsdTable = struct2table(MsdTable);

    % HERE, TIME SCALES ARE CONVERTED FROM [FRAME#] INTO [SEC]
    tmpT = innerjoin(MsdTable, DataIn.VidTable(:,{'Fid', 'Fps'}));
    MsdTable.Tau_s = MsdTable.Tau ./ tmpT.Fps;




    MsdTable = movevars(MsdTable, 'Tau_s', 'after', 'Tau');

    MsdTable.Properties.Description = 'Mean Squared-Displacements in microns over Tau';
    MsdTable.Properties.VariableDescriptions = { 'FileID (key)', ...
                                                 'Trajectory ID',...
                                                 'Time scale, frames', ...
                                                 'Time scale, sec', ... 
                                                 'Mean-squared displacements over Tau, X (filtered)', ...
                                                 'Mean-squared displacements over Tau, Y (filtered)', ...
                                                 'Mean-squared displacements over Tau, X (original)', ...
                                                 'Mean-squared displacements over Tau, Y (original)', ...
                                                 'Number of estimates in MSD'};
                                                 
    MsdTable.Properties.VariableUnits = {'', '', 'frames', 's', 'um^2', 'um^2', 'um^2', 'um^2', ''};

return
   
   
function outs = split_apply_msd(fid, id, data, taulist)

    taulist = taulist(:);
    Ntaus = length(taulist);

    fid = repmat(fid(1), Ntaus, 1);
    id  = repmat(id(1), Ntaus, 1);
    
    [mymsd, Nest] = msd1d(data, taulist);    
    
    outs = [fid, id, taulist, mymsd, Nest];
    
return

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'video_msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    