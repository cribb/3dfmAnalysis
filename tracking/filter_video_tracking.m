function [outs, filtout] = filter_video_tracking(data, filt)
% FILTER_VIDEO_TRACKING    Filters video tracking datasets
% CISMM function
% video
% 
% This function reads in a Video Tracking dataset, saved in the 
% matlab workspace file (*.mat) format and filters it using filter types
% defined below.
% 
% function filter_video_tracking(data, filt)
%
% where 
%       "data" 
%       "filt"
%	    "min_frames" 
%       "min_pixels"
%       "max_pixels" 
%       "tcrop" 
%       "xycrop" 
%       "minFrames"
%       "tCrop" 
%       "xyCrop" 
%       "jerk_limit"
%       "min_intensity"
%
% Notes:
% - This function is designed to work under default conditions with
%   only the filename as an input argument.
%
%Filters data from trackers that have few than minFrames datapoints
%less than minPixelRange in either x OR y.
%from the edge of each tracker in time by tCrop
%from the edge of the field of view by xyCrop
%
%USAGE:
%   function data = prune_data_table(data, minFrames, minPixelRange, units, calib_um, tCrop, xyCrop)
%
%   where:
%   'data' is the video table
%   'min_PixelRange' is the minimum range a tracker must move in either x OR Y if it is to be kept
%   'units' is either 'pixel' or 'um', refering to the position columns in 'data'
%   'calib_um' is the microns per pixel calibration of the image.
%
%   Note that x and y ranges are converted to pixels if and only if 'units'
%   is 'um'. In this case, then 'calib_um' must be supplied.
   
    video_tracking_constants;

    %  Handle inputs
    if (nargin < 2) || isempty(filt)
        filt.min_frames      = 0;
        filt.min_pixels      = 0;
        filt.max_pixels      = Inf;
        filt.max_region_size = Inf;
        filt.min_sens        = 0;
        filt.tcrop           = 0;
        filt.xycrop          = 0;
        filt.xyzunits        = 'pixels';
        filt.calib_um        = 1;
        filt.drift_method    = 'none';
        filt.dead_spots      = [];
        filt.jerk_limit      = [];
        filt.min_intensity   = 0;
        filt.deadzone        = 0; % deadzone around trackers [pixels]
        filt.overlapthresh  = 0;
    end

    filtout = filt;
    
    if (nargin < 1) || isempty(data); 
        logentry('No data inputs set. Exiting filter_video_tracking now.');
        outs = [];
        filtout.drift_vector = [NaN NaN];
        return;
    end

    % convert everything to pixel units
    if isempty(data)
        logentry('Saving empty dataset.');
        data = ones(0,10);    
    elseif strcmp(filt.xyzunits,'m')
        data(:,X:Z) = data(:,X:Z) ./ filt.calib_um * 1e6;  % convert video coords from pixels to meters
    elseif strcmp(filt.xyzunits,'um')
        data(:,X:Z) = data(:,X:Z) ./ filt.calib_um;  % convert video coords from pixels to meters
    elseif strcmp(filt.xyzunits,'nm')
        data(:,X:Z) = data(:,X:Z) ./ filt.calib_um * 1e-3;  % convert video coords from pixels to nm
    elseif strcmp(filt.xyzunits, 'pixels')
        % do nothing
    else
        units{X} = 'pixels';  units{Y} = 'pixels';  units{Z} = 'pixels';
    end


    %  Handle filters    
    if isfield(filt, 'tcrop')
        if filt.tcrop > 0
            logentry(['tcrop- Removing first and last ' num2str(filt.tcrop) ' time points from each trajectory.']);
            data = filter_tcrop(data, filt.tcrop);    
        end
    end
    
    if isfield(filt, 'deadzone')
        if filt.deadzone > 0 && filt.overlapthresh > 0
            logentry(['deadzone- Removing trackers that get closer than ' num2str(filt.deadzone) ' pixels for more than ' num2str(ceil(filt.overlapthresh*100)) '% of their trajectory.']);
            data = filter_dead_zone_around_trackers(data, filt.deadzone, filt.overlapthresh);
        end
    end
    
    
    if isfield(filt, 'deadzone')
        if filt.deadzone > 0
            logentry(['deadzone-simple- Removing trackers that get closer than ' num2str(filt.deadzone) ' pixels for more than ' num2str(ceil(filt.overlapthresh*100)) '% of their trajectory.']);
            data = filter_dead_zone_simple(data, filt.deadzone);
        end            
    end
    
    % 'minframes' the minimum number of frames required to keep a tracker
    if isfield(filt, 'min_frames')
        if filt.min_frames > 0
            logentry(['min_frames- Removing trackers existing for less than ' num2str(filt.min_frames) ' frames.']);
            data = filter_min_frames(data, filt.min_frames);
        end
    end
    
    if isfield(filt, 'min_intensity')
        if filt.min_intensity>0
            logentry(['min_intensity- Removing trackers existing with less than ' num2str(filt.min_intensity) ' intensity.']);
            data=filter_min_intensity(data,filt.min_intensity);
        end
    end
    
    
    % Minimum sensitivity given the first XY datapoint of the trajectory
    if isfield(filt, 'min_sens')
        if filt.min_sens > 0
            logentry(['min_sens- Removing trackers existing with sensitivities (image-SNR) lower than ' num2str(filt.min_frames) '.']);
            data = filter_min_sens(data, filt.min_sens);
        end
    end
    
    
    % maxarea given the first XY datapoint of the trajectory
    if isfield(filt, 'max_region_size')
        if filt.max_region_size < Inf
            logentry(['max_region_size- Removing trackers with region sizes (tracker area) larger than ' num2str(filt.max_region_size) ' pixels^2.']);
            data = filter_max_region_size(data, filt.max_region_size);
        end
    end
    
    if isfield(filt, 'min_pixels')
        if filt.min_pixels > 0
            logentry(['min_pixels- Removing trackers with extents smaller than ' num2str(filt.min_pixels) ' pixels.']);
            % going to assume pixels
            data = filter_pixel_range('min', data, filt.min_pixels);
        end
    end

    if isfield(filt, 'max_pixels')
        if filt.max_pixels < Inf
            logentry(['max_pixels- Removing trackers with extents larger than ' num2str(filt.max_pixels) ' pixels.']);
            % going to assume pixels
            data = filter_pixel_range('max', data, filt.max_pixels);
        end
    end
    
    if isfield(filt, 'min_visc') && isfield(filt, 'bead_radius')
        if filt.min_visc > 0
            logentry(['min_visc- Removing trackers with viscosities smaller than ' num2str(filt.min_pixels) ' [Pa s].']);
            % assuming pixels
            data = filter_viscosity_range('min', data, filt.min_visc, filt.bead_radius, filt.xyzunits, filt.calib_um);
        end
    end
    
    if isfield(filt, 'max_visc') && isfield(filt, 'bead_radius')
        if filt.max_visc > 0
            logentry(['max_visc- Removing trackers with viscosities larger than ' num2str(filt.min_pixels) ' [Pa s].']);
            % assuming pixels
            data = filter_viscosity_range('max', data, filt.max_visc, filt.bead_radius, filt.xyzunits, filt.calib_um);
        end
    end
    
    if isfield(filt, 'xycrop')
        if filt.xycrop > 0
            logentry(['xycrop- Removing trackers along outer ' num2str(filt.xycrop) ' pixels in the frame.']);
            data = filter_xycrop(data, filt.xycrop);
        end
    end

%     if isfield(filt, 'max_area')
%         if filt.max_area < Inf
%             data = filter_max_area(data, filt.max_area);
%         end
%     end
    
    if isfield(filt, 'dead_spots')
        if ~isempty(filt.dead_spots);
            logentry(['dead_spots- Removing trackers from camera deadspots.']);
            data = filter_dead_spots(data, filt.dead_spots);
        end
    end
        
    if isfield(filt, 'drift_method')
        if ~strcmp(filt.drift_method, 'none')
            [data,drift_vector] = filter_subtract_drift(data, filt.drift_method);
            filtout.drift_vector = drift_vector;
            if isstruct(drift_vector)
                mydrift = mean(drift_vector.xy);
            else
                mydrift = mean(drift_vector);
            end
            logentry(['drift_method- Removed ' num2str(mydrift*filt.calib_um) ' um/s from data.']);
        end        
    end    

    if isfield(filt, 'jerk_limit')
        if ~isempty(filt.jerk_limit) && filt.jerk_limit < inf
            [data,num_jerks] = filter_remove_tracker_jerk(data, filt.jerk_limit);
            filtout.num_jerks = num_jerks;
            logentry(['Large, jerky displacements (larger than ' num2str(filt.jerk_limit) ') removed.']);
        end
    end

    if isfield(filt, 'stage_jerk_limit')
        if ~isempty(filt.stage_jerk_limit) && filt.stage_jerk_limit < inf
            [data,num_stage_jerks] = filter_remove_stage_jerk(data, filt.stage_jerk_limit);
            filtout.num_jerks = num_stage_jerks;
            logentry(['Large, jerky displacements in stage (larger than ' num2str(filt.stage_jerk_limit) ') removed.']);
        end
    end
    % Relabel trackers to have consecutive IDs
    beadlist = unique(data(:,ID));   
    if length(beadlist) == max(beadlist)+1
    %     logentry('No empty trackers, so no need to redefine tracker IDs.');
    else
        logentry('Removing empty trackers, tracker IDs are redefined.');
        for k = 1:length(beadlist)
            idx = find(data(:,ID) == beadlist(k));
            data(idx,ID) = k-1;
        end
    end

    % convert everything back to original units
    if isempty(data)
        logentry('Saving empty dataset.');
        data = ones(0,10);    
    elseif strcmp(filt.xyzunits,'m')
        data(:,X:Z) = data(:,X:Z) .* filt.calib_um * 1e-6;  % convert video coords from pixels to meters
    elseif strcmp(filt.xyzunits,'um')
        data(:,X:Z) = data(:,X:Z) .* filt.calib_um;  % convert video coords from pixels to meters
    elseif strcmp(filt.xyzunits,'nm')
        data(:,X:Z) = data(:,X:Z) .* filt.calib_um * 1e3;  % convert video coords from pixels to nm
    elseif strcmp(filt.xyzunits, 'pixels')
        % do nothing
    else
        units{X} = 'pixels';  units{Y} = 'pixels';  units{Z} = 'pixels';
    end
    
    outs = data;

return;




% %%%%%%
% FILTER FUNCTIONS BELOW
% %%%%%%

   
function data = filter_min_frames(data, minFrames)
%   'minFrames' is the minimum number of frames required to keep a tracker

    video_tracking_constants;
    beadlist = unique(data(:,ID));

    for i = 1:length(beadlist)                  %Loop over all beadIDs.
        idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
        numFrames = length(idx);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        % Remove trackers that are too short in time
        if(numFrames < minFrames)             %If this bead has too few datapoints
            idx = find(data(:, ID) ~= beadlist(i)); %Get the rest of the data
            data = data(idx, :);                    %Recreate data without this bead
            continue                                %Move on to next bead now
        end
    end
    
    return;

    
function data = filter_dead_zone_around_trackers(data, deadzone, freq_thresh)

    video_tracking_constants;

    if nargin < 3 || isempty(freq_thresh)
        freq_thresh = 0.1;
    end
    
    v = summarize_tracking(data);
    
    thresh = deadzone;
        
    idlist = v.idlist;
    framelist = unique(data(:,FRAME));
    
    ntrackers = length(idlist);
    
    master_list = cell(1,length(framelist));
    for k = 1 : length(framelist)
        this_frame_num = framelist(k);
        
        idx = find(data(:,FRAME) == this_frame_num);
       
        this_frame = data(idx,:);
 
        ids = this_frame(:,ID); ids = ids(:)';
        x = this_frame(:,X); x = x(:);
        y = this_frame(:,Y); y = y(:);

        % get square matrices for idlist, x, & y positions
        ids = repmat(ids, 1, length(ids));
        x   = repmat(x,   1, length(x));
        y   = repmat(y,   1, length(y));

        % to get the distance between pairs transpose and subtract and put
        % into distance formula
        dist = sqrt( (x - x').^2 + (y - y').^2 );        
        distu = triu(dist); 
        
        % distances mirror the bottom-left triangle and we don't count the
        % zero distance between a particle and itself. Populate a nan
        % matrix & extract the lower triangle.
        nanmatrix = nan(size(distu));        
        nanl = tril(nanmatrix);
        
        % get the distances matrix we want by adding upper distances to
        % lower nans.
        distu = distu + nanl;        
       
        % particle pairs whose distances are less than the separation 
        % distance threshold (supposed to be in pixels).
        too_close = (distu < thresh);

        % need a way to identify reference and test tracker IDs 
        idst = ids'; 
        refbead   = ids( too_close );
        testbead  = idst( too_close );
        too_close_list = [refbead(:) testbead(:) ];
        sorted = sortrows(too_close_list,1);
        
        % Now, attach them to the current frame number
        this_frame_num = repmat(this_frame_num,size(sorted,1),1);
        
        % store everything into a cell array to handle preallocation
        % 'issue' (also saves a few seconds processing time on large datasets)
        master_list{1,k} = [this_frame_num sorted];                
    end
    
    % Turn the master_list into an actual 'list'
    master_list = vertcat(master_list{:});
    
    % Now it's time to tabulate how much overlap there is between trackers
    accumulating_trackers_to_delete = cell(1,length(framelist));
    for k = 1 : length(framelist)
        thisbead = master_list( master_list(:,2) == framelist(k), :);

        if ~isempty(thisbead)            
            freqdata = tabulate(thisbead(:,3));
            freq_of_occurence = freqdata(:,2) ./ length(framelist);

            above_thresh = (freq_of_occurence > freq_thresh);
            accumulating_trackers_to_delete{1,k} = freqdata(above_thresh,1);
        end
    end    
    
    accumulating_trackers_to_delete = vertcat(accumulating_trackers_to_delete{:});
    
    % reduce the instances to a list of unique IDs to remove
    trackers_to_delete = unique(accumulating_trackers_to_delete);
    
    % remove trackers identified as being too close
    for k = 1:length(trackers_to_delete)
        idxd = find(data(:,ID) ~= trackers_to_delete(k));
        data = data(idxd,:);
    end
    
    logentry(['Deleted ' num2str(length(trackers_to_delete)) ' trackers that failed dead zone filter.']);
    
    return;


function data = filter_dead_zone_simple(data, deadzone)

    video_tracking_constants;

    if nargin < 3 || isempty(freq_thresh)
        freq_thresh = 0.1;
    end
    
    v = summarize_tracking(data);
    
    thresh = deadzone;
        
    idlist = v.idlist;
    framelist = unique(data(:,FRAME));
    
    ntrackers = length(idlist);
    
    master_list = cell(1,length(framelist));
    newdata = {};
    
    for k = 1 : length(framelist)
        this_frame_num = framelist(k);
        
        idx = find(data(:,FRAME) == this_frame_num);
       
        this_frame = data(idx,:);
 
        ids = this_frame(:,ID); ids = ids(:)';
        x = this_frame(:,X); x = x(:);
        y = this_frame(:,Y); y = y(:);

        % get square matrices for idlist, x, & y positions
        ids = repmat(ids, length(ids), 1);
        x   = repmat(x,   1, length(x));
        y   = repmat(y,   1, length(y));

        % to get the distance between pairs transpose and subtract and put
        % into distance formula
        dist = sqrt( (x - x').^2 + (y - y').^2 );        
        distu = triu(dist); 
        
        % distances mirror the bottom-left triangle and we don't count the
        % zero distance between a particle and itself. Populate a nan
        % matrix & extract the lower triangle.
        nanmatrix = nan(size(distu));        
        nanl = tril(nanmatrix);
        
        % get the distances matrix we want by adding upper distances to
        % lower nans.
        distu = distu + nanl;        
       
        % particle pairs whose distances are less than the separation 
        % distance threshold (supposed to be in pixels).
        too_close = (distu < thresh);

        % need a way to identify reference and test tracker IDs 
        idst = ids'; 
        refbead   = idst( too_close );
        testbead  = ids( too_close );
%         too_close_list = [refbead(:) testbead(:) ];
%         sorted = sortrows(too_close_list,1);
        beads_to_remove = unique(testbead);
        ids = unique(ids);
        beads_to_keep = setdiff(ids, beads_to_remove);
        
        new_frame = {};
        for m = 1:length(beads_to_keep)
            kidx = find(this_frame(:,ID) == beads_to_keep(m));
            new_frame{m} = this_frame(kidx,:);
        end
        
        new_data{k} = vertcat(new_frame{:});        
        
    end
    
    new_data = vertcat(new_data{:});
    
    data = new_data;
    
    logentry(['Deleted trackers that failed simple dead zone filter.']);
    
    return;
    

function data = filter_max_region_size(data, max_region_size)
    video_tracking_constants;
    beadlist = unique(data(:,ID));

    for i = 1:length(beadlist)                  %Loop over all beadIDs.
        idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
        numFrames = length(idx);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        % Remove trackers that have too much area
        if(data(idx(1),AREA) > max_region_size)            %If this bead has too much area
            idx = (data(:, ID) ~= beadlist(i));     %Get the rest of the data
            data = data(idx, :);                    %Recreate data without this bead
            continue                                %Move on to next bead now
        end
    end
return;


function data = filter_min_sens(data, min_sens)
    video_tracking_constants;
    
    beadlist = unique(data(:,ID));
    
    lowsens_data = ( data(:, SENS) < min_sens );
    
    ids_to_remove = unique( data(lowsens_data,ID) );
    
    if isempty(ids_to_remove)
        return;
    end
    
    midx = zeros(size(data,1),1);
    for k = 1:length(ids_to_remove)
        idx = ( data(:,ID) == ids_to_remove(k) );
        midx = or(midx, idx);
    end
    
    data(midx,:) = [];
    
return;

function data = filter_min_intensity(data, min_intensity)
    video_tracking_constants;
    
    beadlist = unique(data(:,ID));
    
    lowintens_data = ( data(:, CENTINTS) < min_intensity );
    
    ids_to_remove = unique( data(lowintens_data,ID) );
    
    if isempty(ids_to_remove)
        return;
    end
    
    midx = zeros(size(data,1),1);
    for k = 1:length(ids_to_remove)
        idx = ( data(:,ID) == ids_to_remove(k) );
        midx = or(midx, idx);
    end
    
    data(midx,:) = [];
    
return;


function data = filter_pixel_range(mode, data, PixelRange, xyzunits, calib_um)
    video_tracking_constants;
    beadlist = unique(data(:,ID));
    
    if nargin < 5 || isempty(calib_um)
        xyzunits = 'pixels';
        calib_um = 1;
    end
    
    xyzunits = 'pixels';

    for i = 1:length(beadlist)                  %Loop over all beadIDs.
        idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
        numFrames = length(idx);    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Remove trackers with too short a range in x OR y
        xrange = max(data(idx, X)) - min(data(idx, X)); %Calculate xrange
        yrange = max(data(idx, Y)) - min(data(idx, Y)); %Calculate yrange
        %Handle unit conversion, if necessary.
        if(nargin > 3)
            if strcmp(xyzunits,'m')
                calib = calib_um * 1e-6;  % convert calibration from um to meters
            elseif strcmp(xyzunits,'um')
                calib = calib_um;         % define calib as calib_um
            elseif strcmp(xyzunits,'nm')
                calib =  calib_um * 1e3;  % convert calib from um to nm
            else 
                calib = 1;
            end  
                xrange = xrange / calib;
                yrange = yrange / calib;
        end
        
        %Delete this bead iff necesary
        switch mode
            case 'min'
                if(xrange<PixelRange && yrange<PixelRange)   %If this bead has too few datapoints
                    idx  = find(data(:, ID) ~= beadlist(i)); %Get all data rows for this bead
                    data = data(idx, :);                     %Recreate data without this bead
%                 continue                                     %Move on to next bead now
                end
            case 'max'
                if(xrange>PixelRange && yrange>PixelRange)   %If this bead has too few datapoints
                    idx  = find(data(:, ID) ~= beadlist(i)); %Get all data rows for this bead
                    data = data(idx, :);                     %Recreate data without this bead
%                 continue                                     %Move on to next bead now
                end
        end                
    end    
    
    return;

    
function data = filter_viscosity_range(mode, data, ViscRange, bead_radius, xyzunits, calib_um)
    video_tracking_constants;
    beadlist = unique(data(:,ID));
    
    if nargin < 6 || isempty(calib_um)
        xyzunits = 'pixels';
        calib_um = 1;
    end
    


    
    for i = 1:length(beadlist)                  %Loop over all beadIDs.
        idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
        numFrames = length(idx);    

        mydata = data(idx,:);
        
        if isempty(mydata)
            continue;
        end
                
        longest_frame = max(mydata(:,FRAME)) - min(mydata(:,FRAME));
        shortest_frame = min(diff(mydata(:,FRAME)));
        
        windows = [shortest_frame floor(longest_frame/2)];
        windows = windows(:);
        time_scales = windows .* mean(diff(mydata(:,TIME)));
        
        % 2D MSD in pixels
        [tau mymsd_px] = msd(mydata(:,TIME), mydata(:,X:Y), windows);
        mymsd_px = mymsd_px(:);
        
        kb = 1.3806e-23;
        T = 298;
        
        % Calculate range limits for bead diffusing in 2D
        Rrange_px = sqrt((2*kb*T)/(3*pi*bead_radius*ViscRange) .* time_scales) ./ (calib_um*1e-6);
                        
        %Delete this bead iff necesary
        switch mode
            case 'max' % delete any tracker that exceeds max visc threshold
                % large msd means small viscosity
                if(mymsd_px < Rrange_px)
                    idx  = find(data(:, ID) ~= beadlist(i)); %Get all data rows for this bead
                    data = data(idx, :);                     %Recreate data without this bead
                    logentry('deleted tracker with TOO HIGH viscosity.');
                end
            case 'min' % delete any tracker that has a lower viscosity than min visc threshold
                if(mymsd_px > Rrange_px)
                    idx  = find(data(:, ID) ~= beadlist(i)); %Get all data rows for this bead
                    data = data(idx, :);                     %Recreate data without this bead
                    logentry('deleted tracker with TOO LOW viscosity.');
                end
        end                
    end    
    
    return;


function data = filter_tcrop(data, tCrop)
    video_tracking_constants;    
    beadlist = unique(data(:,ID));
    
    for i = 1:length(beadlist)                  %Loop over all beadIDs.
        idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
        numFrames = length(idx);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Remove the frames before and after tCrop
        if(numFrames <= 2*tCrop)
            data(idx,:) = [];
            continue
        elseif(tCrop >= 1)
            firstFrames = 1:tCrop;
            lastFrames  = ceil(1+numFrames-tCrop):numFrames;
            data(idx([firstFrames lastFrames]),:) = [];         %Delete these rows
            % Update rows index
            idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
            numFrames = length(idx);
        end
    end
    
    return;


%Perform xyCrop
function data = filter_xycrop(data, xycrop)
    video_tracking_constants;
    
    minX = min(data(:,X)); maxX = max(data(:,X));
    minY = min(data(:,Y)); maxY = max(data(:,Y));

    xIDXmin = find(data(:,X) < (minX+xycrop)); xIDXmax = find(data(:,X) > (maxX-xycrop));
    yIDXmin = find(data(:,Y) < (minY+xycrop)); yIDXmax = find(data(:,Y) > (maxY-xycrop));

    DeleteRowsIDX = unique([xIDXmin; yIDXmin; xIDXmax; yIDXmax]);

    data(DeleteRowsIDX,:) = [];

    return;

% % % % %Perform xyCrop
% % % % function data = filter_max_region_size(data, max_region_size)
% % % % %   'max_area' is the maximum allowable pixel area (signal) for a tracker 
% % % % 
% % % %     video_tracking_constants;
% % % %     beadlist = unique(data(:,ID));
% % % % 
% % % %     for i = 1:length(beadlist)                  %Loop over all beadIDs.
% % % %         idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
% % % % 
% % % %         
% % % %         numFrames = length(idx);
% % % % 
% % % %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% % % %         % Remove trackers that are too short in time
% % % %         if(numFrames < minFrames)             %If this bead has too few datapoints
% % % %             idx = find(data(:, ID) ~= beadlist(i)); %Get the rest of the data
% % % %             data = data(idx, :);                    %Recreate data without this bead
% % % %             continue                                %Move on to next bead now
% % % %         end
% % % %     end
    
    return;

    
% perform "dead spot" crop
function data = filter_dead_spots(data, dead_spots)
% each row in 'dead_spots' corresponds to a dead spot with values equal to
% [top_left_X top_left_Y width height]

    video_tracking_constants;
    
    for k = 1:size(dead_spots,1)
        Xtl = dead_spots(k, 1);
        Ytl = dead_spots(k, 2);
        wid = dead_spots(k, 3);
        ht  = dead_spots(k, 4);
        
        % find those data that exist within our 'dead zone'
        idx = find(data(:,X) >  Xtl         & ...
                   data(:,X) < (Xtl + wid)  & ...
                   data(:,Y) >  Ytl         & ...
                   data(:,Y) < (Ytl + ht) );
               
        % extract out the unique trackerIDs
        IDs_to_delete = unique( data(idx,ID) );
        
        % the response to those trackers here is to delete the entire
        % tracker.  one could imagine deleting points at and after the time
        % where the boundary is crossed.
        if ~isempty(IDs_to_delete)
            for m = 1:length(IDs_to_delete)
                IDidx = find( data(:,ID) == IDs_to_delete(m) );
                data(IDidx, :) = [];               
            end
        end
    end
    
    return;

function [data,drift_vector] = filter_subtract_drift(data, drift_method)
    drift_start_time = [];
    drift_end_time = [];    
    [data,drift_vector] = remove_drift(data, drift_start_time, drift_end_time, drift_method);    
return;



function [data,num_jerks] = filter_remove_tracker_jerk(data, jerk_limit)
    video_tracking_constants;
    
    if isempty(data) 
        num_jerks = NaN;
        return;
    end
    tracker_list = unique(data(:,ID));
    temp = data;
    for k = 1:length(tracker_list)
        idx = find(data(:,ID) == tracker_list(k));
        xy = data(idx, X:Y);    
        dxdy = diff(xy);
        
        jerk_idxX = find(abs(dxdy(:,1)) > jerk_limit);
        jerk_idxY = find(abs(dxdy(:,2)) > jerk_limit);        
        jerk_idx = union(jerk_idxX, jerk_idxY);
        new_xy = xy;
        new_xy(jerk_idx+1,:) = NaN;
        
        for m = 1:length(jerk_idx)
            pre = new_xy(jerk_idx(m),:);
            trigger = NaN;
            count = 1;
            while isnan(trigger)
                if jerk_idx(m)+count > length(new_xy)
                    count = count-1;
                    trigger = 0;
                else
                    trigger = sum(new_xy(jerk_idx(m)+count,:));
                end
                
                if isnan(trigger)
                    count = count + 1;
                end
            end
            post = new_xy(jerk_idx(m)+count,:);
            myidx = jerk_idx(m)+1:jerk_idx(m)+count-1; 
            new_xy(myidx,:) = repmat(mean([pre ; post]),length(myidx),1);
        end
        
        temp(idx,X:Y) = new_xy;
        
        data(idx,X:Y) = new_xy;
        
        if ~isempty(jerk_idx)
            figure;
            subplot(2,1,1)
                plot(data(idx,TIME), xy(:,1), 'b', data(idx,TIME), new_xy(:,1), 'r');
            subplot(2,1,2)
                plot(data(idx,TIME), xy(:,2), 'b', data(idx,TIME), new_xy(:,2), 'r');        
            drawnow;
        end

        num_jerks = length(jerk_idx);
    end
    
return;


function [data,jerk_frames] = filter_remove_stage_jerk(data, stage_jerk_limit)
    video_tracking_constants;
    
    if isempty(data) 
        jerk_frames = NaN;
        return;
    end
    
    tracker_list = unique(data(:,ID));
    
    jerk_frames = [];
    
    for k = 1:length(tracker_list)
        idx = find(data(:,ID) == tracker_list(k));

        t = data(idx, TIME);
        f = data(idx, FRAME);
        xy = data(idx, X:Y);    

        dxdy = diff(xy);
        
        [max_diff_xy, max_diff_xy_idx] = max(abs(dxdy),[],1);
%         dbg_output(k,:) = 
        
        jerk_idxX = find(abs(dxdy(:,1)) > stage_jerk_limit);
        jerk_idxY = find(abs(dxdy(:,2)) > stage_jerk_limit);        
        jerk_idx = union(jerk_idxX, jerk_idxY);
        
        jerk_frames_this_tracker = f(jerk_idx);
        
        jerk_frames = union(jerk_frames, jerk_frames_this_tracker);
        
    end
    
    for m = 1:length(jerk_frames)
        
        myframe = jerk_frames(m);
        
        data1 = data( data(:,FRAME) ==  myframe,   :);
        data2 = data( data(:,FRAME) ==  myframe+1, :);
        
        % which trackers exist in BOTH time points?
        tlist = intersect(data1(:,ID), data2(:,ID));
        
        data1 = remove_uncommon_trackers(data1, tlist);
        data2 = remove_uncommon_trackers(data2, tlist);
        
        xydiff = abs(data1(:, X:Y) - data2(:, X:Y));
        avg_jerk = mean(xydiff,1);
        
        idx = find(data(:,FRAME) > myframe);
        
        data(idx,X) = data(idx,X) - avg_jerk(1);
        data(idx,Y) = data(idx,Y) - avg_jerk(2);
        
    end
    
    return;
    
function data = remove_uncommon_trackers(data, master_list)
    video_tracking_constants;

    C = setdiff(data(:,ID), master_list);

    if ~isempty(C)
        for n = 1:length(C)
            idx = find(data1(:,ID == C(n)));
            data(idx,:) = [];
        end
    end

    return;
