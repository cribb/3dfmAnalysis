function d = load_vrpn_tracking(file, stage_res, psd_res, window, xyzunits);
% 3DFM function
% last modified 04/02/03
%
% This function reads in a 3DFM dataset previously saved as a 
% 2d matrix in a matlab workspace file (*.mat) file 
% and converts it to the familiar 3dfm data structure.
% 
% d = load_vrpn_tracking(filename, stage_res, psd_res, window_type, xyz_units);
%
% where "filename" is the .mat filename
%       "stage_res" is the desired stage sampling frequency
%		"psd_res" is the desired resolution between datapts in the PSD
%		"window_type" is either 'blackman' or 'rectangle'
%		"xyz_units" is either 'um' or 'm'
%
% Notes:
%
% - This function is designed to work under default conditions with
%   only one input argument, the filename.
% - The stage position defaults to resampling the dataset to a 1000Hz
%   uniform time-step (linear interpolation). To avoid resampling 
%   the stage, use a stage_res value of 0 Hz.
% - The choice of window for the power spectral density (PSD) can be 
%   either 'blackman' or 'rectangle' (rectangle for rheology data). 
%   (default = blackman)
% - The xyzunits can be either 'um' for microns for 'm' for meters.
%   (default = microns)
%
% 
% 10/30/02 - added PSD res option.
% 11/12/02 - added window_type option.
% 12/03/02 - added units, meters or microns, option
% 04/02/03 - changed name to load_vrpn_tracking to reflect changes in 
%            particle tracker's output (i.e. logfile format change)


% handle the argument list
if nargin < 5;   xyzunits  = 'um';			end;
if nargin < 4;   window = 'blackman';  		end;
if nargin < 3;   psd_res = 0.3;             end;
if nargin < 2;   stage_res = 1000;          end;

	%load tracking data after it has been converted to a .mat file
	dd=load(file);

	d.const.beadSize = 0.957;
	d.const.name = file;
	d.const.xyzunits = 'microns';
	
	d.stage.time = dd.tracking.stageCommandSecUsecZeroXYZ(:,1) + ...        % get time data
                   dd.tracking.stageCommandSecUsecZeroXYZ(:,2) * 1e-6;      % add usec column
    
	d.stage.x    = dd.tracking.stageCommandSecUsecZeroXYZ(:,4);        % get stage x data
	d.stage.y    = dd.tracking.stageCommandSecUsecZeroXYZ(:,5);        % get stage y data
	d.stage.z    = dd.tracking.stageCommandSecUsecZeroXYZ(:,6);        % get stage z data

    d.qpd.time   = dd.tracking.QPDsSecUsecVals(:,1) + ...
                   dd.tracking.QPDsSecUsecVals(:,2) * 1e-6;
	d.qpd.q1     = dd.tracking.QPDsSecUsecVals(:,3);            % get data from individual 
	d.qpd.q2     = dd.tracking.QPDsSecUsecVals(:,4);            % quadrants and store them in 
	d.qpd.q3     = dd.tracking.QPDsSecUsecVals(:,5);			% d.qpd_0 : d.qpd_3
	d.qpd.q4     = dd.tracking.QPDsSecUsecVals(:,6);

																       
	d.laser.time = dd.tracking.laserIntensitySecUsecVal(:,1) + ...    % get data from laser at top of system
                   dd.tracking.laserIntensitySecUsecVal(:,2) * 1e-6;  % (after being split out of the 98/2 
    d.laser.intensity = dd.tracking.laserIntensitySecUsecVal(:,3);    % beam splitter

    % Subtract off t_zero's
    d.stage.time = d.stage.time - d.stage.time(1);
    d.qpd.time   = d.qpd.time - d.qpd.time(1);
    d.laser.time = d.laser.time - d.laser.time(1);
                                                                 
	% handle the units before doing anything else
	if xyzunits == 'um'
		d.stage.x = d.stage.x * 1e6;  % convert stage data from default meters to microns
		d.stage.y = d.stage.y * 1e6;
		d.stage.z = d.stage.z * 1e6;
		d.const.xyzunits = 'microns';
	end
																 
	% resample the positions on a uniform step if
	% the inputted stage_res is > 0.
	if stage_res > 0
		t = d.stage.time;
		stage_T = 1/stage_res;
		d.stage.ts = interp1(t, d.stage.time, min(t):stage_T:max(t))';
		d.stage.xs = interp1(t, d.stage.x, min(t):stage_T:max(t))';
		d.stage.ys = interp1(t, d.stage.y, min(t):stage_T:max(t))';
		d.stage.zs = interp1(t, d.stage.z, min(t):stage_T:max(t))';
	else
		% empty condition--
		% in case we do not want to interpolate
		% stage dataset.
	end 
	
	% Construct the Power Spectral Densities of x, y, and z
	% Stage Positions
	
	% Put some easier variable names here for all the function calls
	xs = d.stage.xs;
	ys = d.stage.ys;
	zs = d.stage.zs;
	
	% Want a PSD resolution of psd_res Hz between freqs with
	% a windowing of window_type
	
	[psd f] = mypsd([xs, ys, zs], stage_res, psd_res, window);
	d.psd.f = f;
	d.psd.x = psd(:, 1);
	d.psd.y = psd(:, 2);
	d.psd.z = psd(:, 3);

	% get the radial vector (where magnitude of vector is radius from origin)
	d.stage.rs = sqrt( (xs.^2) + (ys.^2) +(zs.^2));
	d.psd.r = mypsd(d.stage.rs, 1000, psd_res, window);
