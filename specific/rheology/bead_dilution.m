function dil_factor = bead_dilution(pct_solids, bead_diameter_um, bead_material_density_gcm3, desired_mean_free_path_um)
% dil_factor = bead_dilution(pct_solids, bead_diameter_um, bead_material_density_gcm3, desired_mean_free_path_um)


if nargin < 1 || isempty(pct_solids)
    error('Need a bead concentration in % solids');
end

if nargin < 2 || isempty(bead_diameter_um)
    bead_diameter_um = 1;
end

if nargin < 3 || isempty(bead_material_density_gcm3)
    bead_material_density_gcm3 = 1.05;
end

if nargin < 4 || isempty(desired_mean_free_path_um)
    desired_mean_free_path_um = 10 .* bead_diameter_um;
end


bead_radius_um = bead_diameter_um ./ 2;

bead_radius_m = bead_radius_um * 1e-6;

bead_volume_m3 = (4/3) * pi .* bead_radius_m .^ 3;

bead_material_density_kgm3 = bead_material_density_gcm3 * 1000;

bead_mass_kg = bead_material_density_kgm3 .* bead_volume_m3;
bead_mass_g = bead_mass_kg .* 1000;

mass_of_beads_grams_per_uL = (pct_solids / 100) / 1000;  % (g/100mL -> g/mL -> g/uL)

bead_count_per_uL = mass_of_beads_grams_per_uL ./ bead_mass_g;

beads_per_mm = (bead_count_per_uL) .^ (1/3);

mean_free_path_mm = 1 ./ beads_per_mm;

mean_free_path_um = mean_free_path_mm .* 1000;

dil_factor = (desired_mean_free_path_um ./ mean_free_path_um) ^3;




