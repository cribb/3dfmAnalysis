function table_out = dmbr_attach_forces(calib, vid_table, caltype);
% caltype = 'avg' then forces are averaged, 'disp' function of displacement

dmbr_constants;

voltages = unique(vid_table(:,VOLTS));

for k = 1:length(voltages)
    
    idx = find(vid_table(:,VOLTS) == voltages(k));
    
    r = magnitude(vid_table(idx,X:Y));
    
    [force, force_err] = varforce_get_force(calib, r, voltages(k));
    
    vid_table(idx, FORCE) = force;
    vid_table(idx, [FERR_H, FERR_L]) = force_err;
    
    table_out = vid_table;
end

% sometimes we want the average force
if strcmp(caltype, 'avg')
    % for each bead
    for k = unique(vid_table(:,ID))'
        % for each sequence
        for m = unique(vid_table(:,SEQ))'
            % for each voltage
            for n = unique(vid_table(:,VOLTS))'
                idx = find(vid_table(:,ID) == k & vid_table(:,SEQ) == m & vid_table(:,VOLTS) == n);
                
                table_out(idx,FORCE) == repmat(mean(table_out(idx,FORCE)), length(idx), 1);
            end
        end
    end
end
