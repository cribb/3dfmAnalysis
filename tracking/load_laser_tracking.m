function d = load_laser_tracking(file, fields, flags);
% 3DFM function
% Created: 10/12/05 - kvdesai
% 
% This function is supposed to replace the load_vrpn_tracking function. It performs 
% all the tasks that load_vrpn_tracking does but in a better and user friendly way.
% It reads in a 3DFM dataset previously logged by Laser Tracker
% program and then converted to matlab compatible format by vrpnLogToMatlab
% program. Compatible to Laser Tracker versions 04.00 and beyond only
% 
% USAGE:
% d = load_laser_tracking(file, fields, flags);
%
% INPUT PARAMETER DESCRIPTION: curly brackets indicate default values.
% 
% "file" : required arguement
%     it can be a string containing name of the the .mat file 
%     OR it can be the 'tracking' structure created by double-clicking the .mat file
% "fields": a string containing one or more of the following characters
%     'a': all the fields listed below
%     'b': Bead position
%     'c': stage command
%     'e': Position error signal
%     'g': Feedback gains
%     'j': Jacobian (including jacobian data)
%     'l': Laser intensity
%     'q': qpd signals
%     's': stage sensor
%     default is set to 'a'. Orders in which characters are put doesn't matter, 'sqj' is same as 'qsj'.
%     If one of the charactes is 'a', all other characters are ignored. So 'abs' = 'a' = 'ale'
%     If "fields is not provided or left empty, it is defaulted to 'a'.
% 
% "flags": a structure containing binary (yes/no type) flags.
%   flags.inmicrons   = {1} | 0 : Units of displacement [{microns} | meters]
%   flags.keepuct     = {1} | 0 : Keep all timestamps in UCT format or subtract
%                                out the offset such that time starts from zero
%   flags.keepoffset  = 1 | {0} : Keep the offset in position data or subtract
%                                it out? Removed by default.
%   flags.askforinput = 1 | {0} : While loading, ask user to type in metadata?
%     controls a prompt where custom information about a dataset can be typed in 
%     by the user. SPECIFYING 1 TURNS LOAD_LASER_TRACKING INTO A FUNCTION 
%     THAT REQUIRES USER INTERACTION, SO BATCH FILES WOULD HALT.
% 
% OUTPUT PARAMETER DESCRIPTION:
% The output is a structure containing the fields that were requested.
% The field names are exactly same as those given by load_vrpn_tracking.
% Name of the fields in the output structure:
%     .beadpos
%     .stageCom
%     .stageReport
%     .posError
%     .qpd
%     .laser
%     .gains
%     .Jacobian
%     
% NOTES: The elder brother of this function 'load_vrpn_tracking' may get
% obsolete at some point. It is encouraged to use this function instead.

% handle the argument list
if (nargin < 3 | isempty(flags))
    flags.inmicrons = 1;         
    flags.keepuct = 1;
    flags.askforinput = 0;
    flags.keepoffset = 0;
else
    % fill in the missing fields
    if (~isfield(flags,'inmicrons')); flags.inmicrons = 1; end;
    if (~isfield(flags,'keepuct')); flags.keepuct = 1; end;
    if (~isfield(flags,'askforinput')); flags.askforinput = 0; end;
    if (~isfield(flags,'keepoffset')); flags.keepoffset = 0; end;
end

if (nargin < 2 | isempty(fields));  fields = 'a';       end;

%if requested to provide all the fields then make the field vector contain
%all the characters
if strfind(fields,'a')
    fields = 'bcegjlqs';
end

% Take care of all version records
version_string = '01.00';
LTver = 'NotAvailable';
V2Mver = 'NotAvailable';
d.info.orig.matOutputFileName = 'NotAvailable';
d.info.orig.LoadLaserTrackingVersion = version_string;

% load tracking data after it has been converted to a .mat file OR
% if it is present as a workspace variable
if(ischar(file))
    dd= load(file);
    if isfield(dd.tracking,'info')
        d.info.orig = dd.tracking.info;
    else
        % get filename by subtracting filepath
        id = max(find(file(:)=='\'));
        if(isempty(id))
            name = file;
        else
            name = file(id+1:end);
        end
        d.info.orig.matOutputFileName = name;            
    end
else
    dd.tracking = file;
    if isfield(dd.tracking,'info')
        d.info.orig = dd.tracking.info;
    end
end
if (isfield(d.info.orig,'LaserTrackverVersion'));
    LTver = dd.tracking.info.LaserTrackerVersion;
end
if (isfield(d.info.orig,'vrpnLogToMatlabVersion'));
    V2Mver = dd.tracking.info.vrpnLogToMatlabVersion;
end
% handle the displacement-unit request
if (flags.inmicrons) 
    d.info.orig.xyzunits = 'u';
    % Upto Laser Tracker version 04.14, the position data in tracking log 
    % is in units of microns.
    distscale = 1;
else
    d.info.orig.xyzunits = 'm';
    distscale = 1E-6;
end

% handle the switch for including user_input 
if flags.askforinput
    d.info.orig.user_input =  input(['Type any extra information you \n', ...
            'want to be associated with this data set \n',...
            'Press Enter only when you are done\n'],'s');
end
% handle the time-offset
if(isfield(dd.tracking,'JacDataSecUsecQPDsStagesensors'))
    if(removeToffset(dd.tracking.JacDataSecUsecQPDsStagesensors(1,1:2), dd.tracking.QPDsSecUsecVals(1,1:2)) < 0)
        d.info.orig.uct_offset = dd.tracking.JacDataSecUsecQPDsStagesensors(1,1:2);
    else
        d.info.orig.uct_offset = dd.tracking.QPDsSecUsecVals(1,1:2);
    end
else
    d.info.orig.uct_offset = dd.tracking.QPDsSecUsecVals(1,1:2);
end

if(strfind(fields,'c'))
    if(flags.keepuct)
        d.stageCom.time = removeToffset(dd.tracking.stageCommandSecUsecZeroXYZ(:,1:2),[0 0]);
    else
        d.stageCom.time = removeToffset(dd.tracking.stageCommandSecUsecZeroXYZ(:,1:2),d.info.orig.uct_offset);
    end
    % The third column is the 'sensor id' for vrpn tracker object. We dont
    % need is so ignore.
    d.stageCom.x    = dd.tracking.stageCommandSecUsecZeroXYZ(:,4)*distscale;        % get stage x commands data
    d.stageCom.y    = dd.tracking.stageCommandSecUsecZeroXYZ(:,5)*distscale;        % get stage y commands data
    d.stageCom.z    = dd.tracking.stageCommandSecUsecZeroXYZ(:,6)*distscale;        % get stage z commands data
    dd.tracking.stageCommandSecUsecZeroXYZ = []; %free up memory as we go
end
if(strfind(fields,'s'))
    if(flags.keepuct)
        d.stageReport.time = removeToffset(dd.tracking.stageSenseSecUsecXYZsense(:,1:2),[0 0]);
    else
        d.stageReport.time = removeToffset(dd.tracking.stageSenseSecUsecXYZsense(:,1:2),d.info.orig.uct_offset);
    end    
    d.stageReport.x    = dd.tracking.stageSenseSecUsecXYZsense(:,3)*distscale;        % get stage x sensed positions
    d.stageReport.y    = dd.tracking.stageSenseSecUsecXYZsense(:,4)*distscale;        % get stage y sensed positions
    d.stageReport.z    = dd.tracking.stageSenseSecUsecXYZsense(:,5)*distscale;        % get stage z sensed positions
    dd.tracking.stageSenseSecUsecXYZsense = []; %free up memory as we go    
end

if(strfind(fields,'q'))
    if(flags.keepuct)
        d.qpd.time = removeToffset(dd.tracking.QPDsSecUsecVals(:,1:2),[0 0]);
    else
        d.qpd.time = removeToffset(dd.tracking.QPDsSecUsecVals(:,1:2),d.info.orig.uct_offset);
    end
    d.qpd.q1     = dd.tracking.QPDsSecUsecVals(:,3);            % get data from individual 
    d.qpd.q2     = dd.tracking.QPDsSecUsecVals(:,4);            % quadrants and store them in 
    d.qpd.q3     = dd.tracking.QPDsSecUsecVals(:,5);			% d.qpd_0 : d.qpd_3
    d.qpd.q4     = dd.tracking.QPDsSecUsecVals(:,6);
    dd.tracking.QPDsSecUsecVals = []; %free up memory as we go    
end

if(strfind(fields,'l'))
    if(flags.keepuct)
        d.laser.time = removeToffset(dd.tracking.laserIntensitySecUsecVal(:,1:2),[0 0]);
    else
        d.laser.time = removeToffset(dd.tracking.laserIntensitySecUsecVal(:,1:2),d.info.orig.uct_offset);
    end 
    d.laser.intensity = dd.tracking.laserIntensitySecUsecVal(:,3);
    dd.tracking.laserIntensitySecUsecVal = []; %free up memory as we go    
end

if(strfind(fields,'e'))
    if(flags.keepuct)
        d.posError.time = removeToffset(dd.tracking.posErrorSecUsecXYZ(:,1:2),[0 0]);
    else
        d.posError.time = removeToffset(dd.tracking.posErrorSecUsecXYZ(:,1:2),d.info.orig.uct_offset);
    end    
    d.posError.x    = dd.tracking.posErrorSecUsecXYZ(:,3)*distscale;        % get x PostionError
    d.posError.y    = dd.tracking.posErrorSecUsecXYZ(:,4)*distscale;        % get y PostionError
    d.posError.z    = dd.tracking.posErrorSecUsecXYZ(:,5)*distscale;        % get z PostionError
    dd.tracking.posErrorSecUsecXYZ = []; %free up memory as we go    
end

if(strfind(fields,'g'))
    if(flags.keepuct)        
        d.gains.time = removeToffset(dd.tracking.gainsSecUsecPxyzIxyzDxyz(:,1:2),[0 0]);
    else
        d.gains.time = removeToffset(dd.tracking.gainsSecUsecPxyzIxyzDxyz(:,1:2), d.info.orig.uct_offset);
    end
    d.gains.PID = dd.tracking.gainsSecUsecPxyzIxyzDxyz(:,3:11); 
    dd.tracking.gainsSecUsecPxyzIxyzDxyz = []; %free up memory as we go
end

if(strfind(fields,'j'))
    names = fieldnames(dd.tracking);
    for c = 1:length(names)
%         'JacDataSecUsecQPDsStagesensors'
        if findstr(names{c},'JacData') % if this is JacobianData, then parse it
            d.Jacobian.FitData.stage = dd.tracking.(names{c})(:,7:9);
            d.Jacobian.FitData.qpd = dd.tracking.(names{c})(:,3:6);
            if flags.keepuct
                d.Jacobian.FitData.time = removeToffset(dd.tracking.(names{c})(:,1:2),[0 0]);
            else
                d.Jacobian.FitData.time = removeToffset(dd.tracking.(names{c})(:,1:2),d.info.orig.uct_offset);
            end
            dd.tracking.(names{c}) = [];%free up memory as we go
        elseif findstr(names{c},'Jac') % if the field name contains the string 'jac', take it as is.
            d.Jacobian.(names{c}) = dd.tracking.(names{c});
            dd.tracking.(names{c}) = [];%free up memory as we go
        end
    end
end
% compute the position of the bead at QPD bandwidth if bead position is
% requested
if(strfind(fields,'b'))
    if ~isfield(d,'stageReport') %is the stagesensed position parsed?
        ss.x = dd.tracking.stageSenseSecUsecXYZsense(:,3)*distscale;
        ss.y = dd.tracking.stageSenseSecUsecXYZsense(:,4)*distscale;
        ss.z = dd.tracking.stageSenseSecUsecXYZsense(:,5)*distscale;
        if(flags.keepuct)        
            ss.time = removeToffset(dd.tracking.stageSenseSecUsecXYZsense(:,1:2),[0 0]);
        else
            ss.time = removeToffset(dd.tracking.stageSenseSecUsecXYZsense(:,1:2), d.info.orig.uct_offset);
        end       
    else
        ss = d.stageReport;
    end
    if ~isfield(d,'posError') %is the position error parsed?
        pe.x    = dd.tracking.posErrorSecUsecXYZ(:,3)*distscale;        % get x PostionError
        pe.y    = dd.tracking.posErrorSecUsecXYZ(:,4)*distscale;        % get y PostionError
        pe.z    = dd.tracking.posErrorSecUsecXYZ(:,5)*distscale;        % get z PostionError       
        if(flags.keepuct)        
            pe.time = removeToffset(dd.tracking.posErrorSecUsecXYZ(:,1:2),[0 0]);
        else
            pe.time = removeToffset(dd.tracking.posErrorSecUsecXYZ(:,1:2), d.info.orig.uct_offset);
        end       
    else
        pe = d.posError;
    end
    d.beadpos.time = ss.time;
    % In the specimen coordinate frame, feedback moves the stage in the
    % opposite direction to the bead.
    d.beadpos.x = -ss.x(1:end) + pe.x(1:end);
    d.beadpos.y = -ss.y(1:end) + pe.y(1:end);
    d.beadpos.z = -ss.z(1:end) + pe.z(1:end);
    
    if ~flags.keepoffset %if we don't want offset in bead positions.
        d.beadpos.x = d.beadpos.x - d.beadpos.x(1,1);
        d.beadpos.y = d.beadpos.y - d.beadpos.y(1,1);
        d.beadpos.z = d.beadpos.z - d.beadpos.z(1,1);
    end
end

%-------------------------------------------------------------------------
% Subtract out the time-offset time-stamps without compromising resolution
function tout = removeToffset(tin, toffset)
tout_sec(:,1) = tin(:,1) - toffset(1,1);
tout_usec(:,1) = tin(:,2) - toffset(1,2);
inegs = find(tout_usec < 0); %indices where the difference went negative
tout_usec(inegs,1) = tout_usec(inegs,1) + 1E6;
tout_sec(inegs,1) = tout_sec(inegs,1) - 1;
tout = tout_sec + tout_usec*1e-6;
