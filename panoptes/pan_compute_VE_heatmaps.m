function [gsers] = pan_compute_VE_heatmaps(metadata, msds, spec_tau)

kB = 1.3806e-23;
T = 296; % temperature in Kelvin 

bead_radius = metadata.plate.bead.diameter ./ (2 * 1e6);
bead_radius = pan_array2plate(bead_radius);

% for k = 1:length(msds)    
%     gsers(k) = ve(msds(k), bead_radius(k), 'f', 'no');    
% end
% 
% Gp = [gsers.

visc = (2 * kB * T * spec_tau) ./ (3 * pi * bead_radius .* 10.^msdmap);
visc_with_err = (2 * kB * T * spec_tau) ./ (3 * pi * bead_radius .* 10.^(msdmap+msdmap_err));

visc_err = abs(visc_with_err - visc);

return;
