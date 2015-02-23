function [plate_msds_by_well, heatmaps] = pan_compute_platewide_msd(metadata, spec_tau)

% nametag = metadata.instr.experiment;
% outf = metadata.instr.experiment;
% duration = metadata.instr.seconds;
% autofocus = metadata.instr.auto_focus;
% video_mode = metadata.instr.video_mode;
% imaging_fps = metadata.instr.fps_imagingmode;

% bead_radius = metadata.plate.bead.diameter ./ (2 * 1e6);
    
    
% bead_radius = cellfun(@str2num, metadata.plate.bead.diameter) ./ (2 * 1e6);
% bead_radius = bead_radius(:)';


%%%%
% compute the MSD for each WELL (for heatmap plots)
%%%%
if nargin < 2 || isempty(spec_tau)
    spec_tau = 1;
end

msds = NaN(1,96);
msd_err = NaN(1,96);
ns  = NaN(1,96);

[plate_msds_by_well wellID] = pan_combine_data(metadata, 'metadata.plate.well_map');

all_taus = [plate_msds_by_well.mean_logtau];
all_msds = [plate_msds_by_well.mean_logmsd];
all_errs = [plate_msds_by_well.msderr];
all_ns   = [plate_msds_by_well.n];

log_spec_welltau = log10(spec_tau);

[minval, minloc] = min( sqrt((all_taus - log_spec_welltau).^2) );

msds(1, str2num(char(wellID)) ) = all_msds(minloc(1),:); %#ok<*ST2NM>
msd_err(1, str2num(char(wellID)) ) = all_errs(minloc(1),:);
ns(  1, str2num(char(wellID)) ) = all_ns(minloc(1),:);

heatmaps.spec_tau = spec_tau;
heatmaps.msd = pan_array2plate(msds);
heatmaps.msd_err = pan_array2plate(msd_err);
heatmaps.beadcount = pan_array2plate(ns);

return;
