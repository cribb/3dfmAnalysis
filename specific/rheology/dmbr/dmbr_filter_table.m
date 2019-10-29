function v = dmbr_filter_table(rheo_table, beadID, sequence, voltage)

    dmbr_constants;    

    filtered_table = rheo_table;
    
    % filter out all but current bead
    if ~isempty(beadID)
        idx = (rheo_table(:,ID) == beadID);
        filtered_table = filtered_table(idx,:);
        clear('idx');
    end
    
    if ~isempty(sequence)
        idx = (filtered_table(:,SEQ) == sequence);
        filtered_table = filtered_table(idx,:);
        clear('idx');
    end
    
    if ~isempty(voltage)
        idx = (filtered_table(:,VOLTS) == voltage);
        filtered_table = filtered_table(idx,:);
        clear('idx');
    end
    
 
    v = filtered_table;


    return;
    
    
