function d = load_xls_tracking(file, frame_rate, upsampleHz, psd_res, window, xyzunits, calib_um);
% 3DFM function
% last modified 08/09/2003
%
% This function reads in a Video Tracking dataset, saved as an Excel 
% spreadsheet (*.xls), and converts it to the familiar 3dfm data structure.
% 
% d = load_xls_tracking(file, frame_rate, psd_res, window, xyzunits, calib_um);
%
% where "filename" is the .mat filename
%       "frame_rate" is the physical frame rate of the captured video sequence
%       "upsampleHz" is the desired upsampling (linear interp) rate of the video
%		"psd_res" is the desired resolution between datapts in the PSD
%		"window_type" is either 'blackman' or 'rectangle'
%		"xyz_units" is either 'um' or 'm' or 'pixels'
%       "calib_um" is the calibration coefficient to convert pixels to microns
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
%   (default = microns)
%
% 
% 08/04/03 - created from load_vrpn_tracking; jcribb
% 08/09/03 - added the upsampling feature
%
%
    

% handle the argument list
if nargin < 7;   calib_um = 1;              end;
if nargin < 6;   xyzunits  = 'pixels';	    end;
if nargin < 5;   window = 'blackman';  		end;
% psd nargin handled below
if nargin < 3;   upsampleHz = [];           end;
if nargin < 2;   frame_rate = 30;            end;

	% Load the tracking data after it has been converted to a .mat file
	data = xlsread(file);

    d.const.beadSize = 0.957;
	d.const.name = file;

    % num_sensors = max(data(:,2));
    num_sensors = 1;
    
    for k = 1 : num_sensors
        my_sensor      = find(data(:,2) == k);
		d.video.x(:,k) = data(my_sensor,4);    
		d.video.y(:,k) = data(my_sensor,5);    
        d.video.r(:,k) = magnitude(d.video.x(:,k),d.video.y(:,k));
    end        
    
    % handle the units before doing anything else
	if strcmp(xyzunits,'m')
		d.video.x = d.video.x * calib_um * 1e-6;  % convert video coords from 
		d.video.y = d.video.y * calib_um * 1e-6;  % default meters to microns
		d.const.xyzunits = 'meters';
    elseif strcmp(xyzunits,'um')
        d.video.x = d.video.x * calib_um;
        d.video.x = d.video.y * calib_um;
        d.const.xyzunits = 'microns';
    else 
        d.const.xyzunits = 'pixels';
	end
    
    % Assuming we have a constant frame rate:
    d.video.time = [0 : 1/frame_rate : (length(d.video.x)-1)/frame_rate]';

    % handle the upsampling if so desired
    if length(upsampleHz) > 0
		t = d.video.time;
		video_T = 1/upsampleHz;
		d.video.ts = interp1(t, d.video.time, min(t):video_T:max(t))';
		d.video.xs = interp1(t, d.video.x, min(t):video_T:max(t));
		d.video.ys = interp1(t, d.video.y, min(t):video_T:max(t));
		d.video.rs = interp1(t, d.video.r, min(t):video_T:max(t));
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
        if (nargin < 4) | (length(psd_res) == 0);
            psd_res = 1/d.video.time(end);
        end
		[psd f] = mypsd([x, y, r], frame_rate, psd_res, window);
		d.psd.f = f;
		d.psd.x(:,k) = psd(:, 1);
		d.psd.y(:,k) = psd(:, 2);
        d.psd.r(:,k) = psd(:, 3);
        
	end
    
