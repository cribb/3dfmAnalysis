function [v, calout] = load_video_tracking(filemask, frame_rate, xyzunits, calib_um,...
                                           absolute_pos, tstamps, table)
% LOAD_VIDEO_TRACKING Loads 3DFM video tracking dataset(s) into memory.
%
% 3DFM function  
% Tracking 
% 
% This function reads in a Video Tracking dataset, saved in either the
% matlab workspace file (*.mat) format or as a CSV file provided by 
% video_spot_tracker and prepares it for most data analysis functions.
% 
% function [v, calout] = load_video_tracking(filemask, frame_rate, xyzunits, calib_um,...
%                                            absolute_pos, tstamps, table)
%  
% where "v" is the outputted data table
%       "calout" is the outputted calibration factor
%       "filemask" is the .mat filename(s) (i.e. wildcards ok)
%       "frame_rate" (default 120fps) is the frame rate of the captured video sequence
%	    "xyzunits" is either 'nm' 'um' 'm' or 'pixels'
%       "calib_um" is the calibration coefficient to convert pixels to microns
%       "absolute_pos" is either 'relative' or 'absolute'
%       "tstamps" is 'yes' when a timestamps file exists
%       "table" is 'struct' or 'table', denoting the style of the output data
%       
%
% Notes:
% - This function is designed to work under default conditions with
%   only the filename as an input argument.
%

video_tracking_constants;

% handle the argument list
if (nargin > 7); error('use filter_video_tracking to filter datasets!'); end;
if (nargin < 7 || isempty(table));          table = 'struct';          end;
if (nargin < 6 || isempty(tstamps));        tstamps  = 'no';	       end;
if (nargin < 5 || isempty(absolute_pos));   absolute_pos = 'relative'; end;
if (nargin < 4 || isempty(calib_um));       calib_um = 1;              end;
if (nargin < 3 || isempty(xyzunits));       xyzunits  = 'pixels';      end;
if (nargin < 2 || isempty(frame_rate) || frame_rate == 0); frame_rate = 120; end;

% deal with different ways to list files
if isstruct(filemask)
    filelist = filemask;
elseif iscell(filemask)
    for k = 1:length(filemask)
        filelist(k) = dir(filemask{k});
    end    
elseif isempty(filemask)
    filelist = [];
else
    filelist = dir(filemask);
end

% check for proper filepath
orig_directory = pwd;

% we need to handle the case that an absolute filename is used (complete 
% with path). I've put this into a try:catch block because matlab's fileparts 
% requires a char array for input and dir outputs a struct. If dir is used
% then there won't be any path information anyway. And if there's no path
% on the input then it won't hurt anything.
% 
try
    [pathstr, name, ext] = fileparts(filemask);
catch
end

if exist('pathstr') && ~isempty(pathstr)
    cd(pathstr);
end

if length(filelist) < 1
    logentry(['No files found matching ' filemask ', returning empty set.']);
    v = NULLTRACK;
    calout = NaN;
    return;
end

% Need to handle the ambiguity between loading N files with just one
% calibration factor versus loading N files with N calibration factors.
if ( length(filelist) ~= length(calib_um) ) && ( length(calib_um) == 1 )
    calib_um = repmat(calib_um, length(filelist), 1);
elseif ( length(filelist) ~= length(calib_um) )
    error('Mismatch between the number of files in inputted list and number of defined calib_um');
end

% Now, for every file...
for fid = 1:length(filelist)
    
    file = filelist(fid).name;    
    
    % What if we want to use the csv file provided by video spot tracker?
    % We have to make a decision here, and we'll base it on the filename
    % extension...
    if ~isempty(strfind(file, '.csv')) && isempty(strfind(file, '.mat'))
        % assume csv file is the input and load accordingly
%         dd = csvread(file, 1, 0);
          dd = importdata(file, ',', 1);
          if isstruct(dd) && isfield(dd, 'data')
              dd = dd.data;
          else
              logentry('No data. Moving on...');
              v = NULLTRACK;
              if size(filelist,1) > 1
                  continue;
              else
                  return;
              end
          end
    else
        % Load the tracking data from a .mat file    
        dd=load(file);
    end

    % Handle the incoming data for whatever type it is...
    % First, check if it's a csv file
    if ~isempty(strfind(file, '.csv')) && isempty(strfind(file, '.mat'))
        
        data = convert_csv(dd);
                
        % no timestamps in this vrpn file format
        tstamps = 'no';
        
    % If it's not a csv file, it should be a vrpn2mat structure, which
    % changes depending on the vrpnlog2matlab version. In any case, if the
    % input has no fieldnames then we don't know what kind of file this is.
    elseif isempty(fieldnames(dd))
        logentry(['No data found in *' file '*.']);
        if ~exist('glommed_d', 'var')            
            glommed_d = [];
        end
        continue;
        
    % Is it an EVT (edited video tracking) file?
    elseif ~isempty(strfind(file, '.evt.')) && isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        data = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;
        
        % need to handle the presence and absence of a calibration factor inside the
        % tracking structure
        
        % A calibration factor (CF) can exist in either the function call
        % for load_video_tracking or within the inputted tracking
        % structure, or both.  If there is a CF in the tracking 
        % structure AND the function call, they had better be the same or
        % there's a contradiction we don't know how to resolve (error).  If
        % there is just one CF and it lives in the tracking structure 
        % then forward it through the rest of load_video_tracking as the 
        % root 'calib_um'.
        if isfield(dd.tracking, 'calib_um')
            if ~isempty(calib_um(fid)) && dd.tracking.calib_um ~= calib_um(fid)
                warning('The inputted calib_um at function call does not equal calib_um in the tracking data structure, using data structure version.');
            end
            calib_um(fid) = dd.tracking.calib_um;
        elseif ~isempty(calib_um(fid))
            dd.tracking.calib_um = calib_um(fid);
        end
        
        % if there are timestamps, and evt_gui was used, then they are already attached
        tstamps = 'done';
        
    elseif isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        data = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;

        data = axe_vrpn_timestamps(data); 
        
    elseif isfield(dd.tracking, 'videoTrackingSecUsecZeroXYZ')        
        data = convert_videoTrackingSecUsecZeroXYZ(dd);
         
        % no timestamps in this vrpn file format
        tstamps = 'no';

    elseif isfield(dd.tracking, 'spot2DSecUsecIndexXYZ')
        data = convert_spot2DSecUsecIndexXYZ(dd);
        
        % no timestamps in this vrpn file format
        tstamps = 'no';

    elseif length(dd.tracking) > 1
        data = dd.tracking;
        ch = NaN;
        error(['CONGRATULATIONS! You have stumbled upon an OLD video-tracking VRPN format. ' ...
              '\nYou will have to edit load_video_tracking and include a filter for this format.']);
    else
      data = zeros(1,13);

    end
    
    if fid == 1
        glommed_d = zeros(0,size(data,2));
    end

    % Add in compatibility with Panoptes runs, but only when there's no
    % pass or well data to clobber (sums > 0)
    if size(data,2) < 12 || (sum(data(:,PASS)) == 0 && sum(data(:,WELL)) == 0)
        [well, pass] = pan_wellpass(file);
        if well == 0
            well = fid; % use the 'well' heading as a placeholder for "filenumber" when there's no Panoptes data
        else
            data(:,WELL) = well;
        end
        data(:,PASS) = pass;        
    end
    
    % handle the physical units
    units{X} = xyzunits;  units{Y} = xyzunits;  units{Z} = xyzunits;
	if strcmp(xyzunits,'m')
		data(:,X:Z) = data(:,X:Z) .* calib_um(fid) * 1e-6;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'um')
		data(:,X:Z) = data(:,X:Z) .* calib_um(fid);  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'nm')
		data(:,X:Z) = data(:,X:Z) .* calib_um(fid) * 1e3;  % convert video coords from pixels to nm
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

    logentry(['Loaded *' filelist(fid).name '* which contains ' num2str(max(data(:,ID))) ' initial trackers.']);
    
    % now do all of the bead specific things
    IDlist = unique(trackerID)';
    for k = 1 : length(IDlist)
        
        % select rows in table that correspond only to the k-th bead
        idx = find(trackerID == IDlist(k));
        this_tracker  = data(idx,:);
        
        % handle the case for which a trackerID was used, but no points
        % were retained in the dataset.
        if(isempty(this_tracker)); 
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
            
        elseif strcmp(tstamps, 'no')
            if sum(this_tracker(:,FRAME)) > 0
                data(idx,TIME) = data(idx,FRAME) * 1/frame_rate;
            else
                frames = [0 : rows(this_tracker)-1]';
                data(idx,TIME) = frames * 1/frame_rate;
            end
            
%             logentry(['Computed time using specified frame rate of ' num2str(frame_rate) ' fps.']);
        end    


    end

    
    % we don't want to repeat any beadIDs as we concatenate the
    % datasets from each filename in the stack.  To avoid this, we add
    % the max(beadID) to the newdata's beadID and then we concatenate.
    if ~isempty(glommed_d)
        beadmax = max(glommed_d(:,ID));
    else
        beadmax = 0;
    end
    
    data(:,ID) = data(:,ID) + beadmax + 1;
    
    if isempty(glommed_d)
        glommed_d = data;
        clear data;
    elseif ~isempty(data) && ~isempty(glommed_d)
        glommed_d = [glommed_d ; data];
        clear data;
    end
    
    calout(fid,1) = calib_um(fid);
%     fprintf('The size of glommed_d is: %i, %i\n', size(glommed_d,1), size(glommed_d,2));
end

data = glommed_d;


% now, settle our outputs, and move on....
if ~isempty(data)
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
            if exist('AREA');    v.area = data(:,AREA);    end;
            if exist('SENS');    v.sens = data(:,SENS);    end;
            if exist('WELL');    v.well = data(:,WELL);    end;
            if exist('PASS');    v.pass = data(:,PASS);    end;
%             if size(dd,2) == 14
%                 v.area = data(:,AREA);
%             end
%             if size(dd,2) == 15
%                 v.sens = data(:,SENS);
%             end
    end
else
    v = NULLTRACK;
end 
    
    cd(orig_directory);
return;

function data = axe_vrpn_timestamps(data)
    % Let's axe the VRPN "time-stamps"... they don't mean anything here
    data(:,2) = zeros(size(data, 1),1);  %fill the second column with zeros
    data = data(:,2:end); %delete the first column
    return;

function data = convert_csv(dd)
    video_tracking_constants;

    CSVFRAME = 1;
    CSVID    = 2;
    CSVX     = 3;
    CSVY     = 4;
    CSVZ     = 5;

    if size(dd,2) >= 14
        CSVAREA = 14;
    end

    if size(dd,2) >= 15
        CSVSENS = 15;
    end

    data(:,TIME)  = zeros(rows(dd),1);
    data(:,FRAME) = dd(:,CSVFRAME);
    data(:,ID)    = dd(:,CSVID);
    data(:,X)     = dd(:,CSVX);
    data(:,Y)     = dd(:,CSVY);
    data(:,Z)     = dd(:,CSVZ);
    data(:,ROLL)  = zeros(rows(dd),1);
    data(:,PITCH) = zeros(rows(dd),1);
    data(:,YAW)   = zeros(rows(dd),1);

    if size(dd,2) >= 14
        data(:,AREA) = dd(:,CSVAREA);
    else
        data(:,AREA) = 0;
    end

    if size(dd,2) >= 15
        data(:,SENS) = dd(:,CSVSENS);
    else
        data(:,SENS) = 0;
    end
    
    return;
    
    
function data = convert_videoTrackingSecUsecZeroXYZ(dd)
    video_tracking_constants; 

    data = dd.tracking.videoTrackingSecUsecZeroXYZ;

    data = axe_vrpn_timestamps(data);


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
    
    return;
    
function data = convert_spot2DSecUsecIndexXYZ(dd)
        
    video_tracking_constants;
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
    
    return;
    