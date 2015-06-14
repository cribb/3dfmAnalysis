function h = plot_tracker_images(vid_table, im, tracker_halfwidth, sort_by)

video_tracking_constants;

% traj_filename = '2014_04_21_pancreatic_constructs_video_pass1_well46_TRACKED.csv';
% vid_table = load_video_tracking(traj_filename, [], 'pixels', 1, 'absolute', 'no', 'table');
% im = imread('2014_04_21_pancreatic_constructs_FLburst_pass1_well46.pgm');
% tracker_halfwidth = 15;
% sort_by = 'id';


frame1 = vid_table( vid_table(:,FRAME) == 1, :);

[tstack,tlist] = get_tracker_images(frame1, im, tracker_halfwidth);

tkey = 1:size(frame1,1);
tmp = [tkey(:) frame1];

switch lower(sort_by)
    case 'id'
       tmp = sortrows(tmp, ID+1); 
       sorted_vals = tmp(:, ID+1);
    case 'area'
       tmp = sortrows(tmp, AREA+1);
       sorted_vals = tmp(:, AREA+1);
    case 'sens'
       tmp = sortrows(tmp, SENS+1);
       sorted_vals = tmp(:, SENS+1);
    otherwise
        error('Incorrect sorting variable used. Consult help text for this function.');
end
tkey = tmp(:,1);
clear('tmp');

ts_by_area = tstack(:,:,tkey);

q = reshape(ts_by_area, 2*tracker_halfwidth, 2*tracker_halfwidth*length(tlist));

h = figure; 

figure(h);
    subplot(2,1,1); 
    imagesc(q); 
    colormap(gray(256)); 
    
figure(h);
    subplot(2,1,2); 
    bar(sorted_vals);

set(h, 'Units', 'Normalized');

pos = get(h, 'Position');
pos(1) = 0.1;
pos(2) = 0.1;
pos(4) = 3 * (pos(3) / length(tlist));
set(h, 'Position', pos);
drawnow;



