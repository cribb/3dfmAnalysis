function varargout = load_video_tracking(file, frame_rate, xyzunits, calib_um, absolute_pos, tstamps);
% 3DFM function
% last modified 05/09/2005
%
% This function reads in a Video Tracking dataset, saved in the 
% matlab workspace file (*.mat) format and prepares it for most 
% data analysis functions.
% 
% d        = load_video_tracking(file, frame_rate, xyzunits, calib_um, absolute_pos, tstamps);
% [d,ch]   = load_video_tracking(file, frame_rate, xyzunits, calib_um, absolute_pos, tstamps);
% [d,ch,u] = load_video_tracking(file, frame_rate, xyzunits, calib_um, absolute_pos, tstamps);
%
% where "d" is the outputted data table
%       "ch" are the column headings for the data table, d
%       "u" are the units for columns of the data table, d
%       "filename" is the .mat filename
%       "frame_rate" (default 120fps) is the frame rate of the captured video sequence
%	    "xyz_units" is either 'nm' 'um' 'm' or 'pixels'
%       "calib_um" is the calibration coefficient to convert pixels to microns
%       "absolute_pos" is either 'relative' or 'absolute'
%
% Notes:
%
% - This function is designed to work under default conditions with
%   only the filename as an input argument.
%
% 08/04/03 - created from load_vrpn_tracking
% 08/09/03 - added the upsampling feature
% 09/22/04 - updated documentation
% 10/23/04 - added filter on input file (in case it's not a struct)
% 01/24/05 - added the timestamps ability
% 05/09/05 - MAJOR CHANGES to output format.  Prior to this version,
%            load_video_tracking outputted a matrix that required all beads to exist
%            for all times.  This was changed to reflect Video Spot Tracker's output
%            more truthfully.  Use 'get_bead' to extract a specific bead's
%            data.  Also added support for '.evt.mat' data format.
%

% handle the argument list
if (nargin < 6 | isempty(tstamps));        tstamps  = 'no';	          end;
if (nargin < 5 | isempty(absolute_pos));   absolute_pos = 'relative'; end;
if (nargin < 4 | isempty(calib_um));       calib_um = 1;              end;
if (nargin < 3 | isempty(xyzunits));       xyzunits  = 'pixels';	  end;
if (nargin < 2 | isempty(frame_rate));     frame_rate = 120;          end;

	% Load the tracking data after it has been converted to a .mat file
    dd=load(file);
    if strfind(file, '.evt.') & isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        data = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;

        % set up variables for easy tracking of table's column headings
        TIME = 1; ID = 2; FRAME = 3; X = 4; Y = 5; Z = 6; 
        ROLL = 7; PITCH = 8; YAW = 9; RADIAL = 10;
        
        ch{TIME} = 'time';
        ch{ID} = 'id';
        ch{FRAME} = 'frame';
        ch{X} = 'x';
        ch{Y} = 'y';
        ch{Z} = 'z';
        ch{ROLL} = 'roll';
        ch{PITCH} = 'pitch';
        ch{YAW} = 'yaw';
        ch{RADIAL} = 'radial vector';      
        
        % if there are timestamps, and evt_gui was used, then they are already attached
        tstamps = 'done';
        
    elseif isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        data = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;

        % Let's axe the VRPN "time-stamps"... they don't mean anything here
        data(:,2) = zeros(size(data, 1),1);  %fill the second column with zeros
        data = data(:,2:end); %delete the first column

        % set up variables for easy tracking of table's column headings
        TIME = 1; ID = 2; FRAME = 3; X = 4; Y = 5; Z = 6; 
        ROLL = 7; PITCH = 8; YAW = 9; RADIAL = 10;
        
        ch{1} = 'time';
        ch{2} = 'id';
        ch{3} = 'frame';
        ch{4} = 'x';
        ch{5} = 'y';
        ch{6} = 'z';
        ch{7} = 'roll';
        ch{8} = 'pitch';
        ch{9} = 'yaw';
        ch{10} = 'radial vector';      

    elseif isfield(dd.tracking, 'videoTrackingSecUsecZeroXYZ')        
        data = dd.tracking.videoTrackingSecUsecZeroXYZ;

        % Let's axe the VRPN "time-stamps"... they don't mean anything here
        data(:,2) = zeros(size(data, 1),1);  
        data = data(:,2:end);

        % set up variables for easy tracking of table's column headings
        TIME = 1; ID = 2; X = 3; Y = 4; Z = 5; 
        
        ch{1} = 'time';
        ch{2} = 'id';
        ch{3} = 'x';
        ch{4} = 'y';
        ch{5} = 'z';  
        
        % no timestamps in this vrpn file format
        tstamps = 'no';

    elseif isfield(dd.tracking, 'spot2DSecUsecIndexXYZ')
        data = dd.tracking.spot2DSecUsecIndexXYZ;

        % Let's axe the VRPN "time-stamps"... they don't mean anything here
        data(:,2) = zeros(size(data, 1),1);  
        data = data(:,2:end);

        % set up variables for easy tracking of table's column headings
        TIME = 1; ID = 2; X = 3; Y = 4; Z = 5; 
        
        ch{1} = 'time';
        ch{2} = 'id';
        ch{3} = 'x';
        ch{4} = 'y';
        ch{5} = 'z';       
        
        % no timestamps in this vrpn file format
        tstamps = 'no';

    elseif length(dd.tracking) > 1
        data = dd.tracking;
        ch = NaN;
    else
        error('I do not know how to handle this video VRPN file (weird fieldnames).');
    end
        
    units{TIME} = 'sec';
    
    % handle the physical units
    units{X} = xyzunits;  units{Y} = xyzunits;  units{Z} = xyzunits;
	if strcmp(xyzunits,'m')
		data(:,X:Z) = data(:,X:Z) * calib_um * 1e-6;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'um')
		data(:,X:Z) = data(:,X:Z) * calib_um;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'nm')
		data(:,X:Z) = data(:,X:Z) * calib_um * 1e3;  % convert video coords from pixels to nm
    else 
        units{X} = 'pixels';  units{Y} = 'pixels';  units{Z} = 'pixels';
	end

    trackerID = data(:,ID);
    x = data(:,X);
    y = data(:,Y);
    
    % now do all of the bead specific things
    for k = 0 : max(trackerID)    
                    
        % select rows in table that correspond only to the k-th bead
        this_tracker  = find(trackerID == k);
        
        % handle the case for which a trackerID was used, but no points
        % were retained in the dataset.
        if(length(this_tracker) == 0); 
            continue;
        end;

        % select x&y coords for only the kth bead
        this_x = x(this_tracker);
        this_y = y(this_tracker);

        if(strcmp(absolute_pos,'relative'))
            
            % subtract off the initial x and y (1st point becomes the zero)
            this_x = this_x - this_x(1);
            this_y = this_y - this_y(1);
            
            % enter the new locations into the data table
            data(this_tracker,X) = this_x;
            data(this_tracker,Y) = this_y;            

            % ASIDE: add vector magnitude column (because this is only relevant 
            % in relative measurements, it's placed here.)
            data(this_tracker,RADIAL) = magnitude(this_x,this_y);           
        
        end
        
            % Handle time.... if we don't have timestamps then we have to assume
            % that we have a constant frame rate.
            if strcmp(tstamps,'yes')
                tfile = file(1:end-9);
                try
                    times = load([tfile '.tstamp.txt'], 'ASCII');
                    times = times - times(1);
                    active_frames = data(this_tracker, FRAME);
                    data(this_tracker,TIME) = times(active_frames+1);
                catch
                    data(this_tracker,TIME) = data(this_tracker,FRAME) * 1/frame_rate;                
                end            
            elseif strcmp(tstamps, 'no')
                data(this_tracker,TIME) = data(this_tracker,FRAME) * 1/frame_rate;
            else
                % do nothing
            end    
    end
    
switch nargout
    case 1
        varargout{1} = data;
    case 2
        varargout{1} = data;
        varargout{2} = ch;
    case 3
        varargout{1} = data;
        varargout{2} = ch;
        varargout{3} = units;
    otherwise
        error('incorrect number of output arguments');
end
