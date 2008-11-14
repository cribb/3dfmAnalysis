function v = load_video_tracking(filemask, frame_rate, xyzunits, calib_um,...
                                  absolute_pos, tstamps, table,...
                                  minFrames, minPixelRange)
% LOAD_VIDEO_TRACKING Loads into memory 3DFM video tracking dataset(s).
%
% 3DFM function  
% Tracking 
% last modified 2008.11.14 (jcribb)
% 
% This function reads in a Video Tracking dataset, saved in the 
% matlab workspace file (*.mat) format and prepares it for most 
% data analysis functions.
% 
% function v = load_video_tracking(filemask, frame_rate, xyzunits, calib_um,...
%                                  absolute_pos, tstamps, table,...
%                                  minFrames, minPixelRange)
%
% where "d" is the outputted data table
%       "filemask" is the .mat filename(s) (i.e. wildcards ok)
%       "frame_rate" (default 120fps) is the frame rate of the captured video sequence
%	    "xyzunits" is either 'nm' 'um' 'm' or 'pixels'
%       "calib_um" is the calibration coefficient to convert pixels to microns
%       "absolute_pos" is either 'relative' or 'absolute'
%       "tstamps" is 'yes' when a timestamps file exists
%       "table" is 'struct' or 'table', denoting the style of the output data
%       "minFrames": tracker length threshold, default value 1 (to kill empty trackers)
%       "minPixelRange": tracker range threshold in x OR y, default value 0
%
% Notes:
% - This function is designed to work under default conditions with
%   only the filename as an input argument.
%

video_tracking_constants;

% handle the argument list
if (nargin < 9 || isempty(minPixelRange));  minPixelRange = 0;         end;
if (nargin < 8 || isempty(minFrames));      minFrames = 1;             end;
if (nargin < 7 || isempty(table));          table = 'struct';          end;
if (nargin < 6 || isempty(tstamps));        tstamps  = 'no';	       end;
if (nargin < 5 || isempty(absolute_pos));   absolute_pos = 'relative'; end;
if (nargin < 4 || isempty(calib_um));       calib_um = 1;              end;
if (nargin < 3 || isempty(xyzunits));       xyzunits  = 'pixels';      end;
if (nargin < 2 || isempty(frame_rate));     frame_rate = 120;          end;

filelist = dir(filemask);
if length(filelist) < 1
    error(['No files found matching ' filemask '.']);
end

for fid = 1:length(filelist)
    
    file = filelist(fid).name;
    
    % what if we want to use the csv file provided by video spot tracker?
    % we have to make a decision here, and we'll base it on the filename
    % extension
    if ~isempty(strfind(file, '.csv')) && isempty(strfind(file, '.mat'))
        % assume csv file is the input and load accordingly
        dd = csvread(file, 1, 0);
    else
        % Load the tracking data after it has been converted to a .mat file    
        dd=load(file);
    end


    if ~isempty(strfind(file, '.csv')) && isempty(strfind(file, '.mat'))
        CSVFRAME = 1;
        CSVID    = 2;
        CSVX     = 3;
        CSVY     = 4;
        CSVZ     = 5;

        data(:,TIME)  = zeros(rows(dd),1);
        data(:,FRAME) = dd(:,CSVFRAME);
        data(:,ID)    = dd(:,CSVID);
        data(:,X)     = dd(:,CSVX);
        data(:,Y)     = dd(:,CSVY);
        data(:,Z)     = dd(:,CSVZ);
        data(:,ROLL)  = zeros(rows(dd),1);
        data(:,PITCH) = zeros(rows(dd),1);
        data(:,YAW)   = zeros(rows(dd),1);

        % no timestamps in this vrpn file format
        tstamps = 'no';
    elseif ~isempty(strfind(file, '.evt.')) && isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        data = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;
    
        % if there are timestamps, and evt_gui was used, then they are already attached
        tstamps = 'done';
        
    elseif isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        data = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;

        % Let's axe the VRPN "time-stamps"... they don't mean anything here
        data(:,2) = zeros(size(data, 1),1);  %fill the second column with zeros
        data = data(:,2:end); %delete the first column

    elseif isfield(dd.tracking, 'videoTrackingSecUsecZeroXYZ')        
        data = dd.tracking.videoTrackingSecUsecZeroXYZ;

        % Let's axe the VRPN "time-stamps"... they don't mean anything here
        data(:,2) = zeros(size(data, 1),1);  
        data = data(:,2:end);
        
        video_tracking_constants; 
        
        % set up variables for easy tracking of table's column headings
        myTIME = 1; myID = 2; myX = 3; myY = 4; myZ = 5; 

        data(:,TIME) = data(:,myTIME);
        data(:,ID)   = data(:,myID);
        data(:,FRAME)= 1:rows(data);
        data(:,X)    = data(:,myX);
        data(:,Y)    = data(:,myY);
        data(:,Z)    = data(:,myZ);
        data(:,ROLL) = zeros(rows(data),1);
        data(:,PITCH) = zeros(rows(data),1);
        data(:,YAW) = zeros(rows(data),1);
         
        % no timestamps in this vrpn file format
        tstamps = 'no';

    elseif isfield(dd.tracking, 'spot2DSecUsecIndexXYZ')
        mydata = dd.tracking.spot2DSecUsecIndexXYZ;

        % Let's axe the VRPN "time-stamps"... they don't mean anything here
        mydata(:,2) = zeros(size(mydata, 1),1);  
        mydata = mydata(:,2:end);

        video_tracking_constants; 
        
        % set up variables for easy tracking of table's column headings
        myTIME = 1; myID = 2; myX = 3; myY = 4; myZ = 5; 

        data(:,TIME) = mydata(:,myTIME);
        data(:,ID)   = mydata(:,myID);
        data(:,FRAME)= zeros(rows(mydata),1);
        data(:,X)    = mydata(:,myX);
        data(:,Y)    = mydata(:,myY);
        data(:,Z)    = mydata(:,myZ);
        data(:,ROLL) = zeros(rows(mydata),1);
        data(:,PITCH) = zeros(rows(mydata),1);
        data(:,YAW) = zeros(rows(mydata),1);
        
        % no timestamps in this vrpn file format
        tstamps = 'no';

    elseif length(dd.tracking) > 1
        data = dd.tracking;
        ch = NaN;
        error(['CONGRATULATIONS! You have stumbled upon an OLD video-tracking VRPN format. ' ...
              '\nYou will have to edit load_video_tracking and include a filter for this format.']);
    else
        error('I do not know how to handle this video VRPN file (weird fieldnames).');
    end
        
    % handle the physical units
    units{X} = xyzunits;  units{Y} = xyzunits;  units{Z} = xyzunits;
	if strcmp(xyzunits,'m')
		data(:,X:Z) = data(:,X:Z) .* calib_um * 1e-6;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'um')
		data(:,X:Z) = data(:,X:Z) .* calib_um;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'nm')
		data(:,X:Z) = data(:,X:Z) .* calib_um * 1e3;  % convert video coords from pixels to nm
    else 
        units{X} = 'pixels';  units{Y} = 'pixels';  units{Z} = 'pixels';
    end

    trackerID = data(:,ID);
    x = data(:,X);
    y = data(:,Y);
    
    % try loading the time stamps if that is requested.
    if strcmp(tstamps,'yes')
        tfile = strrep(file,  '.raw',  '');
        tfile = strrep(tfile, '.vrpn', '');
        tfile = strrep(tfile, '.mat',  '');
        tfile = strrep(tfile, '.evt',  '');
        
        try
            times = load([tfile '.raw.tstamp.txt'], 'ASCII');            
        catch
            tstamps = 'no';                
            logentry('Attempt to load timestamps failed (file not found). Using frame rate to construct timestamps');
        end
    end

    % now do all of the bead specific things
    for k = 0 : max(trackerID)    
                    
        % select rows in table that correspond only to the k-th bead
        idx = find(trackerID == k);
        this_tracker  = data(idx,:);
        
        % handle the case for which a trackerID was used, but no points
        % were retained in the dataset.
        if(length(this_tracker) == 0); 
            continue;
        end;

        % select x&y coords for only the kth bead
        this_x = x(idx);
        this_y = y(idx);

        if(strcmp(absolute_pos,'relative'))            
            % subtract off the initial x and y (1st point becomes the zero)
            this_x = this_x - this_x(1);
            this_y = this_y - this_y(1);
            
            % enter the new locations into the data table
            data(idx,X) = this_x;
            data(idx,Y) = this_y;            
        end
        
        % Handle time.... if we don't have timestamps then we have to assume
        % that we have a constant frame rate.
        if strcmp(tstamps,'yes')
            if size(times, 2) == 2
                times = times(:,1) + times(:,2) / 1e6;
            end
            active_frames = data(idx, FRAME);
            data(idx,TIME) = times(active_frames+1);

            logentry('Successfully loaded and attached time stamps.');

        end
        
        if strcmp(tstamps, 'no')
            if sum(this_tracker(:,FRAME)) > 0
                data(idx,TIME) = data(idx,FRAME) * 1/frame_rate;
            else
                frames = [0 : rows(this_tracker)-1]';
                data(idx,TIME) = frames * 1/frame_rate;
            end                
        end    


    end

    
    % we don't want to repeat any beadIDs as we concatenate the
    % datasets from each filename in the stack.  To avoid this, we add
    % the max(beadID) to the newdata's beadID and then we concatenate.
    if exist('glommed_d')
        beadmax = max(glommed_d(:,ID));
        data(:,ID) = data(:,ID) + beadmax + 1;            
        glommed_d = [glommed_d ; data];
    else
        glommed_d = data;
    end    
end

data = glommed_d;

%Prune data table of trackers that are too short, or don't move enough
data = prune_data_table(data, minFrames, minPixelRange, xyzunits, calib_um);

% now, settle our outputs, and move on....
switch table
    case 'table'
        v = data;
    otherwise
        v.id= data(:,ID);    
        v.t = data(:,TIME);
        v.frame = data(:,FRAME);
        v.x = data(:,X);
        v.y = data(:,Y);
        v.z = data(:,Z);		
        if exist('ROLL');    v.roll = data(:,ROLL);    end;
        if exist('PITCH');   v.pitch= data(:,PITCH);   end;
        if exist('YAW');     v.yaw  = data(:,YAW);     end;                    
end

function data = prune_data_table(data, minFrames, minPixelRange, xyzunits, calib_um)

%Removes all data from trackers that have few than minFrames datapoints
%less than minPixelRange in either x OR y.
%
%USAGE:
%   function data = prune_data_table(data, minFrames, minPixelRange, units, calib_um)
%
%   where:
%   'data' is the video table
%   'minFrames' is the minimum number of frames required to keep a tracker
%   'minPixelRange' is the minimum range a tracker must move in either x OR Y if it is to be kept
%   'units' is either 'pixel' or 'um', reffering to the position columns in 'data'
%   'calib_um' is the microns per pixel calibration of the image.
%
%   Note that x and y ranges are converted to pixels if and only if 'units'
%   is 'um'. In this case, then 'calib_um' must be supplied.

video_tracking_constants;

beadlist = unique(data(:,ID));
for i = 1:length(beadlist)                  %Loop over all beadIDs.
    % Remove trackers that are too short in time
    idx = find(data(:, ID) == beadlist(i)); %Get all data rows for this bead
    if(length(idx) < minFrames)             %If this bead has too few datapoints
        idx = find(data(:, ID) ~= beadlist(i)); %Get the rest of the data
        data = data(idx, :);                    %Recreate data without this bead
        continue                                %Move on to next bead now
    end

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
    if(xrange<minPixelRange && yrange<minPixelRange) %If this bead has too few datapoints
        idx  = find(data(:, ID) ~= beadlist(i));     %Get all data rows for this bead
        data = data(idx, :);                         %Recreate data without this bead
       continue                                     %Move on to next bead now
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


% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'load_video_tracking: '];
     
     fprintf('%s%s\n', headertext, txt);
