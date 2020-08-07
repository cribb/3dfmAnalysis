function [v,q] = vst_remove_drift(TrackingTable, drift_start_time, drift_end_time, type)
% REMOVE_DRIFT Subtracts drift from 3DFM video tracking data.
%
% [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% 
% v = data minus drift
% q = drift vector/struct
% type = 'linear' or 'center-of-mass'
%

    % handle "global" variables that contain column positions for video
%     video_tracking_constants;  

    % handle the argument list
    if nargin < 1 
        TrackingTable = [];
    end
    
    if isempty(TrackingTable)
        logentry('No data found. Exiting function.'); 
        v = TrackingTable;
        q = [];
        return;
    end

    if nargin < 2 || isempty(drift_start_time)
        drift_start_time = min(TrackingTable.Frame); 
    end
   
    if nargin < 3 || isempty(drift_end_time)
        drift_end_time = max(TrackingTable.Frame); 
    end

    if nargin < 4 || isempty(type)
        type = 'linear'; 
        logentry('No drift type specified.  Choosing linear method.');
    end

    switch type
        case 'linear'
            [v,q] = linear(TrackingTable, drift_start_time, drift_end_time);
        case 'center-of-mass'
            [v,q] = center_of_mass(TrackingTable, drift_start_time, drift_end_time); 
        case 'common-mode'
            [v,q] = common_mode(TrackingTable, drift_start_time, drift_end_time);
        otherwise
            [v,q] = linear(TrackingTable, drift_start_time, drift_end_time);
            logentry('Specified type is undefined.  Switching to linear method.');
	end
        
    return


function [TrackingTableOut, ComTable] = common_mode(TrackingTable, drift_start_time, drift_end_time)
    [TrackingTable, ComTable] = vst_common_motion(TrackingTable);
    TrackingTableOut  = vst_subtract_common_motion(TrackingTable, ComTable);        
return


function [TrackingTableOut, ComTable] = center_of_mass(TrackingTable, drift_start_time, drift_end_time)
    [TrackingTable, ComTable] = vst_common_motion(TrackingTable);
    TrackingTableOut = vst_subtract_centmass_motion(TrackingTable, ComTable);
return


function [TrackingTableOut,drift_vectors] = linear(TrackingTable, drift_start_time, drift_end_time)

    idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
    [g,~] = findgroups(idGroupsTable);
    
    if ~isempty(TrackingTable)
        drift_free = splitapply(@(x1,x2,x3,x4,x5){sa_subtract_linear_drift(x1,x2,x3,x4,x5)}, ...
                                             TrackingTable.Fid, ...
                                             TrackingTable.Frame, ...
                                             TrackingTable.ID, ...
                                             TrackingTable.Xo, ...
                                             TrackingTable.Yo, ...
                                             g);    
    else
        TrackingTableOut = [];
        return
    end

    drift_free = cell2mat(drift_free);
    drift_free = num2cell(drift_free, 1);
    
    tmpT = table(drift_free{:},'VariableNames', {'Fid', 'Frame', 'ID', 'X', 'Y'});

    TrackingTable.X   = [];
    TrackingTable.Y   = [];
    
    TrackingTableOut = join(tmpT, TrackingTable);

    TrackingTableOut.Properties.VariableDescriptions{'X'} = 'x-location';
    TrackingTableOut.Properties.VariableUnits{'X'} = 'pixels';
    TrackingTableOut.Properties.VariableDescriptions{'Y'} = 'y-location';
    TrackingTableOut.Properties.VariableUnits{'Y'} = 'pixels';
    
    drift_vectors = [];
return

function outs = sa_subtract_linear_drift(fid, frame, id, xo, yo)

%         frameNeut = frame - frame(1);
        frameNeut = frame;
        if numel(frameNeut) > 2 
            
            fitx = polyfit(frameNeut, xo, 1);
%             xnew = x - polyval(fitx, t) + fitx(2);
            xnew = xo - polyval(fitx, frameNeut) + xo(1);

            fity = polyfit(frameNeut, yo, 1);
%             ynew = y - polyval(fity, t) + fity(2);
            ynew = yo - polyval(fity, frameNeut) + yo(1);

        else
            xnew = xo;
            ynew = yo;
        end

    outs = [fid, frame, id, xnew, ynew];
    
    return


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'vst_remove_drift: '];
     
     fprintf('%s%s\n', headertext, txt);
