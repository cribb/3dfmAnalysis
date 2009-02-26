function outs = dmbr_fit_all(rheo_table, fit_type)

    dmbr_constants;

%     fit_type = params.fit_type;
    
    % iterate across beads
    available_beads = unique(rheo_table(:,ID))';

    % iterate across sequences
    available_sequences = unique(rheo_table(:,SEQ))';

    % preseed matrix with NaN
    vel = NaN * zeros(max(available_beads), max(available_sequences));
    G = vel;
    n = vel;

    count = 1;
    for k = 1:length(available_beads)
        for m = 1:length(available_sequences)
            idx = find(rheo_table(:,ID) == available_beads(k) & rheo_table(:,SEQ) == available_sequences(m));
            table = rheo_table(idx,:); 
            
            [G, eta, ct_fit, R_square] = dmbr_fit(table, fit_type);
                
            outs(count,:) = [G, eta, R_square];

            count = count + 1;
        end
    end    

return;

