function [visc, visc_err] = pan_compute_viscosity_heatmap(metadata)

% nametag = metadata.instr.experiment;
% outf = metadata.instr.experiment;
% duration = metadata.instr.seconds;
% autofocus = metadata.instr.auto_focus;
% video_mode = metadata.instr.video_mode;
% imaging_fps = metadata.instr.fps_imagingmode;

kB = 1.3806e-23;
T = 296; % temperature in Kelvin 

bead_radius = metadata.plate.bead.diameter ./ (2 * 1e6);
    
    
% bead_radius = cellfun(@str2num, metadata.plate.bead.diameter) ./ (2 * 1e6);
% bead_radius = bead_radius(:)';

%%%%
% compute the MSD for each WELL (for the heatmap)
spec_tau = 1;
[wellmsds wellID] = pan_combine_data(metadata, 'metadata.plate.well_map');
all_welltaus = [wellmsds.mean_logtau];
all_wellmsds = [wellmsds.mean_logmsd];
all_wellerrs = [wellmsds.msderr];
heatmap_msds = NaN(1,96);
heatmap_errs = NaN(1,96);
log_spec_welltau = log10(spec_tau);
[minval, minloc] = min( sqrt((all_welltaus - log_spec_welltau).^2) );
mywelltau = 10.^all_welltaus(minloc(1),:);
mywellmsd = all_wellmsds(minloc(1),:);
mywellerr = all_wellerrs(minloc(1),:);
heatmap_msds(1, str2num(char(wellID)) ) = mywellmsd;
heatmap_errs(1, str2num(char(wellID)) ) = mywellerr;


visc = (2 * kB * T * spec_tau) ./ (3 * pi * bead_radius .* 10.^heatmap_msds);
visc_with_err = (2 * kB * T * spec_tau) ./ (3 * pi * bead_radius .* 10.^(heatmap_msds+heatmap_errs));

visc_err = abs(visc_with_err - visc);

visc = reshape(visc, 12, 8)';
visc_err = reshape(visc_err, 12, 8)';

return;
