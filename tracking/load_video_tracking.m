function d = load_video_tracking(file, frame_rate, upsampleHz, psd_res, window, xyzunits, calib_um, absolute_pos);
% 3DFM function
% last modified 09/22/2004
%
% This function reads in a Video Tracking dataset, saved in the 
% matlab workspace file (*.mat) format and converts it to the 
% familiar 3dfm data structure.
% 
% d = load_video_tracking(file, frame_rate, upsampleHz, psd_res, window, xyzunits, calib_um, absolute_pos);
%
% where "filename" is the .mat filename
%       "frame_rate" is the physical frame rate of the captured video sequence
%       "upsampleHz" is the desired upsampling (linear interp) rate of the video
%		"psd_res" is the desired resolution between datapts in the PSD
%		"window_type" is either 'blackman' or 'rectangle'
%		"xyz_units" is either 'nm' 'um' 'm' or 'pixels'
%       "calib_um" is the calibration coefficient to convert pixels to microns
%       "absolute_pos" is either 'relative' or 'absolute'
%
% Notes:
%
% - This function is designed to work under default conditions with
%   only one input argument, the filename.
% - The video framerate defaults to 30Hz (fps)
% - The default upsampling frequency is 30fps.
% - If no upsampling is desired, use an upsampleHz of [] (NULL).
% - The choice of window for the power spectral density (PSD) can be 
%   either 'blackman' or 'rectangle' (rectangle for rheology data). 
%   (default = blackman)
% - The xyzunits can be either 'um' for microns for 'm' for meters.
%   (default = pixels)
%
% 08/04/03 - created from load_vrpn_tracking
% 08/09/03 - added the upsampling feature
% 09/22/04 - updated documentation
%

% handle the argument list
if nargin < 8;   absolute_pos = 'relative'; end;
if nargin < 7;   calib_um = 1;              end;
if nargin < 6;   xyzunits  = 'pixels';	    end;
if nargin < 5;   window = 'blackman';  		end;
% psd nargin handled below
if nargin < 3;   upsampleHz = [];           end;
if nargin < 2;   frame_rate = 30;            end;

	% Load the tracking data after it has been converted to a .mat file
	dd=load(file);
    if isfield(dd.tracking, 'videoTrackingSecUsecZeroXYZ')
        data = dd.tracking.videoTrackingSecUsecZeroXYZ;
    elseif isfield(dd.tracking, 'spot2DSecUsecIndexXYZ')
        data = dd.tracking.spot2DSecUsecIndexXYZ;
    else
        error('I do not know how to handle this video VRPN file (weird fieldnames).');
    end
    
	d.const.beadSize = 0.957;
	d.const.name = file;

    num_sensors = max(data(:,3)) + 1;
    
    num_rows = 0;
    for k = 1 : num_sensors
        my_sensor = find(data(:,3) == k-1);
        if(length(my_sensor)>num_rows)
            num_rows = length(my_sensor);
        end
    end
    

    d.video.x = zeros(num_rows,num_sensors);
    d.video.y = zeros(num_rows,num_sensors);
    
	if(strcmp(absolute_pos,'relative'))
        for k = 1 : num_sensors       
            my_sensor      = find(data(:,3) == k-1);
                  
            xsensor = data(my_sensor,4);
            ysensor = data(my_sensor,5);
            
            for j = 1:length(my_sensor)
 			d.video.x(j,k) = xsensor(j) - xsensor(1);    
			d.video.y(j,k) = ysensor(j) - ysensor(1);
        end
    end
   	elseif(strcmp(absolute_pos,'absolute'))
        for k = 1 : num_sensors       
       
            my_sensor      = find(data(:,3) == k-1);

            xsensor = data(my_sensor,4);
            ysensor = data(my_sensor,5);
            
            for j = 1:length(my_sensor)
 			d.video.x(j,k) = xsensor(j);    
			d.video.y(j,k) = ysensor(j);
        end
        end
	end
    
    % handle the units before doing anything else
	if strcmp(xyzunits,'m')
		d.video.x = d.video.x * calib_um * 1e-6;  % convert video coords from 
		d.video.y = d.video.y * calib_um * 1e-6;  % default pixels to meters
		d.const.xyzunits = 'meters';
    elseif strcmp(xyzunits,'um')
        d.video.x = d.video.x * calib_um;
        d.video.y = d.video.y * calib_um;  % default pixels to microns
        d.const.xyzunits = 'microns';
    elseif strcmp(xyzunits,'nm')
        d.video.x = d.video.x * calib_um * 1e3; % convert video coords from
        d.video.y = d.video.y * calib_um * 1e3; % default pixels to nm
    else 
        d.const.xyzunits = 'pixels';
	end

    for k = 1 : num_sensors
        my_sensor      = find(data(:,3) == k-1);
        d.video.r(:,k) = magnitude(d.video.x(:,k),d.video.y(:,k));
    end        
    
    % Assuming we have a constant frame rate:
    d.video.time = [0 : 1/frame_rate : (length(d.video.x)-1)/frame_rate]';

    
    % handle the PSD res Problem
    if (nargin < 4) | (length(psd_res) == 0);
        psd_res = 1/d.video.time(end);
    end

    
    % handle the upsampling if so desired
    if length(upsampleHz) > 0
		t = d.video.time;
		video_T = 1/upsampleHz;
		d.video.ts = interp1(t, d.video.time, min(t):video_T:max(t))';
		d.video.xs = interp1(t, d.video.x, min(t):video_T:max(t));
		d.video.ys = interp1(t, d.video.y, min(t):video_T:max(t));
		d.video.rs = interp1(t, d.video.r, min(t):video_T:max(t));
    
        ts = d.video.ts;
        xs = d.video.xs(:,k);
		ys = d.video.ys(:,k);
		rs = d.video.rs(:,k);
        
        [psd f] = mypsd([xs, ys, rs], frame_rate, psd_res, window);
		d.psd.fs = f;
		d.psd.xs(:,k) = psd(:, 1);
		d.psd.ys(:,k) = psd(:, 2);
        d.psd.rs(:,k) = psd(:, 3);
    end   

	% Construct the Power Spectral Densities for x and y tracked positions
	for k = 1 : num_sensors

        % Put some easier variable names here for all the function calls
        t = d.video.time;
        x = d.video.x(:,k);
		y = d.video.y(:,k);
		r = d.video.r(:,k);

        
        % Want a PSD resolution of psd_res Hz between freqs with
		% a windowing of window_type

        
		[psd f] = mypsd([x, y, r], frame_rate, psd_res, window);
		d.psd.f = f;
		d.psd.x(:,k) = psd(:, 1);
		d.psd.y(:,k) = psd(:, 2);
        d.psd.r(:,k) = psd(:, 3);

	end
    
