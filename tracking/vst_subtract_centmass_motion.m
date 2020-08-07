function outs = vst_subtract_centmass_motion(TrackingTable, ComTable)

    idGroupsTable = TrackingTable(:,{'Fid', 'ID'});
    [g,~] = findgroups(idGroupsTable);
    
    frame = ComTable.Frame;    
    
    [xfit, ~] = polyfit(frame, ComTable.Xcom, 1);
    [yfit, ~] = polyfit(frame, ComTable.Ycom, 1);

    ComTable.Fitx = polyval(xfit, frame);
    ComTable.Fity = polyval(yfit, frame); 

    TempTable = innerjoin(TrackingTable, ComTable);

    if ~isempty(TrackingTable)
        drift_free = splitapply(@(x1,x2,x3,x4,x5,x6,x7){subtract_center_of_mass(x1,x2,x3,x4,x5,x6,x7)}, ...
                                             TempTable.Fid, ...
                                             TempTable.Frame, ...
                                             TempTable.ID, ...
                                             TempTable.Xo, ...
                                             TempTable.Yo, ...
                                             TempTable.Fitx, ...
                                             TempTable.Fity, ...
                                             g);    
    else
        outs = [];
        return
    end

    drift_free = cell2mat(drift_free);
    drift_free = num2cell(drift_free, 1);
    
    tmpT = table(drift_free{:},'VariableNames', {'Fid', 'Frame', 'ID', 'X', 'Y'});

    TrackingTable.X   = [];
    TrackingTable.Y   = [];
    
    outs = innerjoin(tmpT, TrackingTable);

    outs.Properties.VariableDescriptions{'X'} = 'x-location';
    outs.Properties.VariableUnits{'X'} = 'pixels';
    outs.Properties.VariableDescriptions{'Y'} = 'y-location';
    outs.Properties.VariableUnits{'Y'} = 'pixels';
    
return


function outs = subtract_center_of_mass(fid, frame, id, x, y, xcom, ycom)
    
    xy = [x(:) y(:)];
    centerofmass_xy = [xcom(:) ycom(:)];

    xy_offset = xy(1,:);
    centerofmass_offset = centerofmass_xy(1,:);

    xy = xy - xy_offset;        
    centerofmass_xy = centerofmass_xy - centerofmass_offset;

    new_xy = xy - centerofmass_xy;

    new_xy = new_xy + xy_offset;

    outs = [fid, frame, id, new_xy];
return