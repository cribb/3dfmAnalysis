function msdout = msd_concat(msdA, msdB)

    if isfield(msdA, 'trackerID') && ...
       isfield(msdB, 'trackerID') && ...
       size(msdA.trackerID,1) == size(msdB.trackerID,1)
       msdout.trackerID = [msdA.trackerID, msdB.trackerID];
    elseif ~isfield(msdA, 'trackerID') && isfield(msdB, 'trackerID')
       msdout.trackerID = msdB.trackerID;
       logentry('No data in msdA, just copying over msdB');
    else
       error('One or both msd inputs does not contain trackerIDs OR they are not of commensurate size.');
    end

    if isfield(msdA, 'tau') && ...
       isfield(msdB, 'tau') && ...
       size(msdA.tau,1) == size(msdB.tau,1)
       msdout.tau = [msdA.tau, msdB.tau];
    elseif ~isfield(msdA, 'tau') && isfield(msdB, 'tau')
       msdout.tau = msdB.tau;
       logentry('No data in msdA, just copying over msdB');
    else
       error('One or both msd inputs does not contain tau data OR they are not of commensurate size.');
    end

    if isfield(msdA, 'msd') && ...
       isfield(msdB, 'msd') && ...
       size(msdA.msd,1) == size(msdB.msd,1)   
       msdout.msd = [msdA.msd, msdB.msd];
    elseif ~isfield(msdA, 'msd') && isfield(msdB, 'msd')
       msdout.msd = msdB.msd;
       logentry('No data in msdA, just copying over msdB');       
    else
       error('One or both msd inputs does not contain msd data OR they are not of commensurate size.');
    end

    if isfield(msdA, 'Nestimates') && ...
       isfield(msdB, 'Nestimates') && ...
       size(msdA.Nestimates,1) == size(msdB.Nestimates,1)   
       msdout.Nestimates = [msdA.Nestimates, msdB.Nestimates];
    elseif ~isfield(msdA, 'Nestimates') && isfield(msdB, 'Nestimates')
       msdout.Nestimates = msdB.Nestimates;
       logentry('No data in msdA, just copying over msdB');
    else
       error('One or both msd inputs does not contain Nestimates OR they are not of commensurate size.');
    end
    
    if isfield(msdA, 'data_label') && ...
       isfield(msdB, 'data_label') && ...
       size(msdA.data_label,1) == size(msdB.data_label,1)
   
       msdout.data_label = [msdA.data_label, msdB.data_label];
    else
       warning('One or both msd inputs does not contain data labels OR they are not of commensurate size.');
    end
    
    return;