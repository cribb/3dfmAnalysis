function [visc, visc_err] = pan_compute_viscosity_heatmap(metadata, spec_tau, msdmap, msdmap_err)

bead_radius = metadata.plate.bead.diameter ./ (2 * 1e6);
bead_radius = transpose(reshape(bead_radius, 12,8));

kB = 1.3806e-23;
T = 296; % temperature in Kelvin 

visc = (2 * kB * T * spec_tau) ./ (3 * pi * bead_radius .* 10.^msdmap);
visc_with_err = (2 * kB * T * spec_tau) ./ (3 * pi * bead_radius .* 10.^(msdmap+msdmap_err));

visc_err = abs(visc_with_err - visc);

visc = reshape(visc, 12, 8)';
visc_err = reshape(visc_err, 12, 8)';

return;
