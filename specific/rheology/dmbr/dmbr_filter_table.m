function v = dmbr_filter_table(rheo_table, beadID, sequence, voltage)

    dmbr_constants;    

    filtered_table = rheo_table;
    
    % filter out all but current bead
    if ~isempty(beadID)
        idx = find(rheo_table(:,ID) == beadID);
        filtered_table = filtered_table(idx,:);
        clear('idx');
    end
    
    if ~isempty(sequence)
        idx = find(filtered_table(:,SEQ) == sequence);
        filtered_table = filtered_table(idx,:);
        clear('idx');
    end
    
    if ~isempty(voltage)
        idx = find(filtered_table(:,VOLTS) == voltage);
        filtered_table = filtered_table(idx,:);
        clear('idx');
    end
    
 
    v = filtered_table;


    return;
    
    
