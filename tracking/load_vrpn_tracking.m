function d = load_vrpn_tracking(file, xyzunits, tzero, beadpos, user_input);
% 3DFM function
% last modified 05/11/04 - kvdesai
%
% This function reads in a 3DFM dataset previously saved as a 
% 2d matrix in a matlab workspace file (*.mat) file 
% and converts it to the familiar 3dfm data structure.
% 
% d = load_vrpn_tracking(filename, xyz_units, tzero, beadpos, user_input);
%
% where "file" can be a string containing name of the the .mat file 
%              OR it can be the variable created by double-clicking the .mat file
%		"xyz_units" is either 'um' or 'm'
%       "tzero" is either 'zero' or 'uct'
%       "beadpos" is either 'yes' or 'no'-tells whether to compute bead-position
%       "user_input" is either 'yes' or 'no'-tells if to prompt user to
%       type in extra information associated with the dataset.
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
% - The tzero parameter can be either 'zero' for using the first element
%   in the array as tzero, or 'uct' for universal coordinated time, defaulting
%   to 'uct'
% - The user_input parameter controls a prompt where custom information
%   about a dataset can be included by the user.  NOTE:  USING THIS ARGUMENT
%   TURNS LOAD_VRPN_TRACKING INTO A FUNCTION THAT REQUIRES USER
%   INTERACTION.
% 
% 10/30/02 - added PSD res option; jcribb.
% 11/12/02 - added window_type option; jcribb.
% 12/03/02 - added units, meters or microns, option; jcribb
% 04/02/03 - changed name to load_vrpn_tracking to reflect changes in 
%            particle tracker's output (i.e. logfile format change); jcribb
% 06/20/03 - added tzero option; jcribb
% 12/19/03 - Added jacobian storage; kvdesai
%          - calculation of position error from jacobian
%          - storage of even time stamps
%          - option to specify empty argument
%          - switched default value of tzero from 'zero' to 'uct'
% 05/06/04 - merged changes between two different versions; jcribb
%          - added user_input parameter
%          - removed DSP handling code  
% 05/11/04 - renamed d.stage field to d.stageCom, removed ambiguity
%

	% handle the argument list
	if (nargin < 5 | isempty(user_input));  user_input='no';         end;
	if (nargin < 4 | isempty(beadpos));     beadpos='yes';        	 end;
	if (nargin < 3 | isempty(tzero));       tzero = 'uct';           end;
	if (nargin < 2 | isempty(xyzunits));    xyzunits  = 'um';	     end;

	% load tracking data after it has been converted to a .mat file OR
    % if it is present as a workspace variable
	if(ischar(file))
        dd= load(file);
    else
        dd.tracking = file;
    end

    % meta-information (just constant here, but should be upgradable for
    % meta-data found in future .vrpn tracking files
	d.info.orig.beadSize = 0.957;
	d.info.orig.name = name;
	d.info.orig.xyzunits = xyzunits;

    % get filename by subtracting filepath
    id = max(find(file(:)=='\'));
    if(isempty(id))
        name = file;
    else
        name = file(id+1:end);
    end

   % handle the switch for including user_input 
   if findstr(user_input,'y')
        d.info.orig.user_input =  input(['Type any extra information you \n', ...
                                         'want to be associated with this data set \n',...
                                         'Press Enter only when you are done\n'],'s');
   end

   
	d.stageCom.time = dd.tracking.stageCommandSecUsecZeroXYZ(:,1) + ...        % get time data
                   dd.tracking.stageCommandSecUsecZeroXYZ(:,2) * 1e-6;      % add usec column
	d.stageCom.x    = dd.tracking.stageCommandSecUsecZeroXYZ(:,4);        % get stage x data
	d.stageCom.y    = dd.tracking.stageCommandSecUsecZeroXYZ(:,5);        % get stage y data
	d.stageCom.z    = dd.tracking.stageCommandSecUsecZeroXYZ(:,6);        % get stage z data

    d.qpd.time   = dd.tracking.QPDsSecUsecVals(:,1) + ...
                   dd.tracking.QPDsSecUsecVals(:,2) * 1e-6;
	d.qpd.q1     = dd.tracking.QPDsSecUsecVals(:,3);            % get data from individual 
	d.qpd.q2     = dd.tracking.QPDsSecUsecVals(:,4);            % quadrants and store them in 
	d.qpd.q3     = dd.tracking.QPDsSecUsecVals(:,5);			% d.qpd_0 : d.qpd_3
	d.qpd.q4     = dd.tracking.QPDsSecUsecVals(:,6);
						       
	d.laser.time = dd.tracking.laserIntensitySecUsecVal(:,1) + ...    % get data from laser at top of system
                   dd.tracking.laserIntensitySecUsecVal(:,2) * 1e-6;  % (after being split out of the 98/2 
    d.laser.intensity = dd.tracking.laserIntensitySecUsecVal(:,3);    % beam splitter

    if(isfield(dd.tracking,'stageSenseSecUsecXYZsense')) %if we have sensor data logged
        d.stageReport.time = dd.tracking.stageSenseSecUsecXYZsense(:,1) + ...
                            dd.tracking.stageSenseSecUsecXYZsense(:,2) * 1e-6;
        d.stageReport.x = dd.tracking.stageSenseSecUsecXYZsense(:,3); %from volts to micorns
        d.stageReport.y = dd.tracking.stageSenseSecUsecXYZsense(:,4);
        d.stageReport.z = dd.tracking.stageSenseSecUsecXYZsense(:,5);
    end    
    
    if(isfield(dd.tracking,'RMSerror'))
        % this are position error passed through a decreasing ramp filter.
        % So this are essentilly weighted averages of last 100 position
        % This field is obsolete as of 05/11/04 
        d.avgError.time = dd.tracking.RMSerror(:,1) + dd.tracking.RMSerror(:,2) * 1e-6;
        d.avgError.x = dd.tracking.RMSerror(:,3);
        d.avgError.y = dd.tracking.RMSerror(:,4);
        d.avgError.z = dd.tracking.RMSerror(:,5);
    end
    
    if(isfield(dd.tracking,'posErrorSecUsecXYZ'))
        % This are position errors got from QPD signals pass through the
        % jacobian. This computation is done in vrpnLogTomatlab module
        d.posError.time = dd.tracking.posErrorSecUsecXYZ(:,1) + dd.tracking.posErrorSecUsecXYZ(:,2) * 1e-6;
        d.posError.x = dd.tracking.posErrorSecUsecXYZ(:,3);
        d.posError.y = dd.tracking.posErrorSecUsecXYZ(:,4);
        d.posError.z = dd.tracking.posErrorSecUsecXYZ(:,5);
    end
    
    if(isfield(dd.tracking,'qpd2xyzRawsPolyColsXYZ'))
    % convert one/many jacobians to the matrix form from a serial raw form
        svec = size(dd.tracking.qpd2xyzRawsPolyColsXYZ);
        num_jacobs = svec(1,1);
        for i = 1:num_jacobs
            for j = 1:26
                for k = 1:3
                    d.jacobian(i,1).qpd2xyz(j,k) =  dd.tracking.qpd2xyzRawsPolyColsXYZ(i, 2 + (j-1)*3 + k);
                end
            end
            d.jacobian(i,1).time = dd.tracking.qpd2xyzRawsPolyColsXYZ(i,1) + dd.tracking.qpd2xyzRawsPolyColsXYZ(i,2)*1e-6;
        end
    end
    
   if(isfield(dd.tracking,'TimeStampsVRPNSecUsecEVENSecUse'));
   % replace the vrpn time stamps with even time stamps if provided
       teven = dd.tracking.TimeStampsVRPNSecUsecEVENSecUse(:,3)+ dd.tracking.TimeStampsVRPNSecUsecEVENSecUse(:,4)*1e-6;
       d.qpd.time = teven;
       d.laser.time = teven;
       if(isfield(d,'stageReport'))
           d.stageReport.time = teven;
       end
       if(isfield(d,'posError'))
           d.posError.time = teven;
       end
   end
    
   % Now all information from the original files is copied. So delete the 'dd' to clear memory
   clear dd;
   
   % Subtract off t_zero's if the parameter is set to do so
   if ~strcmp(tzero,'uct')
       t0 = d.qpd.time(1,1);
       d.stageCom.time = d.stageCom.time - t0;
       d.qpd.time   = d.qpd.time - t0;
       d.laser.time = d.laser.time - t0;
   
       if(isfield(d,'jacobian'))
           d.jacobian(:,1).time = d.jacobian(:,1).time - t0;
       end
       
       if(isfield(d,'stageReport'))
           d.stageReport.time = d.stageReport.time - t0;
       end
       
       if(isfield(d,'avgError'))
           d.avgError.time = d.avgError.time - t0;
       end
       
       if(isfield(d,'posError'))
           d.posError.time = d.posError.time - t0;
       end
   end   
                                                                 
	% handle the units before doing any mathematical analysis on data
	if findstr(xyzunits,'m')
		d.stageCom.x = d.stageCom.x * 1e-6;  % convert stage data from
		d.stageCom.y = d.stageCom.y * 1e-6;  % default microns to meters
		d.stageCom.z = d.stageCom.z * 1e-6;
		d.info.orig.xyzunits = 'm';
    end
			
    % compute the position of the bead at QPD bandwidth, provided
    % that the 'beadpos' switch is active.
    if findstr(beadpos,'y')
		d.beadpos.time = d.stageReport.time;
		d.beadpos.x = d.stageReport.x + d.posError.x;
		d.beadpos.y = d.stageReport.y + d.posError.y;
		d.beadpos.z = d.stageReport.z + d.posError.z;
    end
