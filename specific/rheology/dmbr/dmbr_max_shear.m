function [vd, shear_max] = dmbr_shear_max(rheo_table, params)

dmbr_constants;

percent_of_response_for_fit = 0.25; % 25%

idx = find(rheo_table(:,VOLTS) ~= 0);
rheo_table = rheo_table(idx,:);

if size(rheo_table,1) > 1
    
    x = rheo_table(:,X);
    y = rheo_table(:,Y);
    
    x = x - x(1);
    y = y - y(1);
    
    r = magnitude(x,y);
    
    len = size(rheo_table, 1);
    min_idx = floor((1-percent_of_response_for_fit)*len);
    
    t = rheo_table(min_idx:end,TIME);
    r = r(min_idx:end);
    
    [fit,S] = polyfit(t, r, 1);
    
    vd = fit(1);
    
    shear_max = shear_rate_max(vd, params.bead_radius*1e-6);
    
%     fprintf('%i\t%i\t%f\t%f\n', min_idx, len, vd, shear_max);

else
    
    vd = NaN;
    shear_max = NaN;
    
end


return;


    
    
