function outs = pan_tracker_report(filepath, systemid, plate_type)

video_tracking_constants;

if nargin < 1 || isempty(filepath)
    filepath = '.';
end;

metadata = pan_load_metadata(filepath, systemid, plate_type);

fps = metadata.instr.fps_imagingmode;

bead_stacks_NF = pan_collect_tracker_areas(filepath, 'panoptes', 'n');

cs = combine_tracker_image_stacks(bead_stacks_NF);
scs = sort_tracker_images(cs, 'sens');
h = plot_tracker_images(scs, 'sens');

% Load ALL of the trajectories in the path
csvfiles = '*video_*_TRACKED.csv';
d = load_video_tracking(csvfiles, fps, 'pixels', [], 'absolute', 'no', 'table');

% Assemble the filt structure for filtering the data
filt.xyzunits   = 'pixels';
filt.tcrop      = 3;
filt.min_frames = 10;
filt.min_pixels = 0;
filt.max_pixels = Inf;
filt.min_visc = 0;  % Pa s
filt.xycrop     = 0;
filt.dead_spots = [0 0 0 0];
filt.drift_method = 'none';
filt.max_region_size = Inf;
filt.min_sens = 0;

% filter the data
[dfilt, filtout] = filter_video_tracking(d, filt);

% compute the MSDs
mymsd = video_msd(dfilt, 50, 32.6, 0.152, 'y', 'no');

% Pull out the ID numbers from the resulting filtered data. These IDs will
% serve as the index for all tracked particles for ALL data, images
% included (well there will be two lists that will be checked against each
% other for consistency).
IDlist = unique(dfilt(:,ID))';

% Pull out the corresponding sensitivity (goodnes-of-fit) data
for k = 1:length(IDlist); 
    idx = find( dfilt(:,ID) == IDlist(k)); 
    mysens(1,k) = dfilt(idx(1),SENS); 
end;

MSDdat = [mymsd.trackerID(:) mymsd.msd(1,:)'];
SENSdat = [IDlist(:) mysens(:)];

figure; 
plot(log10(SENSdat(:,2)), log10(MSDdat(:,2)),'.');
xlabel('log_{10}(sens)'); 
ylabel('log_{10}(MSD)');

outs = [];

return;
