function d = load_vrpn_tracking(file, xyzunits, tzero, beadpos, beadOffset, user_input);
% 3DFM function
% last modified 06/11/04 - kvdesai
%
% This function reads in a 3DFM dataset previously saved as a 
% 2d matrix in a matlab workspace file (*.mat) file 
% and converts it to the familiar 3dfm data structure.
% 
% USAGE:
% d = load_vrpn_tracking(filename, xyz_units, tzero, beadpos, beadOffset, user_input);
%
% PARAMETER DESCRIPTION: curly brackets indicate default values.
% 
% "file" : required arguement
%     it can be a string containing name of the the .mat file 
%     OR it can be the variable created by double-clicking the .mat file
% "xyz_units" : [{'u'} | 'm']
%     specifies units of the displacement. 
%     'u' for microns and 'm' for meters
% "tzero" : [{'uct'} | 'zero']
%     specifies format of time staps
%     'uct' for universal coordinated time stamps
%     'zero' for using first element in the array as time reference
% "beadpos" : [{'yes'} | 'no']
%     a flag specifying whether we want bead positions to be computed and
%     included in the data set or not.
% "beadOffset" : [{'yes'} | 'no']
%     a flag specifying if we want to remove the offset from bead positions.
%     not used when "beadpos" == 'no'. 
%     'yes' means remove any offset from bead positions
%     'no' means do not remove any offset.
% "user_input" : ['yes' | {'no'}]
%     controls a prompt where custom information about a dataset can be typed in 
%     by the user. SPECIFYING 'YES' TURNS LOAD_VRPN_TRACKING INTO A FUNCTION 
%     THAT REQUIRES USER INTERACTION.
% 
% NOTES: none.


	% handle the argument list
	if (nargin < 6 | isempty(user_input));  user_input='no';         end;
    if (nargin < 5 | isempty(beadOffset));  beadOffset = 'yes';       end;
	if (nargin < 4 | isempty(beadpos));     beadpos='yes';        	 end;
	if (nargin < 3 | isempty(tzero));       tzero = 'uct';           end;
	if (nargin < 2 | isempty(xyzunits));    xyzunits  = 'u';	     end;

	% load tracking data after it has been converted to a .mat file OR
    % if it is present as a workspace variable
    if(ischar(file))
        dd= load(file);        
        % get filename by subtracting filepath
        id = max(find(file(:)=='\'));
        if(isempty(id))
            name = file;
        else
            name = file(id+1:end);
        end
        d.info.orig.name = name;
    else
        dd.tracking = file;
        d.info.orig.name = 'NOT AVAILABLE';
    end

    % meta-information (just constant here, but should be upgradable for
    % meta-data found in future .vrpn tracking files
	d.info.orig.beadSize = 0.957;	
	d.info.orig.xyzunits = xyzunits;

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
    % stage command data in original log file is in meteres
    % stage sensor data in original log file is in microns
    % error positions in original log file is in mircrons
    
	if findstr(xyzunits,'u') % displacement unit is microns
		d.stageCom.x = d.stageCom.x * 1e6;  
		d.stageCom.y = d.stageCom.y * 1e6;  
		d.stageCom.z = d.stageCom.z * 1e6;
		d.info.orig.xyzunits = 'u';
    end
    
    if findstr(xyzunits,'m') % displacement unit is meters
        if(isfield(d,'stageReport'))
            d.stageReport.x = d.stageReport.x*1e-6;
            d.stageReport.y = d.stageReport.y*1e-6;
            d.stageReport.z = d.stageReport.z*1e-6;
        end
        if(isfield(d,'avgError'))
            d.avgError.x = d.avgError.x*1e-6;
            d.avgError.y = d.avgError.y*1e-6;
            d.avgError.z = d.avgError.z*1e-6;
        end        
        if(isfield(d,'posError'))
            d.posError.x = d.posError.x*1e-6;
            d.posError.y = d.posError.y*1e-6;
            d.posError.z = d.posError.z*1e-6;
        end        
    end       
			
    % compute the position of the bead at QPD bandwidth, provided
    % that the 'beadpos' switch is active.
    % A BUG BEING QUARANTINED: 06/14/04 FIX THIS IN PARTICLE TRACKER
    % When the position errors are calculated for first sample, the
    % jacobian is not available, so the default jacobian is used. So the
    % first sample position error is quite different from rest of them.
    % here, we are discarding the first sample to make the offset
    % subtraction work.
    if findstr(beadpos,'y')
		d.beadpos.time = d.stageReport.time(2:end);
		d.beadpos.x = d.stageReport.x(2:end) + d.posError.x(2:end);
		d.beadpos.y = d.stageReport.y(2:end) + d.posError.y(2:end);
		d.beadpos.z = d.stageReport.z(2:end) + d.posError.z(2:end);
        if findstr(beadOffset,'y') %if we don't want offset in bead positions.
            d.beadpos.x = d.beadpos.x - d.beadpos.x(1,1);
            d.beadpos.y = d.beadpos.y - d.beadpos.y(1,1);
            d.beadpos.z = d.beadpos.z - d.beadpos.z(1,1);
        end
    end
