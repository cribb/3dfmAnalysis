function MsdTable = vst_msd(DataIn, taulist)

    TrackingTable = DataIn.TrackingTable;
    
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

% % % % % % 
% % % % % % 
% % % % % % 
% % % % % % 
% % % % % %     % We want to identify a set of strides to step across for a given set of 
% % % % % %     % images (frames).  We would like them to be spread evenly across the 
% % % % % %     % available frames (times) in the log scale sense.  To do this we generate
% % % % % %     % a logspace range, eliminate any repeated values and round them 
% % % % % %     % appropriately, getting a list of strides that may not be as long as we
% % % % % %     % asked but pretty close. 
% % % % % %     if length(taulist) == 1
% % % % % %        percent_duration = 1;
% % % % % %        taulist = msd_gen_taus(max(v.Frame), taulist, percent_duration);
% % % % % %     end
% % % % % % 
% % % % % % 
% % % % % % % trim the data by removing taus sizes that returned no data
% % % % % % % sample_count = sum(~isnan(mymsd),2);
% % % % % % 
% % % % % % % idx = find(sample_count > 0);
% % % % % % % tau = tau(idx,:);
% % % % % % % mymsd = mymsd(idx,:);
% % % % % % % Nestimates = Nestimates(idx,:);
% % % % % % % sample_count = sample_count(idx);
% % % % % % 
% % % % % % 
% % % % % % % output structure
% % % % % % vmsd.trackerID = reshape(beadIDs, 1, length(beadIDs));
% % % % % % vmsd.tau = tau;
% % % % % % vmsd.msd = mymsd;
% % % % % % vmsd.Nestimates = Nestimates;
% % % % % % vmsd.taus = taulist;
% % % % % % 
% % % % % % % creation of the plot MSD vs. tau
% % % % % % if (nargin < 3) || isempty(make_plot) || strncmp(make_plot,'y',1)  
% % % % % %     plot_msd(vmsd, [], 'me'); 
% % % % % % end
% % % % % % 
% % % % % % % fprintf('size(vmsd): %i,  %i\n',size(vmsd.msd));
% % % % % % return;


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