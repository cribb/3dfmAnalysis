function out = load_laser_tracking(file, fields, flags);
% 3DFM function
% Last modified: 06/16/06 -kvdesai
% Created: 10/12/05 - kvdesai
% 
% load_laser_tracking loads two types of laser tracking datasets
% 1. Dataset of the format .vrpn.mat, produced by vrpnLogToMatlab program.
% 2. Dataset saved by lt_analysis_gui, of the format .edited.mat
% 
% Laser Tracker program writes logfiles in .vrpn format and then they are 
% converted to matlab compatible .vrpn.mat format by vrpnLogToMatlab program. 
% load_laser_tracking reads in a 3DFM laser tracking dataset of the form .vrpn.mat.
% load_laser_tracking is compatible to Laser Tracker versions 04.00 and
% beyond only. For datasets created by earlier versions of Laser Tracker,
% user load_vrpn_tracking. load_laser_tracking is supposed to replace the 
% load_vrpn_tracking function. It performs all the tasks that load_vrpn_tracking 
% does but in a better and user friendly way.
% 
% USAGE:
% out = load_laser_tracking(file, fields, flags);
%
% INPUT PARAMETER DESCRIPTION: curly brackets indicate default values.
% 
% "file" : required arguement
%     it can be a string containing name of the the .mat file 
%     OR it can be the 'tracking' structure created by double-clicking the .mat file
%     OR it can be the .edited.mat file saved by lt_analysis_gui.
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
%             .beadpos = bead position in specimen coordinate frame
%             .stageCom = stage drive signal
%             .stageReport = stage sensed positions
%             .posError = position of the beam relative to beam
%             .qpd = qpd signals (volts)
%             .laser = laser intensity or whatever was plugged into ADC Ch8%     
%             .gains = PID controller gains
%             .QtoPmap = The mapping from QPD signals to XYZ positions
%             .info = metadata
%                   .flags = flags that were used 
%                   .orig = metadata added if input is .tracking.vrpn.mat
%                           file.                                   
%                   .orig.vrpnLogToMatlabVersion
%                        .LaserTrackerVersion
%                        .vrpnRawFileName = when file was creatd by laser
%                                           tracker
%                        .perturbationProperties
%                        .matOutputFileName = when file was converted to
%                                           .mat
%                        .xyzunits = position units for the original data 
%                                       microns ('u') or meters('m')
%                        .uct_offset= UCT offset (seconds) for the file
%                        .beadpos_offset = offset in the beadposition
% NOTES: The elder brother of this function 'load_vrpn_tracking' may get
% obsolete at some point. It is encouraged to use this function instead.
global dd  % make the original dataset global to avert multiple copies

%  the cell array containing names of the fields in original vrpn.mat file
bcegjlqs.in = {'','stageCommandSecUsecZeroXYZ', ... 
          'posErrorSecUsecXYZ', ...
          'gainsSecUsecPxyzIxyzDxyz', ... 
          'JacDataSecUsecQPDsStagesensors', ...
          'laserIntensitySecUsecVal', ...
          'QPDsSecUsecVals', ...
          'stageSenseSecUsecXYZsense'};
% the cell array containing names of the fields in output file
bcegjlqs.out = {'beadpos', ... 
          'stageCom', ...
          'posError', ...
          'gains', ... 
          'QtoPmap', ...
          'laser', ...
          'qpd', ...
          'stageReport'};
fmaster = 'bcegjlqs'; % the string containg the name of the structure that 
                    % contains the order of the input/output field names.
                    % MUST BE SAME as the name of the structure above.
THIS_IS_POS = 1;          
% handle the argument list
if (nargin < 3) % no flags are supplied
    flags = []; % so that we don't have to copy the defaulting code for flags
end
    % set the missing flags to default values
    if (~isfield(flags,'inmicrons')); flags.inmicrons = 1; end;
    if (~isfield(flags,'keepuct')); flags.keepuct = 1; end;
    if (~isfield(flags,'askforinput')); flags.askforinput = 0; end;
    if (~isfield(flags,'keepoffset')); flags.keepoffset = 0; end;
    if (~isfield(flags,'matoutput')); flags.matoutput = 0; end;
    if (~isfield(flags,'filterstage')); flags.filterstage = 0; end;

if (nargin < 2 | isempty(fields));  fields = 'a';       end; % all fields by default


%if requested to provide all the fields then make the field vector contain all the characters
if strfind(fields,'a')
    fields = 'bcegjlqs';
end

% Take care of all version records
version_string = '02.01';
LTver = 'NotAvailable';
V2Mver = 'NotAvailable';
d.info.orig.matOutputFileName = 'NotAvailable';
d.info.orig.LoadLaserTrackingVersion = version_string;

% load tracking data after it has been converted to a .mat file OR
% if it is saved by lt_analysis_gui OR
% if it is present as a workspace variable 
if(ischar(file)) % file contains the name of the file as a string
    % get filename by subtracting filepath
    islash = max(find(file(:)=='\'));
    if(isempty(islash))
        thisname = file;
        thispath = pwd;
    else
        thisname = file(islash+1:end);
        thispath = file(1:islash);
    end
    if findstr(file,'.vrpn.mat')
        % 'file' is the original, unedited, .vrpn.mat log file
        dd= load(file);        
        out.fname = thisname;
        out.path = thispath;
        % load in the version info etc metadata from the vrpn.mat file
        if isfield(dd.tracking,'info')
            d.info.orig = dd.tracking.info;
        else            
            d.info.orig.matOutputFileName = out.fname ;            
        end            
    elseif findstr(file,'.edited.mat')
        % file is saved by lt_analysis_gui tool
        load(file); % saved as a structure named 'edited'
        % Now compare the name of the file that is stored in the file
        % itself with the current name of the file.
        if ~strcmp(thisname,edited.fname)
            edited.previousname = edited.fname;
            edited.fname = thisname;
        end
        if ~strcmp(thispath,edited.path)
            edited.previouspath = edited.path;
            edited.path = thispath;
        end
        %-----------------------
        % Check that all requested fields are present in edited.mat file.
        new_fields = fields;
        for cf = 1:length(fields)
            ihere = findstr(fmaster,fields(cf)); %index of this field
            if ~isfield(edited.data, bcegjlqs.out{ihere})
                disp([' WARNING: Requested field, ',bcegjlqs.out{ihere},' is not ', ...
                    'present in the input .edited.mat file. Can not load.'])
                disp('To fix, re-load original .vrpn.mat file with correct flags and save');
                new_fields = setdiff(new_fields,fields(cf));
            end
        end
        fields = new_fields; clear new_fields;       
        % Now compare the flags that were used to load this file last time
        % with flags that are supposed to be used to load the file this
        % time, and handle offsets + scales accordingly.
        last_flags = edited.data.info.flags;
        %-----------------------
        % First, handle the offset in bead position if requested
        % This has to be done in the same units in which the information
        % about the offset is stored. SO we have to handle this before
        % changing units of the position.
        if ~isequal(last_flags.keepoffset, flags.keepoffset) && findstr(fields,'b')
            if flags.keepoffset% input: no offset, output: need offset
                posadjust = -edited.data.info.beadpos_offset;
            else % input: has offset, output: need zero offset
                posadjust = edited.data.info.beadpos_offset;
            end
            edited.data.(bcegjlqs.out{1}) = ...
                removePosOffset(edited.data.(bcegjlqs.out{1}),posadjust,last_flags.matoutput);
        end
        %-----------------------
        % Second, handle the Time offset
        if ~isequal(last_flags.keepuct, flags.keepuct)
            twocoloffset = edited.data.info.orig.uct_offset;
            if flags.keepuct ==1 % input: time relative to start of experiment                
                tadjust = -(twocoloffset(1) + twocoloffset(2)*1E-6); %add the offset
            else %input: time relative to 1st Jan 1970 midnight.
                tadjust = -(twocoloffset(1) + twocoloffset(2)*1E-6); %subtract offset
            end
            for cf = 1:length(fields)
                ihere = findstr(fmaster,fields(cf)); %index of this field
                if ihere == 5, continue; end; %don't dare to adjust jacobian data
                if last_flags.matoutput
                    edited.data.(bcegjlqs.out{ihere})(:,1) = ...
                        edited.data.(bcegjlqs.out{ihere})(:,1) - tadjust;
                else
                    edited.data.(bcegjlqs.out{ihere}).t = ...
                        edited.data.(bcegjlqs.out{ihere}).t - tadjust;
                end                
            end       
        end
        %-----------------------
        % Third, handle the displacement units: meters or microns?
        if ~isequal(last_flags.inmicrons, flags.inmicrons)
            if flags.inmicrons == 0               
                %output requested in meters, input loaded in microns, 
               fmult = 1E-6;
            else%output requested in microns, input loaded in meters,
               fmult = 1E6;
            end
            for cf = 1:length(fields)
                switch fields(cf)
                    case {'b','e','s'} % the position signals
                       ihere = findstr(fmaster,fields(cf)); %index of this field
                       edited.data.(bcegjlqs.out{ihere}) = ...
                           scaleme(edited.data.(bcegjlqs.out{ihere}),fmult,last_flags.matoutput);
                       edited.drift.(bcegjlqs.out{ihere}) = edited.drift.(bcegjlqs.out{ihere})*fmult;
                    case 'j' % Data used to fit the QtoP map
                        if isfield(edited.data.(bcegjlqs.out{6}),'FitData')
                            edited.data.(bcegjlqs.out{6}).stage = edited.data.(bcegjlqs.out{6}).stage*fmult;
                        end % ignore if we have QtoP map but no fitting data.                        
                    otherwise % ignore all other fields which are not positions                        
                end
            end
        end
        %-----------------------
        % Fourth, if the user has requested to change the format of the
        % output from structure to matrix, (or from matrix to structure),
        % tell that it is impossible to do because we don't know the
        % field-names in the structure format and how they are ordered in the corresponding
        % matrix format.
        if ~isequal(last_flags.matoutput, flags.matoutput)           
            if flags.matoutput %input: structure, output: matrix
                disp('WARNING: requested to convert output format from structure to matrix.');
                disp('Do not know how to. Output will be given in the structure form only.');
                disp('To fix, re-load original .vrpn.mat file with correct flags and save');                            
            else %input: matrix, output: structure
                disp('WARNING: requested to convert output format from matrix to structure.');
                disp('Do not know how to. Output will be given in the matrix form only.');
                disp('To fix, re-load original .vrpn.mat file with correct flags and save');
            end
            flags.matoutput = last_flags.matoutput;
        end
        %-----------------------
        % Fifth, if the user has requested to change the filterstage flag then
        % in the case where user has asked to filter the stage position,
        % check that either (bead position and position error) or stage position 
        % is present in the old data. Otherwise, tell that it is impossible 
        % to change the flag becuase we can't un-filter once
        % filtered; or we don't know the component of stage position in
        % bead position.
        if ~isequal(last_flags.filterstage, flags.filterstage)
            if flags.filterstage == 1 
                if isfield(edited.data,bcegjlqs.out{1}) & isfield(edited.data,bcegjlqs.out{3})
                    oldb = edited.data.(bcegjlqs.out{1});
                    olde = edited.data.(bcegjlqs.out{3});
                    oldt = olde(:,1);
                    oldpos = olde(:,2:4) - oldb(:,2:4);
                    filtpos = filterMCLsense(oldt, oldpos);
                    % For now assuming that only 'matrix output' formatted
                    % files will need this functionality
                    edited.data.(bcegjlqs.out{8}) = [oldt,filtpos];
                    clear oldb olde oldt filtpos oldpos 
                    flags.filterstage = 1;
                elseif isfield(edited.data,bcegjlqs.out{8})
                    oldstage = edited.data.(bcegjlqs.out{8});
                    filtpos = filterMCLsense(oldstage(:,1),oldstage(:,2:4));
                    edited.data.(bcegjlqs.out{8}) = [oldstage(:,1), filtpos];
                    clear oldstage filtpos
                    flags.filterstage = 1;
                else
                    disp('WARNING: User requested to filter the stage sensed positions.');
                    disp('Cannot find or compute the original stage positions in the input .edited.mat file.');
                    disp('To fix, re-load original .vrpn.mat file with correct flags and save.');
                    flags.filterstage = last_flags.filterstage;
                end
            else
                disp('WARNING: requested to unfilter previously filtered stage positions.');
                disp('Impossible.');
                disp('To fix, re-load original .vrpn.mat file with correct flags and save');
                flags.filterstage = last_flags.filterstage;
            end
        end
        %-----------------------
        edited.data.info.flags = flags;
        out = edited;
        return;        
    else
        error('Unrecognized file format, only know about .vrpn.mat and .edited.mat formats');
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
% determine who was first to start logging: JacData or QPD?
if(isfield(dd.tracking,bcegjlqs.in{1+4}))
    if(removeToffset(dd.tracking.(bcegjlqs.in{1+4})(1,1:2), dd.tracking.(bcegjlqs.in{1+6})(1,1:2)) < 0)
        d.info.orig.uct_offset = dd.tracking.(bcegjlqs.in{1+4})(1,1:2); %JacData started earlier
    else
        d.info.orig.uct_offset = dd.tracking.(bcegjlqs.in{1+6})(1,1:2);%QPD started earlier
    end
else
    d.info.orig.uct_offset = dd.tracking.(bcegjlqs.in{1+6})(1,1:2);
end

if(flags.keepuct)
    Toffset = [0 0];
else
    Toffset = [d.info.orig.uct_offset];
end

% Now parse in the fields

if(strfind(fields,'c')) % handle stage command logs
    strs = {'','x','y','z'}; %ignore the first column since it is index of tracker in vrpn
    d.(bcegjlqs.out{2}) = extractfield(bcegjlqs.in{1+1},flags,strs,Toffset,THIS_IS_POS);
end
if(strfind(fields,'s')) % handle stage sensed positions
    d.(bcegjlqs.out{8}) = extractfield(bcegjlqs.in{1+7},flags,{'x','y','z'},Toffset,THIS_IS_POS);
end
if(strfind(fields,'q')) % handle qpd signals
    d.(bcegjlqs.out{7}) = extractfield(bcegjlqs.in{1+6},flags,{'q1','q2','q3','q4'},Toffset,~THIS_IS_POS);
end
if(strfind(fields,'l')) % handle laser intensity OR ADC channel 8 signal
    d.(bcegjlqs.out{6}) = extractfield(bcegjlqs.in{1+5},flags,{'intensity'},Toffset,~THIS_IS_POS);
end

if(strfind(fields,'e')) % handle position errors
    d.(bcegjlqs.out{3}) = extractfield(bcegjlqs.in{1+2},flags,{'x','y','z'},Toffset,THIS_IS_POS);
end

if(strfind(fields,'g')) % handle PID controller gains
    d.(bcegjlqs.out{4}) = extractfield(bcegjlqs.in{1+3},flags,{'Px','Py','Pz','Ix','Iy','Iz','Dx','Dy','Dz'},Toffset,~THIS_IS_POS);
end

if(strfind(fields,'j'))  % handle Jacobian and JacobianData. This field is renamed to QtoPmap.
    names = fieldnames(dd.tracking);
    for c = 1:length(names)
%         'JacDataSecUsecQPDsStagesensors'
        if findstr(names{c},'JacData') % if this is JacobianData, then parse it
            d.(bcegjlqs.out{5}).FitData.stage = dd.tracking.(names{c})(:,7:9);
            d.(bcegjlqs.out{5}).FitData.qpd = dd.tracking.(names{c})(:,3:6);
            if flags.keepuct
                d.(bcegjlqs.out{5}).FitData.time = removeToffset(dd.tracking.(names{c})(:,1:2),[0 0]);
            else
                d.(bcegjlqs.out{5}).FitData.time = removeToffset(dd.tracking.(names{c})(:,1:2),d.info.orig.uct_offset);
            end
            dd.tracking.(names{c}) = [];%free up memory as we go
        elseif findstr(names{c},'Jac') % if the field name contains the string 'jac', take it as is.
            d.(bcegjlqs.out{5}).(names{c}) = dd.tracking.(names{c});
            dd.tracking.(names{c}) = [];%free up memory as we go
        end
    end
end
% compute the position of the bead at QPD bandwidth if bead position is requested
if(strfind(fields,'b')) 
    if ~isfield(d,bcegjlqs.out{8}) %is the stagesensed position parsed?
        ss = extractfield(bcegjlqs.in{1+7},flags,{'x','y','z'},Toffset,THIS_IS_POS);
    else
        ss = d.(bcegjlqs.out{8});
    end
    if ~isfield(d,bcegjlqs.out{3}) %is the position error parsed?
        pe = extractfield(bcegjlqs.in{1+2},flags,{'x','y','z'},Toffset,THIS_IS_POS);
    else
        pe = d.(bcegjlqs.out{3});
    end
    if flags.matoutput
        d.(bcegjlqs.out{1})(:,1) = ss(:,1);
        % In the laer coordinate frame, feedback moves the stage in the
        % opposite direction to compensate for the motion of the bead.    
        d.(bcegjlqs.out{1})(:,2:4) = -ss(:,2:4) + pe(:,2:4);
        if ~flags.keepoffset
            d.(bcegjlqs.out{1})(:,2:4) = d.(bcegjlqs.out{1})(:,2:4) - repmat(d.(bcegjlqs.out{1})(1,2:4),size(d.(bcegjlqs.out{1}),1),1);
        end
        d.info.orig.beadpos_offset(1,1:3) = d.(bcegjlqs.out{1})(1,2:4);
    else
        d.(bcegjlqs.out{1}).time = ss.time;
        % In the specimen coordinate frame, feedback moves the stage in the
        % opposite direction to the bead.
        d.(bcegjlqs.out{1}).x = -ss.x(1:end) + pe.x(1:end);
        d.(bcegjlqs.out{1}).y = -ss.y(1:end) + pe.y(1:end);
        d.(bcegjlqs.out{1}).z = -ss.z(1:end) + pe.z(1:end);        
        if ~flags.keepoffset %if we don't want offset in bead positions.
            d.(bcegjlqs.out{1}).x = d.(bcegjlqs.out{1}).x - d.(bcegjlqs.out{1}).x(1,1);
            d.(bcegjlqs.out{1}).y = d.(bcegjlqs.out{1}).y - d.(bcegjlqs.out{1}).y(1,1);
            d.(bcegjlqs.out{1}).z = d.(bcegjlqs.out{1}).z - d.(bcegjlqs.out{1}).z(1,1);
        end
        d.info.orig.beadpos_offset.x = d.(bcegjlqs.out{1}).x(1);
        d.info.orig.beadpos_offset.y = d.(bcegjlqs.out{1}).y(1);
        d.info.orig.beadpos_offset.z = d.(bcegjlqs.out{1}).z(1);
    end

    clear ss pe %clear memory as we go
end
d.info.flags = flags; %pass on flags that were used for this session
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
% handle scaling of displacements when .edited file units are different
% than requested.
function posout = scaleme(posin,fmult,matoutput)

if matoutput == 0
    posout.t = posin.t;
    posout.x = posin.x*fmult;
    posout.y = posin.y*fmult;
    posout.z = posin.z*fmult;
else
    posout(:,1) = posin(:,1);
    posout(:,2:4) = posin(:,2:4)*fmult;
end

%-------------------------------------------------------------------------
% handle offsets in the displacements 
function posout = removePosOffset(posin,posoffset,matoutput)
if matoutput == 0
    posout.t = posin.t;
    posout.x = posin.x - posoffset.x;
    posout.y = posin.y - posoffset.y;
    posout.z = posin.z - posoffset.z;
else
    posout(:,1) = posin(:,1);
    posout(:,2:4) = posin(:,2:4)-repmat(posoffset,size(posin,1),1);
end

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
% if this is stage-sensed positions, then filter it if we are told to do so
% -------------------------------------------------------------
if strfind(fin_name,'stageSense') & (flags.filterstage == 1)
    pos = dd.tracking.(fin_name)(:,3:M+2);
    filtpos = filterMCLsense(t,pos);
    dd.tracking.(fin_name)(:,3:M+2) = filtpos;    
end
% Now read in the values and put them in the appropriate form
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

% ----------   FILETERING STAGE SENSED POSITIONS  -------------------------
function filtpos = filterMCLsense(t, pos)
% NOTE: Can not use global dd here, because in the case of edited file,
% there won't be any dd.
MCL_CUTOFF_HZ = 600;
M = size(pos,2);

if (range(diff(t)) > 1e-6)
    disp('load_laser_tracking: User requested to filter stage sensed positions, but time-stamps were uneven.');
    disp('I will upsample the data at 10000 Hz, filter it, and then resample at the original time stamps');
    srate = 10000;
    teven = [t(1):1/srate:t(end)]';
    for k = 1:M;
        sig(:,k) = interp1(t,pos(:,k),teven);
    end
    downsample = 1;
else
    sig(:,1:M) = pos(:,1:M);
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
        filtpos(:,cl) = interp1(teven,filtsig(:,cl),t);
    end
else
    filtpos = filtsig;
end
disp(['stage sensed positions were filtered with ',num2str(MCL_CUTOFF_HZ),' Hz cutoff']);