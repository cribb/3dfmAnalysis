function [tracker_stack, tracker_list] = get_tracker_images(vid_table, im, tracker_halfsize, reportyn)
% tracker locations embedded in video_tracking_constants format

video_tracking_constants;


if nargin < 4 || isempty(reportyn)
    reportyn = 'n';
end

if nargin < 3 || isempty(tracker_halfsize)
    tracker_halfsize = 15; % pixels
end

if nargin < 2
    error('Not enough inputs.');
end
    
% check that we have only one frame in the data
if length(unique(vid_table(:,FRAME))) > 1
    error('Too many frames in input data. Reduce to one frame and try again.');
end

tracker_list = unique(vid_table(:,ID))';
Ntrackers = length(tracker_list);

if Ntrackers ~= size(vid_table,1)
    error('Too many entries in the vid_table. One or more IDs are represented more than once.');
end

width = size(im, 2);
height = size(im, 1);

tfs = 2*tracker_halfsize;

tracker_stack = zeros(tfs, tfs, Ntrackers);

for k = 1:Ntrackers

    % find the k_th tracker row number
    idx = ( vid_table(:,ID) == tracker_list(k) );
    
    % extract x and y locations
    x = round(vid_table(idx, X));
    y = round(vid_table(idx, Y));
    
    % determine boundaries for mini_image
    xmin = x - tracker_halfsize;
    xmax = x + tracker_halfsize;
    ymin = y - tracker_halfsize;
    ymax = y + tracker_halfsize;
    
    % determine boundaries in full inputted image
    if xmin <= 0
        x_under = abs(xmin)+1;
        x1_im = 1;
    else
        x_under = 0;
        x1_im = xmin;
    end
           
    if xmax > width
        x_over = xmax - width;
        x2_im = width;
    else
        x_over = 0;
        x2_im = xmax;
    end
    
    if ymin <= 0
        y_under = abs(ymin)+1;        
        y1_im = 1;
    else
        y_under = 0;
        y1_im = ymin;
    end    
   
    if ymax > height
        y_over = ymax - height;
        y2_im = height;
    else        
        y_over = 0;
        y2_im = ymax;
    end
    
    % switch from x,y of cartesian coords to matrix/pixel row,col location
    row1 = y1_im;
    row2 = y2_im-1;
    col1 = x1_im;
    col2 = x2_im-1;
    
    % extract the temporary matrix that describes what bit of image exist for
    % this particular trackerID
    tmp_im = im(row1:row2, col1:col2);

    % switch from x,y of cartesian coords to matrix/pixel row,col location
    row1 = 1+y_under;
    row2 = tfs-y_over;
    col1 = 1+x_under;
    col2 = tfs-x_over;    
    
    % set the default value in the mini-image to be the mean of the entire
    % available mini-image (sets unavailable pixels/edges to average value)
    mini_im = ones(tfs, tfs) * mean(tmp_im(:));    
    
    % convert tmp matrix into full-sized mini-image
    mini_im(row1:row2, col1:col2) = tmp_im;
    
    % put mini-image into proper location in outputted stack
    tracker_stack(:,:,k) = mini_im;
end

if findstr(lower(reportyn), 'y')
%     plot_tracker_images();
end

return
