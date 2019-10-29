function MsdTable = grouped_msd(DataIn, group_names)

    if nargin < 2 || isempty(group_names)
        group_names = {'SampleName', 'SampleInstance', 'FovID', 'Tau'};
    end

    
    v = DataIn.VidTable(:,{'Fid', 'SampleName', 'SampleInstance', 'FovID', 'Fps', 'Calibum'});
    m = DataIn.MsdTable(:,{'Fid', 'ID', 'Tau', 'MsdX', 'MsdY', 'MsdXo', 'MsdYo', 'N'});

    b = join(m, v);
    
    b.MsdX = b.MsdX .* (b.Calibum).^2;
    b.MsdY = b.MsdY .* (b.Calibum).^2;
    b.MsdXo = b.MsdXo .* (b.Calibum).^2;
    b.MsdYo = b.MsdYo .* (b.Calibum).^2;    
    b.Properties.VariableUnits{'MsdX'} = '[um^2]';
    b.Properties.VariableUnits{'MsdXo'} = '[um^2]';
    b.Properties.VariableUnits{'MsdY'} = '[um^2]';
    b.Properties.VariableUnits{'MsdYo'} = '[um^2]';
    
    b.Tau = b.Tau ./ b.Fps;
    b.Properties.VariableUnits{'Tau'} = '[s]';
    
    b.Calibum = [];
    b.Fps = [];
    
    [g, mygroups] = findgroups(b(:,group_names));

%     [g,gFid,gID] = findgroups(MsdTable.Fid, MsdTable.ID);        
    
    msdset = splitapply(@(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11){split_apply_groupmsd(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11)}, ...
                                         b.Fid, ...
                                         b.ID, ...
                                         b.Tau, ...
                                         b.MsdX, ...
                                         b.MsdY, ...
                                         b.MsdXo, ...
                                         b.MsdYo, ...                                         
                                         b.N, ...
                                         b.SampleName, ...
                                         b.SampleInstance, ...
                                         b.FovID, ...
                                         g);    
                                     
%     msdset = splitapply(@split_apply_groupmsd, blah, g);    
    
    msdset = cell2mat(msdset);
    
    msdout = table(msdset(:,1), msdset(:,2), msdset(:,3), msdset(:,4), msdset(:,5), msdset(:,6), msdset(:,7), msdset(:,8), msdset(:,9), msdset(:,10));
    msdout.Properties.VariableNames = {'MsdX', 'MsdY', 'MsdXo', 'MsdYo', 'varMsdX', 'varMsdY', 'varMsdXo', 'VarMsdYo', 'Ntrackers', 'Nestimates'};
    msdout.Properties.VariableUnits = {'um^2', 'um^2', 'um^2', 'um^2', 'um^4', 'um^4', 'um^4', 'um^4', '', ''};
           
    MsdTable = [mygroups, msdout];

%     MsdTable.Fid = mymsd(:,1);
%     MsdTable.ID = mymsd(:,2);
%     MsdTable.Tau = mymsd(:,3);
%     MsdTable.MsdX = mymsd(:,4);
%     MsdTable.MsdY = mymsd(:,5);    
%     MsdTable.MsdXo = mymsd(:,6);
%     MsdTable.MsdYo = mymsd(:,7);
%     MsdTable.N = mymsd(:,8);
        
%     MsdTable = struct2table(MsdTable);
    
return
   
   
function outs = split_apply_groupmsd(Fid, ID, Tau, MsdX, MsdY, MsdXo, MsdYo, N, SampleName, SampleInstance, FovID)

    aggN = sum(N);
    weights = N./aggN;
    count = sum(~isnan(MsdX));
    
    MsdX = log10(MsdX);
    MsdY = log10(MsdY);
    MsdXo = log10(MsdXo);
    MsdYo = log10(MsdYo);
    
    % Setting NaNs to zero because a NaN now has zero weight and won't
    % matter anyway.
    MsdX(isnan(MsdX)) = 0;
    MsdY(isnan(MsdY)) = 0;
    MsdXo(isnan(MsdXo)) = 0;
    MsdYo(isnan(MsdYo)) = 0;

    aggMsdX = sum(MsdX .* weights, [], 'omitnan');
    aggMsdY = sum(MsdY .* weights, [], 'omitnan');
    aggMsdXo = sum(MsdXo .* weights, [], 'omitnan');
    aggMsdYo = sum(MsdYo .* weights, [], 'omitnan');
    
    V1 = aggN ./ (aggN-1);
%     varMsdX = V1 * sum(weights .*(MsdX(:) - repmat(aggMsdX,size(MsdX,1),1)).^2, 1);
    varMsdX = sum(weights .*(MsdX(:) - repmat(aggMsdX,size(MsdX,1),1)).^2, 1);
    varMsdY = sum(weights .*(MsdY(:) - repmat(aggMsdY,size(MsdY,1),1)).^2, 1);
    varMsdXo = sum(weights .*(MsdXo(:) - repmat(aggMsdXo,size(MsdXo,1), 1)).^2, 1);
    varMsdYo = sum(weights .*(MsdYo(:) - repmat(aggMsdYo,size(MsdYo,1), 1)).^2, 1);
    
    outs = [aggMsdX, aggMsdY, aggMsdXo, aggMsdYo, varMsdX, varMsdY, varMsdXo, varMsdYo, count, aggN];
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
