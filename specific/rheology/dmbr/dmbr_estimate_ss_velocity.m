function [vel, G, n] = dmbr_estimate_ss_values(rheo_table)

dmbr_constants;

percent_of_response_for_fit = 0.1; % 10%

% iterate across beads
available_beads = unique(rheo_table(:,ID))'

% iterate across sequences
available_sequences = unique(rheo_table(:,SEQ))'

% preseed matrix with NaN
vel = NaN * zeros(max(available_beads), max(available_sequences));
G = vel;
n = vel;

for k = 1:length(available_beads)
    for m = 1:length(available_sequences)
        idx = find(rheo_table(:,ID) == available_beads(k) & rheo_table(:,SEQ) == available_sequences(m));

        if length(idx) > 0
         vel(k,m) = compute_velocity(rheo_table(idx,:), percent_of_response_for_fit);
         [G(k,m),n(k,m)] = compute_ss_rheo_values(rheo_table(idx,:), percent_of_response_for_fit);
        end
    end    
end

return;

function vel_out = compute_velocity(rheo_table, percent_of_response_for_fit);
    dmbr_constants;    
    r = magnitude(rheo_table(:,X:Y));
    
    len = size(rheo_table, 1);
    min_idx = floor( (1-percent_of_response_for_fit)*len);
    t = rheo_table(min_idx:end,TIME);
    r = r(min_idx:end);
    [fit,S] = polyfit(t, r, 1);
    
    vel_out = fit(1);

    return;

function [G,n] = compute_ss_rheo_values(rheo_table, percent_of_response_for_fit);    
    
    dmbr_constants;    
        
    r = magnitude(rheo_table(:,X:Y));
    
    len = size(rheo_table, 1);
    min_idx = floor( (1-percent_of_response_for_fit)*len);
    t = rheo_table(min_idx:end,TIME);
    r = r(min_idx:end);
    compliance = rheo_table(min_idx:end,J);
    [fit,S] = polyfit(t, compliance, 1);
    
    G = 1/fit(2);
    n = 1/fit(1);
    
    return;
    
    
