function dat = load_agnostic_tracking(fileName, flags)
% Parse the laser-tracking log file for the purpose of analyzing agnostic tracking
% compatible with LaserTracker version 03.02 and later.
% USAGE: dat = load_agnostic_tracking(fileName, flags)
% "Always Present" fields in the output structure dat:
%   dat.info.name
%         .ver.loadAT_m
%   dat.t
%   dat.peidle
%   dat.ssense
%   dat.qpd
%   dat.stageCom.t
%               .xyz
%
% "Could be present" fields in the output structure dat:
%   dat.peactive.t
%               .xyz
%   dat.jilin(N,1).tstart
%                 .qgoals
%                 .iblip(1,2)
%                 .jac(4,3)
%                 .qpd
%                 .ssense
%   dat.jalin(N,1).tupdate
%                 .qgoals
%                 .jac(4,3)
%   dat.jacold(1) - fields same as jilin
%   dat.ji2nd - fields same as jilin except change in jacobian dimension
%   dat.ja2nd - fields same as jalin except change in jacobian dimension
% 
%   dat.gains.t
%            .PID
% LAST MODIFIED:    1 September 2005, by kvdesai
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbstop if error
VERSION = '1.3';
if (nargin < 2 | ~isfield(flags,'verbose'));  flags.verbose=1;         end;%print messages loudly by default
if (nargin < 2 | ~isfield(flags,'remtoff'));  flags.remtoff=1;         end;%subtract out the offset in timestamps by default
if (nargin < 2 | ~isfield(flags,'concise')); flags.concise = 0;        end;%return full dataset by default
if(flags.verbose)
    disp(['load_agnostic_tracking :: version ', VERSION]);
end
pack
dat = [];

load(fileName);
d = tracking; clear tracking;

if(isfield(d,'info'))
    dat.info = d.info;
    if(isfield(d.info,'perturbationProperties'))
        noiseinfo = d.info.perturbationProperties;
    end
else
    dat.info.LaserTrackerVersion = '03.02'; %hack
    noiseinfo = '';
end
% dat.info.name = fileName;
dat.info.loadATmVersion = VERSION;
%First check that this is an appropriate file for Agnostic tracking
%analysis. Do this by looking for atleast one filedName containing 'jac'
names = fieldnames(d);
% if (verbose)
%     disp('Below are the fields I got:');
%     disp(names);
% end
LTver = str2double(dat.info.LaserTrackerVersion(1,1:5)); %convert first five characters into a number
if (flags.verbose)
    disp(['Found Version of the laser tracker: ', num2str(LTver)]);
end

if (isempty(strmatch('Jac',names)))
    disp('SURPRISE! SURPRISE! There is no field containing Jacobian relevant information');
    disp('Are you sure this is the correct file?...See for yourself!');
    keyboard
end

%Now since Jacobian information is there, there must be three other
%fields : stageSense, QPD and PosError. This is true atleast for Laser
%Tracker version 03.02 to 04.00 and should be true for later versions too.
%Check that the three fields are indeed there. 
if((~isfield(d,'posErrorSecUsecXYZ')) | (~isfield(d,'stageSenseSecUsecXYZsense')) | (~isfield(d,'QPDsSecUsecVals')))
    disp('SURPRISE! SURPRISE! One or more of the following fields are absent:');
    disp([{'posErrorSecUsecXYZ'};{'stageSenseSecUsecXYZsense'};{'QPDsSecUsecVals'}]);
    disp('Do you think you have taught me to process this type of file?...See for yourself!');
    keyboard
end

%Now check if the time-stamps of the above three fields are identical
if((~isequal(d.posErrorSecUsecXYZ(:,2), d.QPDsSecUsecVals(:,2), d.stageSenseSecUsecXYZsense(:,2)))...
        | (~isequal(d.posErrorSecUsecXYZ(:,1), d.QPDsSecUsecVals(:,1), d.stageSenseSecUsecXYZsense(:,1))))
    disp('TimeStamps of of stage,qpd and posError fields are not identical...');
    disp('You haven''t taught me to process this type of file...Look into it!');
    keyboard
else    
    if(flags.remtoff)
        % determine which is Toffset, the JacData's first sample or, QPDs
        % first sample
        if(isfield(d,'JacDataSecUsecQPDsStagesensors'))
            if(removeToffset(d.JacDataSecUsecQPDsStagesensors(1,1:2), d.QPDsSecUsecVals(1,1:2)) < 0)
                dat.info.Toffset = d.JacDataSecUsecQPDsStagesensors(1,1:2);
            else
                dat.info.Toffset = d.QPDsSecUsecVals(1,1:2);
            end
        else
            dat.info.Toffset = d.QPDsSecUsecVals(1,1:2);
        end
        
        dat.t = removeToffset([d.QPDsSecUsecVals(:,1),d.QPDsSecUsecVals(:,2)], dat.info.Toffset);
    else
        dat.t = d.QPDsSecUsecVals(:,1) + d.QPDsSecUsecVals(:,2)*1E-6;
    end
end
pack
if (~flags.concise)
    dat.peidle = d.posErrorSecUsecXYZ(:,3:5);
    % keep freeing memory as we go
    d.posErrorSecUsecXYZ = [];
end
dat.ssense = d.stageSenseSecUsecXYZsense(:,3:5);
d.stageSenseSecUsecXYZsense = [];
dat.qpd = d.QPDsSecUsecVals(:,3:6);
d.QPDsSecUsecVals = [];

if(isfield(d,'posErrorActiveSecUsecXYZ') & (~flags.concise)) %if we have ActivePositionErrors computed 
    if(flags.remtoff)        
        dat.peactive.t = removeToffset([d.posErrorActiveSecUsecXYZ(:,1),d.posErrorActiveSecUsecXYZ(:,2)], dat.info.Toffset);
    else
        dat.peactive.t = d.posErrorActiveSecUsecXYZ(:,1) + d.posErrorActiveSecUsecXYZ(:,2)*1E-6;
    end    
    dat.peactive.xyz = d.posErrorActiveSecUsecXYZ(:,3:5);
    d.posErrorActiveSecUsecXYZ = [];
end

if(isfield(d,'JacDataSecUsecQPDsStagesensors')) 
    if(flags.remtoff)        
        dat.JacData.t = removeToffset([d.JacDataSecUsecQPDsStagesensors(:,1),d.JacDataSecUsecQPDsStagesensors(:,2)], dat.info.Toffset);
    else
        dat.JacData.t = d.JacDataSecUsecQPDsStagesensors(:,1) + d.JacDataSecUsecQPDsStagesensors(:,2)*1E-6;
    end
    dat.JacData.qpd = d.JacDataSecUsecQPDsStagesensors(:,3:6);
    dat.JacData.ssense = d.JacDataSecUsecQPDsStagesensors(:,7:9);
    d.JacDataSecUsecQPDsStagesensors = [];
end

if(isfield(d,'gainsSecUsecPxyzIxyzDxyz'))
    if(flags.remtoff)        
        dat.gains.t = removeToffset([d.gainsSecUsecPxyzIxyzDxyz(:,1),d.gainsSecUsecPxyzIxyzDxyz(:,2)], dat.info.Toffset);
    else
        dat.gains.t = d.gainsSecUsecPxyzIxyzDxyz(:,1) + d.gainsSecUsecPxyzIxyzDxyz(:,2)*1E-6;
    end
    dat.gains.PID = d.gainsSecUsecPxyzIxyzDxyz(:,3:11);
    d.gainsSecUsecPxyzIxyzDxyz = [];
end

if(flags.remtoff)        
    dat.stageCom.t = removeToffset([d.stageCommandSecUsecZeroXYZ(:,1),d.stageCommandSecUsecZeroXYZ(:,2)], dat.info.Toffset);
else    
    dat.stageCom.t = d.stageCommandSecUsecZeroXYZ(:,1) + d.stageCommandSecUsecZeroXYZ(:,2)*1e-6;
end
dat.stageCom.xyz = d.stageCommandSecUsecZeroXYZ(:,end-2:end);
d.stageCommandSecUsecZeroXYZ = [];

%SCARY HARDCODING, MAY BREAK LATER: TRUE FOR LASER TRACKER VERSIONS 04.00
%ONWARDS. 
SINTERVAL = 100E-6;

% Now parse whatever jacobian info we have.
%
% idle jacobian timestamp is the exact time when noise-injection was started
% active jacobian timestamp is the exact time when jacobian estimate was
% updated in feedback. 
% Jacobians (both format DQtoDS, and QPDtoXYZ) are logged row-by-row 
%       (i.e. in the sequence [1,1] [1,2] [1,3]; [2,1] [2,2] [2,3];...
%
% For LTver <= 04.05
% Two types of Jacobian: Linear and 2nd order. So total 4 combinations
% Laser tracker logs the DQtoDS Jacobian. 
% Idle Jacobian values: 
%   Linear   : TstartSec[1]Usec[1]Goals[4]Nsamples[1]DQtoDS[4 x 3] = total 19
%   2nd Order: TstartSec[1]Usec[1]Goals[4]Nsamples[1]DQtoDS[20 x 3] = total 67
% Active Jacobian values: 
%   Linear   : TupdateSec[1]Usec[1]Goals[4]DQtoDS[4 x 3] = total 18
%   2nd Order: TupdateSec[1]Usec[1]Goals[4]DQtoDS[20 x 3] = total 66
% 
% For LTver > 04.05
% 
% Three types of Jacobian: Linear, 2nd Order, Blocks. So total 6 combinations
% Laser tracker logs the QPDtoXYZ function now instead of DQtoDS Jacobian. 
% Idle Jacobian values: 
%   Linear   : TstartSec[1]Usec[1]Nsamples[1]QPDtoXYZ[4 x 3] = total 15
%   2nd Order: TstartSec[1]Usec[1]Nsamples[1]QPDtoXYZ[15 x 3] = total 48
%   Block: TstartSec[1]Usec[1]Nsamples[1]QPDtoXYZ[26 x 3] = total 81
% Active Jacobian values: 
%   Linear   : TstartSec[1]Usec[1]QPDtoXYZ[4 x 3] = total 14
%   2nd Order: TstartSec[1]Usec[1]QPDtoXYZ[15 x 3] = total 47
%   Block: TstartSec[1]Usec[1]QPDtoXYZ[26 x 3] = total 80


if(LTver <= 04.05)
    if(isfield(d, 'JacLinearIdleSecUsecGoalsNsampleDQtoDS'))
        temp = d.JacLinearIdleSecUsecGoalsNsampleDQtoDS;
        cj = 0;%index of the non-old jacobian 
        for c = 1:1:size(temp,1)
            if(flags.remtoff)
                tstart = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                tstart = temp(c,1) + temp(c,2)*1e-6;
            end
            count = temp(c,7); 
            %tend = tstart+count*SINTERVAL;
            
            %Now see if this jacobian is an old one (either a legacy one or the
            %first in this tracking session)
            if(tstart >= dat.t(1))  
                % this is not a legacy jacobian, neither it is the first in the
                % tracking session.
                istart = max(find(dat.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for LinearIdle Jacobian, index',num2str(c)]);
                    keyboard;
                end
                cj = cj+1;
                iend = istart+count-1;
                if (~flags.concise)
                    dat.jilin(cj,1).qpd = dat.qpd(istart:iend,:);
                    dat.jilin(cj,1).ssense = dat.ssense(istart:iend,:);
                end
                dat.jilin(cj,1).iblip(1,1) = istart; 
                dat.jilin(cj,1).iblip(1,2) = iend;                
                dat.jilin(cj,1).qgoals = temp(c,3:6);                
                dat.jilin(cj,1).tblip = [dat.t(istart), dat.t(iend)];
                dat.jilin(cj,1).pertprop = getperturbationinfo( ... 
                    dat.jilin(cj,1).tblip, noiseinfo, flags.remtoff, dat.info.Toffset);
                for rows = 1:1:4
                    dat.jilin(cj,1).jac(rows,1:3) = temp(c,[7 + (rows-1)*3 + 1 : 7 + (rows-1)*3 + 3]);
                end
                %         dat.jilin(c,1).jac(1,1:3) = temp(c,8:10);
                %         dat.jilin(c,1).jac(2,1:3) = temp(c,11:13);
                %         dat.jilin(c,1).jac(3,1:3) = temp(c,14:16);
                %         dat.jilin(c,1).jac(4,1:3) = temp(c,17:19);
            else% if come here this means that the jacobian is either the first in this tracking session or a legacy one.
                if isfield(dat,'jacold')
                    disp(['Error: Multiple "Old" jacobians received in this file, index ',num2str(c)]);
                    keyboard;
                end
                istart = max(find(dat.JacData.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for LinearIdle, OLD Jacobian, index',num2str(c)]);
                    keyboard;
                end
                iend = istart+count-1;
                
                dat.jacold.iblip(1,1) = istart; 
                dat.jacold.iblip(1,2) = iend;            
                dat.jacold.qgoals = temp(c,3:6); 
                if (~flags.concise)
                    dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);
                    dat.jacold.ssense = dat.JacData.ssense(istart:iend,:);
                end                
                dat.jacold.tblip = [dat.JacData.t(istart), dat.JacData.t(iend)];
                dat.jacold.pertprop = getperturbationinfo( ... 
                    dat.jacold.tblip, noiseinfo, flags.remtoff, dat.info.Toffset);                
                for rows = 1:1:4
                    dat.jacold.jac(rows,1:3) = temp(c,[7 + (rows-1)*3 + 1 : 7 + (rows-1)*3 + 3]);
                end
            end        
        end
    end  
    
    if(isfield(d, 'Jac2ndOrderIdleSecUsecGoalsNsampleDQtoDS'))
        temp = d.Jac2ndOrderIdleSecUsecGoalsNsampleDQtoDS;    
        cj = 0;%index of the non-old jacobian 
        for c = 1:size(temp,1)
            if(flags.remtoff)
                tstart = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                tstart = temp(c,1) + temp(c,2)*1e-6;
            end
            count = temp(c,7);
            %Now see if this jacobian is an old one (either a legacy one or the
            %first in this tracking session)
            if(tstart >= dat.t(1))  
                % this is not a legacy jacobian, neither it is the first in the
                % tracking session
                istart = find(dat.t == tstart);
                if isempty(istart)
                    disp(['Error: can not find jacobian data for 2ndOrderIdle Jacobian, index',num2str(c)]);
                    keyboard;
                end
                cj = cj+1;
                iend = istart+count-1;  
                if (~flags.concise)
                    dat.ji2nd(cj,1).qpd = dat.qpd(istart:iend,:);
                    dat.ji2nd(cj,1).ssense = dat.ssense(istart:iend,:);
                end
                dat.ji2nd(cj,1).iblip(1,1) = istart; 
                dat.ji2nd(cj,1).iblip(1,2) = iend;            
                dat.ji2nd(cj,1).qgoals = temp(c,3:6);
                dat.ji2nd(cj,1).tblip = [dat.t(istart), dat.t(iend)];
                dat.ji2nd(cj,1).pertprop = getperturbationinfo( ... 
                    dat.ji2nd(cj,1).tblip, noiseinfo, flags.remtoff, dat.info.Toffset);
                for rows = 1:1:20
                    dat.ji2nd(cj,1).jac(rows,1:3) = temp(c,[7 + (rows-1)*3 + 1 : 7 + (rows-1)*3 + 3]);
                end
                %         dat.jilin(c,1).jac(1,1:3) = temp(c,8:10);
                %         dat.jilin(c,1).jac(2,1:3) = temp(c,11:13);
                %         dat.jilin(c,1).jac(3,1:3) = temp(c,14:16);
                %         dat.jilin(c,1).jac(4,1:3) = temp(c,17:19);
            else% if come here this means that the jacobian is either the first in this tracking session or a legacy one.
                if isfield(dat,'jacold')
                    disp(['Error: Multiple "Old" jacobians received in this file, index ',num2str(c)]);
                    keyboard;
                end
                istart = max(find(dat.JacData.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for 2ndOrderIdle, OLD Jacobian, index',num2str(c)]);
                    keyboard;
                end
                iend = istart+count-1;            
                dat.jacold.iblip(1,1) = istart; 
                dat.jacold.iblip(1,2) = iend;            
                dat.jacold.qgoals = temp(c,3:6);    
                if (~flags.concise)
                    dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);
                    dat.jacold.ssense = dat.JacData.ssense(istart:iend,:);
                end
                dat.jacold.tblip = [dat.JacData.t(istart), dat.JacData.t(iend)];
                dat.jacold.pertprop = getperturbationinfo( ... 
                    dat.jacold.tblip, noiseinfo, flags.remtoff, dat.info.Toffset);   
                for rows = 1:1:20
                    dat.jacold.jac(rows,1:3) = temp(c,[7 + (rows-1)*3 + 1 : 7 + (rows-1)*3 + 3]);
                end
            end        
        end
    end
    % Policy: we don't store data for Active jacobians, since all Active
    % Jacobians are also recorded first as Idle Jacobians
    if(isfield(d,'JacLinearActiveSecUsecGoalsDQtoDS'))
        temp = d.JacLinearActiveSecUsecGoalsDQtoDS;
        for c = 1:1:size(temp,1)        
            if(flags.remtoff)
                dat.jalin(c,1).tupdate = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                dat.jalin(c,1).tupdate = temp(c,1) + temp(c,2)*1e-6;
            end            
            dat.jalin(c,1).qgoals = temp(c,3:6); 
            for rows = 1:1:4
                dat.jalin(c,1).jac(rows,1:3) = temp(c,[6 + (rows-1)*3 + 1 : 6 + (rows-1)*3 + 3]);
            end        
        end
    end
    if(isfield(d, 'Jac2ndOrderActiveSecUsecGoalsDQtoDS'))
        temp = d.Jac2ndOrderActiveSecUsecGoalsDQtoDS;    
        for c = 1:1:size(temp,1)
            if(flags.remtoff)
                dat.ja2nd(c,1).tupdate = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                dat.ja2nd(c,1).tupdate = temp(c,1) + temp(c,2)*1e-6;
            end            
            dat.ja2nd(c,1).qgoals = temp(c,3:6);            
            for rows = 1:1:20
                dat.ja2nd(c,1).jac(rows,1:3) = temp(c,[6 + (rows-1)*3 + 1 : 6 + (rows-1)*3 + 3]);
            end
        end
    end    
end    
%*************************************************************************
if (LTver > 04.05)
    if(isfield(d, 'JacLinearIdleSecUsecNsampleQPDtoXYZ'))
        temp = d.JacLinearIdleSecUsecNsampleQPDtoXYZ;
        cj = 0;%index of the non-old jacobian 
        for c = 1:1:size(temp,1)
            if(flags.remtoff)
                tstart = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                tstart = temp(c,1) + temp(c,2)*1e-6;
            end
            count = temp(c,3);
            %Now see if this jacobian is an old one (either a legacy one or the
            %first in this tracking session)
            if(tstart >= dat.t(1))  
                % this is not a legacy jacobian, neither it is the first in the
                % tracking session
                istart = max(find(dat.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for LinearIdle Jacobian, index',num2str(c)]);
                    keyboard;
                end
                cj = cj+1;
                iend = istart+count-1;     
                if(~flags.concise)
                    dat.jilin(cj,1).qpd = dat.qpd(istart:iend,:);
                    dat.jilin(cj,1).ssense = dat.ssense(istart:iend,:);
                end
                dat.jilin(cj,1).iblip(1,1) = istart; 
                dat.jilin(cj,1).iblip(1,2) = iend;    
                dat.jilin(cj,1).tblip = [dat.t(istart), dat.t(iend)];
                dat.jilin(cj,1).pertprop = getperturbationinfo( ... 
                    dat.jilin(cj,1).tblip, noiseinfo, flags.remtoff, dat.info.Toffset); 
                for rows = 1:1:4
                    dat.jilin(cj,1).jac(rows,1:3) = temp(c,[3 + (rows-1)*3 + 1 : 3 + (rows-1)*3 + 3]);
                end                
            else% if come here this means that the jacobian is either the first in this tracking session or a legacy one.
                if isfield(dat,'jacold')
                    disp(['Error: Multiple "Old" jacobians received in this file, index ',num2str(c)]);
                    keyboard;
                end
                istart = max(find(dat.JacData.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for LinearIdle, OLD Jacobian, index',num2str(c)]);
                    keyboard;
                end
                iend = istart+count-1;
                
                dat.jacold.iblip(1,1) = istart; 
                dat.jacold.iblip(1,2) = iend; 
                if(~flags.concise)
                    dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);
                    dat.jacold.ssense = dat.JacData.ssense(istart:iend,:);
                end
                dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);                
                dat.jacold.pertprop = getperturbationinfo( ... 
                    dat.jacold.tblip, noiseinfo, flags.remtoff, dat.info.Toffset);  
                for rows = 1:1:4
                    dat.jacold.jac(rows,1:3) = temp(c,[3 + (rows-1)*3 + 1 : 3 + (rows-1)*3 + 3]);
                end
            end        
        end
    end  
    if(isfield(d, 'Jac2ndOrderIdleSecUsecNsampleQPDtoXYZ'))
        temp = d.Jac2ndOrderIdleSecUsecNsampleQPDtoXYZ;    
        cj = 0;%index of the non-old jacobian 
        for c = 1:size(temp,1)
            if(flags.remtoff)
                tstart = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                tstart = temp(c,1) + temp(c,2)*1e-6;
            end            
            count = temp(c,3);
            %Now see if this jacobian is an old one (either a legacy one or the
            %first in this tracking session)
            if(tstart >= dat.t(1))  
                % this is not a legacy jacobian, neither it is the first in the
                % tracking session
                istart = max(find(dat.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for 2ndOrderIdle Jacobian, index',num2str(c)]);
                    keyboard;
                end
                cj = cj+1;
                iend = istart+count-1; 
                if(~flags.concise)
                    dat.ji2nd(cj,1).qpd = dat.qpd(istart:iend,:);
                    dat.ji2nd(cj,1).ssense = dat.ssense(istart:iend,:);
                end
                dat.ji2nd(cj,1).iblip(1,1) = istart; 
                dat.ji2nd(cj,1).iblip(1,2) = iend;
                dat.ji2nd(cj,1).tblip = [dat.t(istart), dat.t(iend)];
                dat.ji2nd(cj,1).pertprop = getperturbationinfo( ... 
                    dat.ji2nd(cj,1).tblip, noiseinfo, flags.remtoff, dat.info.Toffset);
                for rows = 1:1:15
                    dat.ji2nd(cj,1).jac(rows,1:3) = temp(c,[3 + (rows-1)*3 + 1 : 3 + (rows-1)*3 + 3]);
                end                
            else% if come here this means that the jacobian is either the first in this tracking session or a legacy one.
                if isfield(dat,'jacold')
                    disp(['Error: Multiple "Old" jacobians received in this file, index ',num2str(c)]);
                    keyboard;
                end
                istart = max(find(dat.JacData.t <= tstart));
                if isempty(istart)
                    disp(['Error: can not find jacobian data for 2ndOrderIdle, OLD Jacobian, index',num2str(c)]);
                    keyboard;
                end
                iend = istart+count-1;            
                dat.jacold.iblip(1,1) = istart; 
                dat.jacold.iblip(1,2) = iend;    
                if(~flags.concise)
                    dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);
                    dat.jacold.ssense = dat.JacData.ssense(istart:iend,:);
                end
                dat.jacold.tblip = [dat.JacData.t(istart), dat.JacData.t(iend)];
                dat.jacold.pertprop = getperturbationinfo( ... 
                    dat.jacold.tblip, noiseinfo, flags.remtoff, dat.info.Toffset);  
                for rows = 1:1:15
                    dat.jacold.jac(rows,1:3) = temp(c,[3 + (rows-1)*3 + 1 : 3 + (rows-1)*3 + 3]);
                end
            end        
        end
    end
    
    % Policy: we don't store data for Active jacobians, since all Active
    % Jacobians are also recorded first as Idle Jacobians
    if(isfield(d,'JacLinearActiveSecUsecQPDtoXYZ'))
        temp = d.JacLinearActiveSecUsecQPDtoXYZ;
        for c = 1:1:size(temp,1) 
            if(flags.remtoff)
                dat.jalin(c,1).tupdate = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                dat.jalin(c,1).tupdate = temp(c,1) + temp(c,2)*1e-6;
            end            
            for rows = 1:1:4
                dat.jalin(c,1).jac(rows,1:3) = temp(c,[2 + (rows-1)*3 + 1 : 2 + (rows-1)*3 + 3]);
            end        
        end
    end
    if(isfield(d, 'Jac2ndOrderActiveSecUsecQPDtoXYZ'))
        temp = d.Jac2ndOrderActiveSecUsecQPDtoXYZ;    
        for c = 1:1:size(temp,1)
            if(flags.remtoff)
                dat.ja2nd(c,1).tupdate = removeToffset(temp(c,1:2), dat.info.Toffset);
            else
                dat.ja2nd(c,1).tupdate = temp(c,1) + temp(c,2)*1e-6;
            end            
            for rows = 1:1:15
                dat.ja2nd(c,1).jac(rows,1:3) = temp(c,[2 + (rows-1)*3 + 1 : 2 + (rows-1)*3 + 3]);
            end
        end
    end
end
dat = rmfield(dat,'JacData');
clear d
dbclear if error

function tout = removeToffset(tin, toffset)
tout_sec(:,1) = tin(:,1) - toffset(1,1);
tout_usec(:,1) = tin(:,2) - toffset(1,2);
inegs = find(tout_usec < 0); %indices where the difference went negative
tout_usec(inegs,1) = tout_usec(inegs,1) + 1E6;
tout_sec(inegs,1) = tout_sec(inegs,1) - 1;
tout = tout_sec + tout_usec*1e-6;

function str = getperturbationinfo(tspan,pinfo,remtoff,toff)
allowance = 1;
str = 'Perturbation Info Not Available';
for c = 1:size(pinfo,1)
    [A,count,errmsg,nextindex] = sscanf(pinfo(c,:),'Sec %ld uSec %ld ');
    if remtoff
        tpert = removeToffset(A',toff);
    else
        tpert = A(1,1) + A(1,2)*1E-6;
    end
    
    if(tpert > tspan(1,1) - allowance & tpert < tspan(1,2) + allowance)
        %this is our message
        str = pinfo(c,nextindex:end);
    end
end

