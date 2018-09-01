function MsdTable = grouped_msd(DataIn, taulist, group_names)

    if nargin < 3 || isempty(group_names)
        group_names = {'SampleName', 'SampleInstance', 'FovID'};
    end

    v = DataIn.VidTable(:,{'Fid', 'SampleName', 'SampleInstance', 'FovID', 'Fps', 'Calibum'});
    m = DataIn.TrackingTable;

    b = join(m, v);

    [g, foo] = findgroups(b(:,group_names));

    [g,gFid,gID] = findgroups(TrackingTable.Fid, TrackingTable.ID);
    
%     taulist = repmat(taulist, length(g), 1);
    msdset = splitapply(@(x1,x2,x3){split_apply_msd(x1,x2,x3,taulist)}, ...
                                         TrackingTable.Fid, ...
                                         TrackingTable.ID, ...
                                         [TrackingTable.X, TrackingTable.Y TrackingTable.Xo TrackingTable.Yo], ...
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
     
     
     
     
     
     
% % %      
% % %      
% % %      
% % %      
% % % 
% % % 

% % % 
% % %     ssd_kappa = splitapply(@nongausskappa, [b.Xdiff, b.Ydiff, b.Xodiff, b.Yodiff], g);
% % %                  
% % %         outs = foo;
% % %         outs.Xkappa = ssd_kappa(:,1);
% % %         outs.Ykappa = ssd_kappa(:,2);
% % %         outs.Xokappa = ssd_kappa(:,3);
% % %         outs.Yokappa = ssd_kappa(:,4);
% % %         outs.N = ssd_kappa(:,5);
% % % return
% % % 
% % % function outs = nongausskappa(data)
% % %     data = cell2mat(data);
% % %     N = sum(isfinite(data(:,1)));
% % %     outs = [kurtosis(data, [], 1)/3 - 1, N];
% % % return
% % % 
