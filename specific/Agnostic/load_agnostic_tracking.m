function dat = load_agnostic_tracking(fileName, verbose)
% Parse the laser-tracking log file for the purpose of analyzing agnostic tracking
% compatible with LaserTracker version 03.02 to 04.00
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
%   dat.ji2nd - fields same as jilin except (20,3) instead of (4,3)
%   dat.ja2nd - fileds same as jalin except (20,3) instead of (4,3)
% 
%   dat.gains.t
%            .PID
% LAST MODIFIED:    12 July 2005, by kvdesai
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VERSION = '1.0';
disp(['load_agnostic_tracking :: version ', VERSION]);
if (nargin < 2 | isempty(verbose));  verbose=1;         end;%print messages loudly by default

dat = [];

load(fileName);
d = tracking; clear tracking;

if(isfield(d,'info'))
   dat.info = d.info;
end
dat.info.name = fileName;
dat.info.ver.loadAT_m = VERSION;
%First check that this is an appropriate file for Agnostic tracking
%analysis. Do this by looking for atleast one filedName containing 'jac'
names = fieldnames(d);
if (verbose)
    disp('Below are the fields I got:');
    disp(names);
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
    dat.t = d.QPDsSecUsecVals(:,1) + d.QPDsSecUsecVals(:,2)*1e-6;
end

dat.peidle = d.posErrorSecUsecXYZ(:,3:5);
% keep freeing memory as we go
    d.posErrorSecUsecXYZ = [];
dat.ssense = d.stageSenseSecUsecXYZsense(:,3:5);
    d.stageSenseSecUsecXYZsense = [];
dat.qpd = d.QPDsSecUsecVals(:,3:6);
    d.QPDsSecUsecVals = [];
    
if(isfield(d,'posErrorActiveSecUsecXYZ')) %if we have ActivePositionErrors computed 
    dat.peactive.t = d.posErrorActiveSecUsecXYZ(:,1) + d.posErrorActiveSecUsecXYZ(:,2)*1E-6;
    dat.peactive.xyz = d.posErrorActiveSecUsecXYZ(:,3:5);
    d.posErrorActiveSecUsecXYZ = [];
end

if(isfield(d,'JacDataSecUsecQPDsStagesensors')) %if we have ActivePositionErrors computed 
    dat.JacData.t = d.JacDataSecUsecQPDsStagesensors(:,1) + d.JacDataSecUsecQPDsStagesensors(:,2)*1E-6;
    dat.JacData.qpd = d.JacDataSecUsecQPDsStagesensors(:,3:6);
    dat.JacData.ssense = d.JacDataSecUsecQPDsStagesensors(:,7:9);
    d.JacDataSecUsecQPDsStagesensors = [];
end

if(isfield(d,'gainsSecUsecPxyzIxyzDxyz'))
    dat.gains.t = d.gainsSecUsecPxyzIxyzDxyz(:,1) + d.gainsSecUsecPxyzIxyzDxyz(:,2)*1E-6;
    dat.gains.PID = d.gainsSecUsecPxyzIxyzDxyz(:,3:11);
    d.gainsSecUsecPxyzIxyzDxyz = [];
end

dat.stageCom.t = d.stageCommandSecUsecZeroXYZ(:,1) + d.stageCommandSecUsecZeroXYZ(:,2)*1e-6;
dat.stageCom.xyz = d.stageCommandSecUsecZeroXYZ(:,end-2:end);
d.stageCommandSecUsecZeroXYZ = [];
% Now parse whatever jacobian info we have.
%
% idle jacobian timestamp is the exact time when noise-injection was started
% active jacobian timestamp is the exact time when jacobian estimate was
% updated in feedback.
% Two types of Jacobian: Linear and 2nd order. So total 4 combinations
% Laser tracker logs the DQtoDS function (or DsDq matrix), and not the
% forward Jacobian DStoDQ (or DqDs matrix). 
% Idle Jacobian values: 
%   Linear   : TstartSec[1]Usec[1]Goals[4]Nsamples[1]DQtoDS[4 x 3] = total 19
%   2nd Order: TstartSec[1]Usec[1]Goals[4]Nsamples[1]DQtoDS[20 x 3] = total 67
% Active Jacobian values: 
%   Linear   : TupdateSec[1]Usec[1]Goals[4]DQtoDS[4 x 3] = total 18
%   2nd Order: TupdateSec[1]Usec[1]Goals[4]DQtoDS[20 x 3] = total 66
% DQtoDS is logged row-by-row (i.e. in the sequence [1,1] [1,2] [1,3]; [2,1] [2,2] [2,3];...


if(isfield(d, 'JacLinearIdleSecUsecGoalsNsampleDQtoDS'))
    temp = d.JacLinearIdleSecUsecGoalsNsampleDQtoDS;
    cj = 0;%index of the non-old jacobian 
    for c = 1:1:size(temp,1)
        tstart = temp(c,1) + temp(c,2)*1e-6;
        count = temp(c,7);
        %Now see if this jacobian is an old one (either a legacy one or the
        %first in this tracking session)
        if(tstart >= dat.t(1))  
            % this is not a legacy jacobian, neither it is the first in the
            % tracking session
            istart = find(dat.t == tstart);
            if isempty(istart)
                disp(['Error: can not find jacobian data for LinearIdle Jacobian, index',num2str(c)]);
                keyboard;
            end
            cj = cj+1;
            iend = istart+count-1;            
            dat.jilin(cj,1).qpd = dat.qpd(istart:iend,:);
            dat.jilin(cj,1).ssense = dat.ssense(istart:iend,:);
            dat.jilin(cj,1).iblip(1,1) = istart; 
            dat.jilin(cj,1).iblip(1,2) = iend;            
            dat.jilin(cj,1).qgoals = temp(c,3:6);    
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
            istart = find(dat.JacData.t == tstart);
            if isempty(istart)
                disp(['Error: can not find jacobian data for LinearIdle, OLD Jacobian, index',num2str(c)]);
                keyboard;
            end
            iend = istart+count-1;
            
            dat.jacold.iblip(1,1) = istart; 
            dat.jacold.iblip(1,2) = iend;            
            dat.jacold.qgoals = temp(c,3:6);    
            dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);
            dat.jacold.ssense = dat.JacData.ssense(istart:iend,:);
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
        tstart = temp(c,1) + temp(c,2)*1e-6;
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
            dat.ji2nd(cj,1).qpd = dat.qpd(istart:iend,:);
            dat.ji2nd(cj,1).ssense = dat.ssense(istart:iend,:);
            dat.ji2nd(cj,1).iblip(1,1) = istart; 
            dat.ji2nd(cj,1).iblip(1,2) = iend;            
            dat.ji2nd(cj,1).qgoals = temp(c,3:6);    
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
            istart = find(dat.JacData.t == tstart);
            if isempty(istart)
                disp(['Error: can not find jacobian data for 2ndOrderIdle, OLD Jacobian, index',num2str(c)]);
                keyboard;
            end
            iend = istart+count-1;            
            dat.jacold.iblip(1,1) = istart; 
            dat.jacold.iblip(1,2) = iend;            
            dat.jacold.qgoals = temp(c,3:6);    
            dat.jacold.qpd = dat.JacData.qpd(istart:iend,:);
            dat.jacold.ssense = dat.JacData.ssense(istart:iend,:);
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
        dat.jalin(c,1).tupdate = temp(c,1) + temp(c,2)*1e-6;
        dat.jalin(c,1).qgoals = temp(c,3:6); 
        for rows = 1:1:20
            dat.jalin(c,1).jac(rows,1:3) = temp(c,[6 + (rows-1)*3 + 1 : 6 + (rows-1)*3 + 3]);
        end        
    end
end
if(isfield(d, 'Jac2ndOrderActiveSecUsecGoalsDQtoDS'))
    temp = d.Jac2ndOrderActiveSecUsecGoalsDQtoDS;    
    for c = 1:1:size(temp,1)
        dat.ja2nd(c,1).tupdate = temp(c,1) + temp(c,2)*1e-6;
        dat.ja2nd(c,1).qgoals = temp(c,3:6);            
        for rows = 1:1:20
            dat.ja2nd(c,1).jac(rows,1:3) = temp(c,[6 + (rows-1)*3 + 1 : 6 + (rows-1)*3 + 3]);
        end
    end
end
dat = rmfield(dat,'JacData');
clear d
