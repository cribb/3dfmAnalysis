function outs = pan_analyze(filepath, systemid, plate_type)

filt.xyzunits   = 'pixels';
filt.tcrop      = 3;
filt.min_frames = 10;
filt.min_pixels = 0;
filt.max_pixels = Inf;
filt.min_visc = 0;  % Pa s
filt.xycrop     = 0;
filt.dead_spots = [0 0 0 0];
filt.drift_method = 'none';

specified_tau = 1; % [sec]

filetype = 'csv';

metadata = pan_load_metadata(filepath, systemid, plate_type);

% load and filter the data accordign to filt structure
[dataout, summary] = pan_load_tracking(filepath, systemid, filetype, filt);

msds = pan_video_msd(dataout);

msds = msdclean(msds);

msds_at_spec_tau = msd_at_tau(msds);

outs.msds = msds;
outs.msds_at_spec_tau = msds_at_spec_tau;
outs.spec_tau = specified_tau;

return;