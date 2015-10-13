function sorted_stack = sort_tracker_images(tracker_stack, sort_by)

if nargin < 2 || isempty(sort_by)
    sort_by = 'id';
end

vid_table = tracker_stack.vid_table;
tracker_halfsize = tracker_stack.halfsize;
mystack = tracker_stack.stack;

N = size(vid_table,1);

% redirect input to output. Be careful, because the output needs to be reordered.
sorted_stack = tracker_stack;

video_tracking_constants;

tkey = 1:size(vid_table,1);
tmp = [tkey(:) vid_table];

switch lower(sort_by)
    case 'id'
       tmp = sortrows(tmp, ID+1); 
       sorted_vals = tmp(:, ID+1);
    case 'area'
       tmp = sortrows(tmp, AREA+1);
       sorted_vals = tmp(:, AREA+1);
    case 'newarea'       
        % scale images to be 255 max
        for k = 1:length(sorted_stack.stack)
            tmp_im = sorted_stack.stack(:,:,k);
            tmp_im = tmp_im / max(tmp_im(:)) * 255;
            px_above_thresh = tmp_im > (255 * 0.5); 
            newarea(k) = sum(px_above_thresh(:));
        end
        
        tmp = [tmp , newarea(:)];
        newareaCOL = size(tmp,2);
        tmp = sortrows(tmp, newareaCOL);
        sorted_vals = tmp(:,newareaCOL);                
    case 'yaw'
       tmp = sortrows(tmp, YAW+1);
       sorted_vals = tmp(:, YAW+1);        
    case 'sens'
       tmp = sortrows(tmp, SENS+1);
       sorted_vals = tmp(:, SENS+1);
    otherwise
        error('Incorrect sorting variable used. Consult help text for this function.');
end
tkey = tmp(:,1);
clear('tmp');

sorted_stack.vid_table = vid_table(tkey, :);
sorted_stack.stack = mystack(:,:,tkey);
sorted_stack.sort_by = sort_by;
sorted_stack.sorted_vals = sorted_vals;

return;



