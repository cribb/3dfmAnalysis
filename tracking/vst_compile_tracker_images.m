function DataOut = vst_compile_tracker_images(DataIn)

    BigData = join(DataIn.TrackingTable, DataIn.ImageTable, 'Keys', 'Fid');
    
    [g,gFid,gID] = findgroups(BigData.Fid, BigData.ID);
    
    trackim  = splitapply(@(x1,x2,x3,x4){get_image_areas(x1,x2,x3,x4)}, ...
                                         BigData.Xo, ...
                                         BigData.Yo, ...
                                         BigData.FirstFrames, ...
                                         floor(BigData.Radius*1.5), ...
                                         g);
                                     
%     drift_free = cell2mat(drift_free);

    tmp.Fid = gFid;
    tmp.ID = gID;
    tmp.beadImageFF = trackim;
    
    tmpT = struct2table(tmp);

%     outs = join(tmpT, TrackingTable);
     DataOut = tmpT;
     
    return;
                                     



function ia = get_image_areas(x, y, im, tracker_halfsize)
    
    im = im{1};
    
    width = size(im, 2);
    height = size(im, 1);
    
    tracker_halfsize = unique(tracker_halfsize);
    
    
    
    tfs = 2*tracker_halfsize;
    
    % extract x and y locations
    x = round(x);
    y = round(y);
    
    % determine boundaries for mini_image
    xmin = x(1) - tracker_halfsize;
    xmax = x(1) + tracker_halfsize;
    ymin = y(1) - tracker_halfsize;
    ymax = y(1) + tracker_halfsize;
    
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
    ia = mini_im;
    
% % % %     % calculate the cross-sectional area of the tracker and add it to the
% % % %     % outputted data. I don't know a better place to put this at the moment    
% % % %     scaled_tmp_im = tmp_im / max(tmp_im(:)) * 255;  % scale images to be 255 max
% % % %     px_above_thresh = scaled_tmp_im > (255 * 0.5);  % assuming full 'width' at half max
% % % %     newarea(k,1) = sum(px_above_thresh(:));
    
    return;
    





function tracker_stack = get_tracker_images(vid_table, im, tracker_halfsize, reportyn)
% tracker locations embedded in video_tracking_constants format

if findstr(lower(reportyn), 'y') %&& ~isempty(vid_table)
    h = plot_tracker_images(tracker_stack, 'id');
end

return

