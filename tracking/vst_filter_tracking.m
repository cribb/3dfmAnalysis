function [TrackingTableOut, Trash] = vst_filter_tracking(TrackingTable, filtin)
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
        filtin.min_trackers    = 0;
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
    
    if (nargin < 1) || isempty(TrackingTable) 
        logentry('No data inputs set. Exiting filter_vst_tracking now.');
        TrackingTableOut = [];
        filtout.drift_vector = [NaN NaN];
        return;
    end
    
% TrackingTable = TrackingTableIn;


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

% File level filters
vars = {'Fid'};
TrackingTable = sortrows(TrackingTable,vars);
[gid, GroupsTable] = findgroups(TrackingTable(:,vars));

% Original number of trajectories
logentry(['Starting with ' num2str(numel(unique(TrackingTable.ID))) ' trackers in the original dataset.']);

if isfield(filtin, 'min_trackers')
    if filtin.min_trackers > 0
        logentry(['min_trackers- Not enough trackers (N < ' num2str(filtin.min_trackers) '). Zeroing this file.']);

        temp = splitapply(@(x,y){filter_min_trackers(x,y,filtin.min_trackers)}, TrackingTable.ID, [TrackingTable.X, TrackingTable.Y], gid);
        temp = cell2mat(temp);
        TrackingTable.X = temp(:,1);
        TrackingTable.Y = temp(:,2);         
    end
end    
    
% Tracker level filters    
vars = {'Fid', 'ID'};
TrackingTable = sortrows(TrackingTable,vars);
[gid, GroupsTable] = findgroups(TrackingTable(:,vars));

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

            
            % We must add the min_frames and tcrop values since we don't
            % technically "delete" (or "move to trash") any points until
            % after filtering. tcrop trims from the beginning and the end
            % of the dataset.
            my_min = filtin.min_frames + 2 * filtin.tcrop + 1;
            temp = splitapply(@(x){filter_min_frames(x,my_min)}, [TrackingTable.X, TrackingTable.Y], gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);
        end
    end

    % Minimum distance the trajectory must have
    if isfield(filtin, 'min_pixels')
        if filtin.min_pixels > 0
            logentry(['min_pixels- Removing trackers with shorter lengths than ' num2str(filtin.min_pixels) ' [pixels].']);

            temp = splitapply(@(xy){filter_min_pixels(xy,filtin.min_pixels)}, [TrackingTable.X, TrackingTable.Y], gid);
            temp = cell2mat(temp);
            TrackingTable.X = temp(:,1);
            TrackingTable.Y = temp(:,2);
        end
    end

    % Maximum distance the trajectory can have
    if isfield(filtin, 'max_pixels')
        if filtin.max_pixels < Inf
            logentry(['max_pixels- Removing trackers with longer lengths than ' num2str(filtin.max_pixels) ' [pixels].']);

            temp = splitapply(@(xy){filter_max_pixels(xy,filtin.max_pixels)}, [TrackingTable.X, TrackingTable.Y], gid);
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
        if filtin.min_intensity < Inf
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
    
    logentry(['Left with ' num2str(numel(unique(TrackingTableOut.ID))) ' trackers in the filtered dataset.']);    
    return
 
% %%%%%%
% FILTER FUNCTIONS BELOW
% %%%%%%

function XYcoordsOut = filter_min_trackers(ID, XYcoordsIn, minTrackers)

    nID = length(unique(ID));
    
    if nID < minTrackers
        XYcoordsOut = NaN(size(XYcoordsIn));
    else
        XYcoordsOut = XYcoordsIn;
    end
    
    return;
    
%   'minFrames' is the minimum number of frames required to keep a tracker   
function XYcoords = filter_min_frames(XYcoords, minFrames)

    if size(XYcoords,1) < minFrames
        XYcoords = NaN(size(XYcoords));
    end
    
    return

function XYcoords = filter_min_pixels(XYcoords, min_pixels)
%     largest_distance = pdist2(XYcoords(:,1), XYcoords(:,2), 'euclidean', 'Largest', 1);
    x = XYcoords(:,1);
    y = XYcoords(:,2);
    
    largest_distance = sqrt( (max(x) - min(x))^2 + (max(y) - min(y))^2 );
    
    if largest_distance < min_pixels
        XYcoords = NaN(size(XYcoords));
    end
return

function XYcoords = filter_max_pixels(XYcoords, max_pixels)
%     largest_distance = pdist2(XYcoords(:,1), XYcoords(:,2), 'euclidean', 'Largest', 1);

    x = XYcoords(:,1);
    y = XYcoords(:,2);
    
    largest_distance = sqrt( (max(x) - min(x))^2 + (max(y) - min(y))^2 );
    
    if largest_distance > max_pixels
        XYcoords = NaN(size(XYcoords));
    end
return


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


