function out = load_laser_tracking(file, fields, flags);
% 3DFM function
% Last modified: 12/21/05 -kvdesai
% Created: 10/12/05 - kvdesai
% 
% This function is supposed to replace the load_vrpn_tracking function. It performs 
% all the tasks that load_vrpn_tracking does but in a better and user friendly way.
% It reads in a 3DFM laser tracking dataset of the form .vrpn.mat. Laser Tracker
% program writes logfiles in .vrpn format and then they are converted to matlab compatible 
% .vrpn.mat format by vrpnLogToMatlab program. 
% load_laser_tracking is compatible to Laser Tracker versions 04.00 and
% beyond only. For datasets created by earlier versions of Laser Tracker,
% user load_vrpn_tracking.
% 
% USAGE:
% out = load_laser_tracking(file, fields, flags);
%
% INPUT PARAMETER DESCRIPTION: curly brackets indicate default values.
% 
% "file" : required arguement
%     it can be a string containing name of the the .mat file 
%     OR it can be the 'tracking' structure created by double-clicking the .mat file
%     OR it can be the .edited.mat file saved by lt_analysis_gui, in which
%           case "fields" and "flags" would be ignored. 
%     
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
%     If fields is not provided or left empty, it is defaulted to 'a'.
% 
% "flags": a structure containing binary (yes/no type) flags. Note, curly
%   brackets {} indicate default values.
%   flags.matoutput   = 1 | {0} : If 1, then output fields themselves would
%        matrices of the form [t vals], i.e., first column would be time stamp and rest would be the
%        signal values. Signal values would be [x,y,z] vectors for positon(bead/stage) and
%        voltages for QPD/laser signals.
%        If 0, then output fields themselves would be structures, as done traditionally.
%   flags.inmicrons   = {1} | 0 : Units of displacement [{microns} | meters]
%   flags.keepuct     = {1} | 0 : Keep all timestamps in UCT format or subtract
%                                out the offset such that time starts from zero
%   flags.keepoffset  = 1 | {0} : Only for BeadPosition. Keep the offset in position data or subtract
%                                it out? Removed by default.
%   flags.askforinput = 1 | {0} : While loading, ask user to type in metadata?
%        controls a prompt where custom information about a dataset can be typed in 
%        by the user. SPECIFYING 1 TURNS LOAD_LASER_TRACKING INTO A FUNCTION 
%        THAT REQUIRES USER INTERACTION, SO BATCH FILES WOULD HALT.
%   flags.filterstage = 1 | {0} : Lowpass filter stage-sensed values, 600 Hz cutoff
%        We know that stage has no motion beyond 600 Hz. Measured and verified
%        by talking to MCL engineers. So, here is the choice to remove all the 
%        electronic noise beyond 600 Hz.   
% 
% OUTPUT PARAMETER DESCRIPTION:
% If the input file is of .edited.mat format, 'out' is the output of 'load' command. Otherwise 'out' is
% a structure containg following fileds
%     .data (detailed description is given below)
%     .metadata (present only when user types in something with flags.askforinput set to 1)
%     .fname (filename)
%     .path (path)
% 'data' is a structure containing the fields that were requested.
%         The field names are exactly same as those given by load_vrpn_tracking.
%         Name of the fields in the 'data' structure:
%             .beadpos
%             .stageCom
%             .stageReport
%             .posError
%             .qpd
%             .laser
%             .gains
%             .Jacobian
%             .info
%     
% NOTES: The elder brother of this function 'load_vrpn_tracking' may get
% obsolete at some point. It is encouraged to use this function instead.
global dd  % make the original dataset global to avert multiple copies
global ceglqs % the cell array containing names of the fields in original .mat file

%  the cell array containing names of some of the fields in original .mat file
cegjlqs = {'stageCommandSecUsecZeroXYZ', ... 
          'posErrorSecUsecXYZ', ...
          'gainsSecUsecPxyzIxyzDxyz', ... 
          'JacDataSecUsecQPDsStagesensors', ...
          'laserIntensitySecUsecVal', ...
          'QPDsSecUsecVals', ...
          'stageSenseSecUsecXYZsense'};
THIS_IS_POS = 1;          
% handle the argument list
if (nargin < 3 | isempty(flags))
    flags.inmicrons = 1;         
    flags.keepuct = 1;
    flags.askforinput = 0;
    flags.keepoffset = 0;
    flags.matoutput = 0;
    flags.filterstage = 0;
else
    % fill in the missing fields
    if (~isfield(flags,'inmicrons')); flags.inmicrons = 1; end;
    if (~isfield(flags,'keepuct')); flags.keepuct = 1; end;
    if (~isfield(flags,'askforinput')); flags.askforinput = 0; end;
    if (~isfield(flags,'keepoffset')); flags.keepoffset = 0; end;
    if (~isfield(flags,'matoutput')); flags.matoutput = 0; end;
    if (~isfield(flags,'filterstage')); flags.filterstage = 0; end;
end

if (nargin < 2 | isempty(fields));  fields = 'a';       end;

%if requested to provide all the fields then make the field vector contain all the characters
if strfind(fields,'a')
    fields = 'bcegjlqs';
end

% Take care of all version records
version_string = '02.00';
LTver = 'NotAvailable';
V2Mver = 'NotAvailable';
d.info.orig.matOutputFileName = 'NotAvailable';
d.info.orig.LoadLaserTrackingVersion = version_string;

% load tracking data after it has been converted to a .mat file OR
% if it is saved by lt_analysis_gui OR
% if it is present as a workspace variable 
if(ischar(file)) % file contains the name of the file as a string
    if findstr(file,'.vrpn.mat')
        % 'file' is the original, unedited, .vrpn.mat log file
        dd= load(file);
        % get filename by subtracting filepath
        id = max(find(file(:)=='\'));
        if(isempty(id))
            out.fname = file;
            out.path = pwd;
        else
            out.fname = file(id+1:end);
            out.path = file(1:id);
        end
        % load in the version info etc metadata from the vrpn.mat file
        if isfield(dd.tracking,'info')
            d.info.orig = dd.tracking.info;
        else            
            d.info.orig.matOutputFileName = out.fname ;            
        end            
    elseif findstr(file,'.edited.mat')
        % file is saved by lt_analysis_gui tool
        load(file); % saved as a structure named 'edited'
        out = edited;
        return;
    else
        error('Unrecognied file format, only know about .vrpn.mat and .edited.mat formats');
    end
else % 'file' is a variable present in the workspace
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
else
    d.info.orig.xyzunits = 'm';
end

% handle the switch for including metadata that user types in
if flags.askforinput
    out.metadata =  input(['Type any extra information you \n', ...
            'want to be associated with this data set \n',...
            'Press Enter only when you are done\n'],'s');
end

% handle the time-offset
% determine who started logging earliest: JacData or QPD?
if(isfield(dd.tracking,cegjlqs{4}))
    if(removeToffset(dd.tracking.(cegjlqs{4})(1,1:2), dd.tracking.(cegjlqs{6})(1,1:2)) < 0)
        d.info.orig.uct_offset = dd.tracking.(cegjlqs{4})(1,1:2); %JacData started earlier
    else
        d.info.orig.uct_offset = dd.tracking.(cegjlqs{6})(1,1:2);%QPD started earlier
    end
else
    d.info.orig.uct_offset = dd.tracking.(cegjlqs{6})(1,1:2);
end

d.info.orig.filterstage = flags.filterstage; % was stage filtered?

if(flags.keepuct)
    Toffset = [0 0];
else
    Toffset = [d.info.orig.uct_offset];
end

% Now parse in the fields 

if(strfind(fields,'c')) % handle stage command logs
    strs = {'','x','y','z'}; %ignore the first column since it is index of tracker in vrpn
    d.stageCom = extractfield(cegjlqs{1},flags,strs,Toffset,THIS_IS_POS);
end

if(strfind(fields,'s')) % handle stage sensed positions
    d.stageReport = extractfield(cegjlqs{7},flags,{'x','y','z'},Toffset,THIS_IS_POS);
end

if(strfind(fields,'q')) % handle qpd signals
    d.qpd = extractfield(cegjlqs{6},flags,{'q1','q2','q3','q4'},Toffset,~THIS_IS_POS);
end

if(strfind(fields,'l')) % handle laser intensity
    d.laser = extractfield(cegjlqs{5},flags,{'intensity'},Toffset,~THIS_IS_POS);
end

if(strfind(fields,'e')) % handle position errors
    d.posError = extractfield(cegjlqs{2},flags,{'x','y','z'},Toffset,THIS_IS_POS);
end

if(strfind(fields,'g')) % handle PID controller gains
    d.gains = extractfield(cegjlqs{3},flags,{'Px','Py','Pz','Ix','Iy','Iz','Dx','Dy','Dz'},Toffset,~THIS_IS_POS);
end

if(strfind(fields,'j'))  % handle Jacobian and JacobianData
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

% compute the position of the bead at QPD bandwidth if bead position is requested
if(strfind(fields,'b'))
    if ~isfield(d,'stageReport') %is the stagesensed position parsed?
        ss = extractfield(cegjlqs{7},flags,{'x','y','z'},Toffset,THIS_IS_POS);
    else
        ss = d.stageReport;
    end
    if ~isfield(d,'posError') %is the position error parsed?
        pe = extractfield(cegjlqs{2},flags,{'x','y','z'},Toffset,THIS_IS_POS);
    else
        pe = d.posError;
    end
    
    if flags.matoutput
        d.beadpos(:,1) = ss(:,1);
        % In the laer coordinate frame, feedback moves the stage in the
        % opposite direction to compensate for the motion of the bead.    
        d.beadpos(:,2:4) = -ss(:,2:4) + pe(:,2:4);
        if ~flags.keepoffset
            d.beadpos(:,2:4) = d.beadpos(:,2:4) - repmat(d.beadpos(1,2:4),size(d.beadpos,1),1);
        end
    else
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
    clear ss pe %clear memory as we go
end
out.data = d;

%-------------------------------------------------------------------------
% Subtract out the time-offset from time-stamps without compromising resolution
function tout = removeToffset(tin, toffset)
tout_sec(:,1) = tin(:,1) - toffset(1,1);
tout_usec(:,1) = tin(:,2) - toffset(1,2);
inegs = find(tout_usec < 0); %indices where the difference went negative
if ~isempty(inegs) % would be empty when toffset is zero
    tout_usec(inegs,1) = tout_usec(inegs,1) + 1E6;
    tout_sec(inegs,1) = tout_sec(inegs,1) - 1;
end
tout = tout_sec + tout_usec*1e-6;

%-------------------------------------------------------------------------
% a common algorithm to extract the requested field. 
% fin = input [N x M] matrix (e.g. dd.QPDsSecUsecVals)
% flags = flags indicating how to extract the data
% strs = names of fields in the output when output type is requested to be 
%        a structure
% toffset = Time-offset that needs to be subtracted out
% fout = output matrix Or structure
function fout = extractfield(fin_name,flags,strs,toffset,ispos)
global dd %declaring global conserves lot of memory for huge datasets
MCL_CUTOFF_HZ = 600;
t = removeToffset(dd.tracking.(fin_name)(:,1:2),toffset);

if length(strs) ~= (size(dd.tracking.(fin_name),2) - 2)
    disp('load_laser_tracking::Warning: No of columns & No of field names do not match');
    disp(['for signal: ',fin_name,'...data fields OR columns will be truncated']);    
end

if ispos % if this is a position measurement, handle the units
    if flags.inmicrons
    % At least upto Laser Tracker version 04.14, the position data in tracking log 
    % is in units of microns. If it changes later,  change the scale here.
        scale = 1;
    else
        scale = 1E-6;
    end
else
    scale = 1;
end

M = min(length(strs),size(dd.tracking.(fin_name),2)-2);
if flags.matoutput
    fout(:,1) = t;   
else
    fout.time = t;
end
% if this is stage-sensed positions, and if we are told to filter it
% then do so
if strfind(fin_name,'stageSense') & (flags.filterstage == 1)
    if (range(diff(t)) > 1e-6)            
        disp('load_laser_tracking: User requested to filter stage sensed positions, but time-stamps were unever.');
        disp('I will upsample the data at 10000 Hz, filter it, and then resample at the original time stamps');
        srate = 10000;        
        teven = [t(1):1/srate:t(end)]';
        for k = 1:M;
            sig(:,k) = interp1(t,dd.tracking.(fin_name)(:,k+2),teven);
        end
        downsample = 1;        
    else        
        sig(:,1:M) = dd.tracking.(fin_name)(:,3:M+2);
        downsample = 0;        
        srate = 1/mean(diff(t));
    end
    [filt.b,filt.a] = butter(4, MCL_CUTOFF_HZ*2/srate);    
    for cl = 1:size(sig,2)
        filtsig(:,cl) = filtfilt(filt.b,filt.a,sig(:,cl));
    end
    % IF data was upsampled to apply filtering, downsample at the original
    % timestamps so that size of posError and stageReport arrays are same.
    if downsample
        for cl = 1:M
            dd.tracking.(fin_name)(:,cl+2) = interp1(teven,filtsig(:,cl),t);
        end
    else
        dd.tracking.(fin_name)(:,3:M+2) = filtsig;
    end
    clear sig filtsig teven
    disp(['stage sensed positions were filtered with ',num2str(MCL_CUTOFF_HZ),' Hz cutoff']);
end

% Now readin the values and put them in the appropriate form
k = 1; % 1 column occupied by time 
for c = 1:M
    if isempty(strs{c})
        continue; %ignore the column if corresponding name is empty
    end    
    if flags.matoutput
        k = k+1;
        fout(:,k) = dd.tracking.(fin_name)(:,c+2).*scale;        
    else
        fout.(strs{c}) = dd.tracking.(fin_name)(:,c+2).*scale;        
    end
end
dd.tracking.(fin_name) = []; % free up memory as we go  
