function DiffTauTable = vst_difftau(DataIn, taulist)

    TrackingTable = innerjoin(DataIn.TrackingTable, DataIn.VidTable(:,{'Fid', 'Calibum'}));

    [g,~] = findgroups(TrackingTable(:, {'Fid', 'ID'}));
    

    % HERE, LENGTH SCALES ARE CONVERTED INTO [PIXELS] INTO [UM]
    XYXoYo_pix =  [TrackingTable.X, TrackingTable.Y, ...
                  TrackingTable.Xo, TrackingTable.Yo];
    XYXoYo_um =  XYXoYo_pix .* repmat(TrackingTable.Calibum,1,4);

    difftauset =  splitapply(@(x1,x2,x3){split_apply_difftau(x1,x2,x3,taulist)}, ...
                                        TrackingTable.Fid, ...
                                        TrackingTable.ID, ...
                                        XYXoYo_um, ...
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
    
    tmpT = innerjoin(DiffTauTable, DataIn.VidTable(:,{'Fid', 'Fps'}));
    DiffTauTable.Tau_s = DiffTauTable.Tau ./ tmpT.Fps;
%     DiffTauTable.Tau_s = DiffTauTable.Tau ./ 60;
    
    DiffTauTable = movevars(DiffTauTable, 'Tau_s', 'after', 'Tau');
    
    DiffTauTable.Properties.Description = 'Displacements in microns over Tau';
    DiffTauTable.Properties.VariableDescriptions = { 'FileID (key)', ...
                                                     'Trajectory ID',...
                                                     'Time scale, frames', ...
                                                     'Time scale, seconds', ...
                                                     'Displacements over Tau, X (filtered)', ...
                                                     'Displacements over Tau, Y (filtered)', ...
                                                     'Displacements over Tau, X (original)', ...
                                                     'Displacements over Tau, Y (original)'};
                                                 
    DiffTauTable.Properties.VariableUnits = {'', '', 'frames', 'sec', 'um', 'um', 'um', 'um'};
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