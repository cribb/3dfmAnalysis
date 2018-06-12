function DiffTauTable = vst_difftau(DataIn, taulist)

    TrackingTable = DataIn.TrackingTable;
    
    [g,gFid,gID] = findgroups(TrackingTable.Fid, TrackingTable.ID);
    
%     taulist = repmat(taulist, length(g), 1);
    difftauset =  splitapply(@(x1,x2,x3){split_apply_difftau(x1,x2,x3,taulist)}, ...
                                        TrackingTable.Fid, ...
                                        TrackingTable.ID, ...
                                         [TrackingTable.X, TrackingTable.Y TrackingTable.Xo TrackingTable.Yo], ...
                                         g);    
    difftauset = vertcat(difftauset{:});
    
    DiffTauTable.Fid = cell2mat(difftauset(:,1));
    DiffTauTable.ID = cell2mat(difftauset(:,2));
    DiffTauTable.Tau = cell2mat(difftauset(:,3));
    DiffTauTable.Xdiff = difftauset(:,4);
    DiffTauTable.Ydiff = difftauset(:,5);
    DiffTauTable.Xodiff = difftauset(:,6);
    DiffTauTable.Yodiff = difftauset(:,7);
 
    DiffTauTable = struct2table(DiffTauTable);
    
return
   
   
function [outs, taulist] = split_apply_difftau(fid, id, data, taulist)

    taulist = taulist(:);   
%     Ntaus = length(taulist);
    myfid{1} = unique(fid);
    myid{1} = unique(id);
    
    myfid = repmat(myfid, length(taulist), 1);
    myid = repmat(myid, length(taulist), 1);
    mytaus = mat2cell(taulist, ones(size(taulist)));
    mydifftau = difftau(data, taulist);    
    
    % Output shape of difftau is [Ndiffs Mdatasets Ptausteps]. Want to
    % rearrange this a bit for the output here. The new shape should be
    % [Ptausteps Mdatasets Ndiffs]. 
    mydifftau = permute(mydifftau, [3 2 1]);
    
    for k = 1:size(mydifftau,1)
        for m = 1:size(mydifftau,2)
            mydiffs{k,m} = squeeze(mydifftau(k,m,:));
        end
    end    
    
    outs = [myfid myid mytaus mydiffs];
%     outs = cell2table(outs);
    
return