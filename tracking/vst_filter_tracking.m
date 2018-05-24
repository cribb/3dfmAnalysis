function [TrackingTableOut, Trash] = vst_filter_tracking(TrackingTableIn, filtin)
% FILTER_VIDEO_TRACKING    Filters video tracking datasets
% CISMM function
% video
%
% 
% This function reads in a TrackingTable dataset/structure and filters it 
% using filter types defined below.
% 
% function [outs, filtout] = filter_video_tracking(data, filtin)
%
% where 
%       "data" 
%       "filtin"
%	    "min_frames" 
%       "min_pixels"
%       "max_pixels" 
%       "tcrop" 
%       "xycrop" 
%       "jerk_limit"
%       "min_intensity"
%
% Notes:
% - This function is designed to work under default conditions with
%   only the filename as an input argument.

    %  Handle inputs
    if (nargin < 2) || isempty(filtin)
        filtin.min_frames      = 0;
        filtin.min_pixels      = 0;
        filtin.max_pixels      = Inf;
        filtin.max_region_size = Inf;
        filtin.min_sens        = 0;
        filtin.tcrop           = 0;
        filtin.xycrop          = 0;
        filtin.xyzunits        = 'pixels';
        filtin.calib_um        = 1;
        filtin.drift_method    = 'none';
        filtin.dead_spots      = [];
        filtin.jerk_limit      = [];
        filtin.min_intensity   = 0;
        filtin.deadzone        = 0; % deadzone around trackers [pixels]
        filtin.overlapthresh  = 0;
    end

    filtout = filtin;
    
    if (nargin < 1) || isempty(TrackingTableIn) 
        logentry('No data inputs set. Exiting filter_vst_tracking now.');
        TrackingTableOut = [];
        filtout.drift_vector = [NaN NaN];
        return;
    end
    
TrackingTable = TrackingTableIn;

vars = {'Fid', 'ID'};
TrackingTable = sortrows(TrackingTable,vars);
[gid, GroupsTable] = findgroups(TrackingTable(:,vars));

%
% Inputted TrackingTable needs editing, so how?
%
% When data are filtered, replace the X and Y values with NaN. The Xo and
% Yo data will remain untouched. Perhaps, to eliminate coding issue for
% datasets where entire trajectories are removed, those rows can be moved
% to a "Trash" or "Filtered" table for reference later.
%

% Need to establish (or PASS IN) the variable groups 
% GroupTable = TrackingTable(:,{'Fid', 'ID'});

    %  Handle filters    
    if isfield(filtin, 'tcrop')
        if filtin.tcrop > 0
            logentry(['tcrop- Removing first and last ' num2str(filtin.tcrop) ' time points from each trajectory.']);
            
            temp = splitapply(@(x){filter_tcrop(x,filtin.tcrop)}, [TrackingTable.X, TrackingTable.Y], gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);         
        end
    end    

    % 'minframes' the minimum number of frames required to keep a tracker
    if isfield(filtin, 'min_frames')
        if filtin.min_frames > 0
            logentry(['min_frames- Removing trackers existing for less than ' num2str(filtin.min_frames) ' frames.']);

            temp = splitapply(@(x){filter_min_frames(x,filtin.min_frames)}, [TrackingTable.X, TrackingTable.Y], gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);
        end
    end

    % Minimum sensitivity given the first XY datapoint of the trajectory
    if isfield(filtin, 'min_sens')
        if filtin.min_sens > 0
            logentry(['min_sens- Removing trackers existing with minimum sensitivities (image-SNR) lower than ' num2str(filtin.min_sens) '.']);

            temp = splitapply(@(x,y){filter_min_sens(x,y,filtin.min_sens)}, [TrackingTable.X, TrackingTable.Y], TrackingTable.Sensitivity, gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);
        end
    end

    % maxarea given the first XY datapoint of the trajectory
    if isfield(filtin, 'max_region_size')
        if filtin.max_region_size < Inf
            logentry(['max_region_size- Removing trackers with region sizes (tracker area) larger than ' num2str(filtin.max_region_size) ' pixels^2.']);

            temp = splitapply(@(x,y){filter_max_region_size(x,y,filtin.max_region_size)}, [TrackingTable.X, TrackingTable.Y], TrackingTable.RegionSize, gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);
        end
    end
    
    % maxarea given the first XY datapoint of the trajectory
    if isfield(filtin, 'min_intensity')
        if filtin.max_region_size < Inf
            logentry(['min_intensity- Removing trackers with average intensities less than ' num2str(filtin.min_intensity) ' pixels^2.']);

            temp = splitapply(@(x,y){filter_min_intensity(x,y,filtin.min_intensity)}, [TrackingTable.X, TrackingTable.Y], TrackingTable.CenterIntensity, gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);
        end
    end
        
    % NOW that all of the trajectory specific DATA REMOVAL type filters are
    % out of the way, remove the NaN position data from the TrackingTable and 
    % put it into another table for later reference. The two tables can
    % always be reconnected later.
    BadData =  isnan(TrackingTable.X);
    
    
    TrackingTableOut = TrackingTable(~BadData,:);
    Trash = TrackingTable(BadData,:);
    
% %     % Now, deal with drift. Does it make sense to do this here? Should this
% %     % be a completely different function?
% %     if isfield(filtin, 'drift_method')
% %         if ~strcmp(filtin.drift_method, 'none')
% %             [data,drift_vector] = filter_subtract_drift(data, filtin.drift_method);
% %             % outputted drift_vector here is in [pixels] regardless of the
% %             % requested output scaling.
% %             filtout.drift_vector = drift_vector;
% %             filtout.drift_vector_units = 'pixels';
% %             if isstruct(drift_vector)
% %                 mydrift = mean(drift_vector.xy);
% %             else
% %                 mydrift = mean(drift_vector);
% %             end
% %             logentry(['drift_method- Removed ' num2str(mydrift*filtin.calib_um) ' um/s from data.']);
% %         end        
% %     end    


%
% Filters data from trackers that have few than minFrames datapoints
% less than minPixelRange in either x OR y.
% from the edge of each tracker in time by tCrop
% from the edge of the field of view by xyCrop
%







% %%%%%%
% FILTER FUNCTIONS BELOW
% %%%%%%

%   'minFrames' is the minimum number of frames required to keep a tracker   
function XYcoords = filter_min_frames(XYcoords, minFrames)

    if size(XYcoords,1) < minFrames
        XYcoords = NaN(size(XYcoords));
    end
    
    return;

    
function XYcoords = filter_tcrop(XYcoords, tCrop)
    

    if size(XYcoords,1) <= tCrop*2
        XYcoords = NaN(size(XYcoords));
    else
        XYcoords(1:tCrop,:) = NaN;
        XYcoords(end-tCrop+1:end,:) = NaN;
    end
       
    return

    
function XYcoords = filter_min_sens(XYcoords, sensitivity, min_sens)    
    
    if min(sensitivity) < min_sens
        XYcoords = NaN(size(XYcoords));
    end
    
return
    

function XYcoords = filter_max_region_size(XYcoords, RegionSize, max_region_size)

    if mean(RegionSize) > max_region_size
        XYcoords = NaN(size(XYcoords));
    end

return


function XYcoords = filter_min_intensity(XYcoords, Intensity, min_intensity)

    if mean(Intensity) < min_intensity
        XYcoords = NaN(size(XYcoords));
    end
    
return;


%Perform xyCrop
% function data = filter_xycrop(data, xycrop)
%     video_tracking_constants;
%     
%     minX = min(data(:,X)); maxX = max(data(:,X));
%     minY = min(data(:,Y)); maxY = max(data(:,Y));
% 
%     xIDXmin = find(data(:,X) < (minX+xycrop)); xIDXmax = find(data(:,X) > (maxX-xycrop));
%     yIDXmin = find(data(:,Y) < (minY+xycrop)); yIDXmax = find(data(:,Y) > (maxY-xycrop));
% 
%     DeleteRowsIDX = unique([xIDXmin; yIDXmin; xIDXmax; yIDXmax]);
% 
%     data(DeleteRowsIDX,:) = [];
% 
%     return;
% 

% 
%     
% function data = filter_dead_zone_around_trackers(data, deadzone, freq_thresh)
% 
%     video_tracking_constants;
% 
%     if nargin < 3 || isempty(freq_thresh)
%         freq_thresh = 0.1;
%     end
%     
%     v = summarize_tracking(data);
%     
%     thresh = deadzone;
%         
%     idlist = v.idlist;
%     framelist = unique(data(:,FRAME));
%     
%     ntrackers = length(idlist);
%     
%     master_list = cell(1,length(framelist));
%     for k = 1 : length(framelist)
%         this_frame_num = framelist(k);
%         
%         idx = find(data(:,FRAME) == this_frame_num);
%        
%         this_frame = data(idx,:);
%  
%         ids = this_frame(:,ID); ids = ids(:)';
%         x = this_frame(:,X); x = x(:);
%         y = this_frame(:,Y); y = y(:);
% 
%         % get square matrices for idlist, x, & y positions
%         ids = repmat(ids, 1, length(ids));
%         x   = repmat(x,   1, length(x));
%         y   = repmat(y,   1, length(y));
% 
%         % to get the distance between pairs transpose and subtract and put
%         % into distance formula
%         dist = sqrt( (x - x').^2 + (y - y').^2 );        
%         distu = triu(dist); 
%         
%         % distances mirror the bottom-left triangle and we don't count the
%         % zero distance between a particle and itself. Populate a nan
%         % matrix & extract the lower triangle.
%         nanmatrix = nan(size(distu));        
%         nanl = tril(nanmatrix);
%         
%         % get the distances matrix we want by adding upper distances to
%         % lower nans.
%         distu = distu + nanl;        
%        
%         % particle pairs whose distances are less than the separation 
%         % distance threshold (supposed to be in pixels).
%         too_close = (distu < thresh);
% 
%         % need a way to identify reference and test tracker IDs 
%         idst = ids'; 
%         refbead   = ids( too_close );
%         testbead  = idst( too_close );
%         too_close_list = [refbead(:) testbead(:) ];
%         sorted = sortrows(too_close_list,1);
%         
%         % Now, attach them to the current frame number
%         this_frame_num = repmat(this_frame_num,size(sorted,1),1);
%         
%         % store everything into a cell array to handle preallocation
%         % 'issue' (also saves a few seconds processing time on large datasets)
%         master_list{1,k} = [this_frame_num sorted];                
%     end
%     
%     % Turn the master_list into an actual 'list'
%     master_list = vertcat(master_list{:});
%     
%     % Now it's time to tabulate how much overlap there is between trackers
%     accumulating_trackers_to_delete = cell(1,length(framelist));
%     for k = 1 : length(framelist)
%         thisbead = master_list( master_list(:,2) == framelist(k), :);
% 
%         if ~isempty(thisbead)            
%             freqdata = tabulate(thisbead(:,3));
%             freq_of_occurence = freqdata(:,2) ./ length(framelist);
% 
%             above_thresh = (freq_of_occurence > freq_thresh);
%             accumulating_trackers_to_delete{1,k} = freqdata(above_thresh,1);
%         end
%     end    
%     
%     accumulating_trackers_to_delete = vertcat(accumulating_trackers_to_delete{:});
%     
%     % reduce the instances to a list of unique IDs to remove
%     trackers_to_delete = unique(accumulating_trackers_to_delete);
%     
%     % remove trackers identified as being too close
%     for k = 1:length(trackers_to_delete)
%         idxd = find(data(:,ID) ~= trackers_to_delete(k));
%         data = data(idxd,:);
%     end
%     
%     logentry(['Deleted ' num2str(length(trackers_to_delete)) ' trackers that failed dead zone filter.']);
%     
%     return;
% 
% 
% function data = filter_dead_zone_simple(data, deadzone)
% 
%     video_tracking_constants;
% 
%     if nargin < 3 || isempty(freq_thresh)
%         freq_thresh = 0.1;
%     end
%     
%     v = summarize_tracking(data);
%     
%     thresh = deadzone;
%         
%     idlist = v.idlist;
%     framelist = unique(data(:,FRAME));
%     
%     ntrackers = length(idlist);
%     
%     master_list = cell(1,length(framelist));
%     newdata = {};
%     
%     for k = 1 : length(framelist)
%         this_frame_num = framelist(k);
%         
%         idx = find(data(:,FRAME) == this_frame_num);
%        
%         this_frame = data(idx,:);
%  
%         ids = this_frame(:,ID); ids = ids(:)';
%         x = this_frame(:,X); x = x(:);
%         y = this_frame(:,Y); y = y(:);
% 
%         % get square matrices for idlist, x, & y positions
%         ids = repmat(ids, length(ids), 1);
%         x   = repmat(x,   1, length(x));
%         y   = repmat(y,   1, length(y));
% 
%         % to get the distance between pairs transpose and subtract and put
%         % into distance formula
%         dist = sqrt( (x - x').^2 + (y - y').^2 );        
%         distu = triu(dist); 
%         
%         % distances mirror the bottom-left triangle and we don't count the
%         % zero distance between a particle and itself. Populate a nan
%         % matrix & extract the lower triangle.
%         nanmatrix = nan(size(distu));        
%         nanl = tril(nanmatrix);
%         
%         % get the distances matrix we want by adding upper distances to
%         % lower nans.
%         distu = distu + nanl;        
%        
%         % particle pairs whose distances are less than the separation 
%         % distance threshold (supposed to be in pixels).
%         too_close = (distu < thresh);
% 
%         % need a way to identify reference and test tracker IDs 
%         idst = ids'; 
%         ids = ids + nanl;
%         idst = idst + nanl;
%         
%         refbead   = idst( too_close ); % earlier tracker to which the test testbead comes too close.
%         testbead  = ids( too_close );
%         beads_to_remove = unique(testbead);
% 
%         % this just deletes the testbead's id from this frame to the end.
%         % You could squeeze more data out of this by giving later points a
%         % new tracker ID number and test for closeness again at a later
%         % frame.
%         for m = 1:length(beads_to_remove)
%             kidx = find(data(:,ID) == beads_to_remove(m) & data(:,FRAME) >= this_frame_num);
%             data(kidx,:) = [];
%         end
%         
%     end
%     
%     
%     logentry(['Deleted trackers that failed simple dead zone filter.']);
%     
%     return;
%     
% 
% 
% 
% 
% 
% function data = filter_pixel_range(mode, data, PixelRange, xyzunits, calib_um)
%     video_tracking_constants;
%     beadlist = unique(data(:,ID));
%     
%     if nargin < 5 || isempty(calib_um)
%         xyzunits = 'pixels';
%         calib_um = 1;
%     end
%     
%     xyzunits = 'pixels';
% 
%     for i = 1:length(beadlist)                  %Loop over all beadIDs.
%         idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
%         numFrames = length(idx);    
% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Remove trackers with too short a range in x OR y
%         xrange = max(data(idx, X)) - min(data(idx, X)); %Calculate xrange
%         yrange = max(data(idx, Y)) - min(data(idx, Y)); %Calculate yrange
%         %Handle unit conversion, if necessary.
%         if(nargin > 3)
%             if strcmp(xyzunits,'m')
%                 calib = calib_um * 1e-6;  % convert calibration from um to meters
%             elseif strcmp(xyzunits,'um')
%                 calib = calib_um;         % define calib as calib_um
%             elseif strcmp(xyzunits,'nm')
%                 calib =  calib_um * 1e3;  % convert calib from um to nm
%             else 
%                 calib = 1;
%             end  
%                 xrange = xrange / calib;
%                 yrange = yrange / calib;
%         end
%         
%         %Delete this bead iff necesary
%         switch mode
%             case 'min'
%                 if(xrange<PixelRange && yrange<PixelRange)   %If this bead has too few datapoints
%                     idx  = find(data(:, ID) ~= beadlist(i)); %Get all data rows for this bead
%                     data = data(idx, :);                     %Recreate data without this bead
% %                 continue                                     %Move on to next bead now
%                 end
%             case 'max'
%                 if(xrange>PixelRange && yrange>PixelRange)   %If this bead has too few datapoints
%                     idx  = find(data(:, ID) ~= beadlist(i)); %Get all data rows for this bead
%                     data = data(idx, :);                     %Recreate data without this bead
% %                 continue                                     %Move on to next bead now
%                 end
%         end                
%     end    
%     
%     return;
% 
%     



    
% % perform "dead spot" crop
% function data = filter_dead_spots(data, dead_spots)
% % each row in 'dead_spots' corresponds to a dead spot with values equal to
% % [top_left_X top_left_Y width height]
% 
%     video_tracking_constants;
%     
%     for k = 1:size(dead_spots,1)
%         Xtl = dead_spots(k, 1);
%         Ytl = dead_spots(k, 2);
%         wid = dead_spots(k, 3);
%         ht  = dead_spots(k, 4);
%         
%         % find those data that exist within our 'dead zone'
%         idx = find(data(:,X) >  Xtl         & ...
%                    data(:,X) < (Xtl + wid)  & ...
%                    data(:,Y) >  Ytl         & ...
%                    data(:,Y) < (Ytl + ht) );
%                
%         % extract out the unique trackerIDs
%         IDs_to_delete = unique( data(idx,ID) );
%         
%         % the response to those trackers here is to delete the entire
%         % tracker.  one could imagine deleting points at and after the time
%         % where the boundary is crossed.
%         if ~isempty(IDs_to_delete)
%             for m = 1:length(IDs_to_delete)
%                 IDidx = find( data(:,ID) == IDs_to_delete(m) );
%                 data(IDidx, :) = [];               
%             end
%         end
%     end
%     
%     return;
% 
% function [data,drift_vector] = filter_subtract_drift(data, drift_method)
%     drift_start_time = [];
%     drift_end_time = [];    
%     [data,drift_vector] = remove_drift(data, drift_start_time, drift_end_time, drift_method);    
% return;
% 
% 
% 
% function [data,num_jerks] = filter_remove_tracker_jerk(data, jerk_limit)
%     video_tracking_constants;
%     
%     if isempty(data) 
%         num_jerks = NaN;
%         return;
%     end
%     tracker_list = unique(data(:,ID));
%     temp = data;
%     for k = 1:length(tracker_list)
%         idx = find(data(:,ID) == tracker_list(k));
%         xy = data(idx, X:Y);    
%         dxdy = diff(xy);
%         
%         jerk_idxX = find(abs(dxdy(:,1)) > jerk_limit);
%         jerk_idxY = find(abs(dxdy(:,2)) > jerk_limit);        
%         jerk_idx = union(jerk_idxX, jerk_idxY);
%         new_xy = xy;
%         new_xy(jerk_idx+1,:) = NaN;
%         
%         for m = 1:length(jerk_idx)
%             pre = new_xy(jerk_idx(m),:);
%             trigger = NaN;
%             count = 1;
%             while isnan(trigger)
%                 if jerk_idx(m)+count > length(new_xy)
%                     count = count-1;
%                     trigger = 0;
%                 else
%                     trigger = sum(new_xy(jerk_idx(m)+count,:));
%                 end
%                 
%                 if isnan(trigger)
%                     count = count + 1;
%                 end
%             end
%             post = new_xy(jerk_idx(m)+count,:);
%             myidx = jerk_idx(m)+1:jerk_idx(m)+count-1; 
%             new_xy(myidx,:) = repmat(mean([pre ; post]),length(myidx),1);
%         end
%         
%         temp(idx,X:Y) = new_xy;
%         
%         data(idx,X:Y) = new_xy;
%         
%         if ~isempty(jerk_idx)
%             figure;
%             subplot(2,1,1)
%                 plot(data(idx,TIME), xy(:,1), 'b', data(idx,TIME), new_xy(:,1), 'r');
%             subplot(2,1,2)
%                 plot(data(idx,TIME), xy(:,2), 'b', data(idx,TIME), new_xy(:,2), 'r');        
%             drawnow;
%         end
% 
%         num_jerks = length(jerk_idx);
%     end
%     
% return;
% 
% 
% function [data,jerk_frames] = filter_remove_stage_jerk(data, stage_jerk_limit)
%     video_tracking_constants;
%     
%     if isempty(data) 
%         jerk_frames = NaN;
%         return;
%     end
%     
%     tracker_list = unique(data(:,ID));
%     
%     jerk_frames = [];
%     
%     for k = 1:length(tracker_list)
%         idx = find(data(:,ID) == tracker_list(k));
% 
%         t = data(idx, TIME);
%         f = data(idx, FRAME);
%         xy = data(idx, X:Y);    
% 
%         dxdy = diff(xy);
%         
%         [max_diff_xy, max_diff_xy_idx] = max(abs(dxdy),[],1);
% %         dbg_output(k,:) = 
%         
%         jerk_idxX = find(abs(dxdy(:,1)) > stage_jerk_limit);
%         jerk_idxY = find(abs(dxdy(:,2)) > stage_jerk_limit);        
%         jerk_idx = union(jerk_idxX, jerk_idxY);
%         
%         jerk_frames_this_tracker = f(jerk_idx);
%         
%         jerk_frames = union(jerk_frames, jerk_frames_this_tracker);
%         
%     end
%     
%     for m = 1:length(jerk_frames)
%         
%         myframe = jerk_frames(m);
%         
%         data1 = data( data(:,FRAME) ==  myframe,   :);
%         data2 = data( data(:,FRAME) ==  myframe+1, :);
%         
%         % which trackers exist in BOTH time points?
%         tlist = intersect(data1(:,ID), data2(:,ID));
%         
%         data1 = remove_uncommon_trackers(data1, tlist);
%         data2 = remove_uncommon_trackers(data2, tlist);
%         
%         xydiff = abs(data1(:, X:Y) - data2(:, X:Y));
%         avg_jerk = mean(xydiff,1);
%         
%         idx = find(data(:,FRAME) > myframe);
%         
%         data(idx,X) = data(idx,X) - avg_jerk(1);
%         data(idx,Y) = data(idx,Y) - avg_jerk(2);
%         
%     end
%     
%     return;
%     
