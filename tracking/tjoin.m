function joined = tjoin(d1,d2,fields)
% 3DFM function  
% GUI Analysis 
% last modified 05/11/04 
%  
% This function joins two datasets for the fields provided in arguement
%  
%  joined = tjoin(d1,d2,fields)
%  
%  where joined : dataset as result of stitching of two inputs datasets
%          d1     : the first dataset 
%          d2     : the second dataset, to be appended to d1
%          fields : a string that contains letter-combination represeting fields that 
%                   are desired to be in the final dataset
%                   's' : stage command [by default]
%                   'q' : qpd
%                   'r' : stage report
%                   'e' : position error
%                   'b' : bead position
%                   The order of the letters doesn't matter
%          d1 and d2 both MUST be in the format as output of load_vrpn_tracking
%                  
%  Notes:  
%   
%  This function is being called from analysis.m GUI. The main purpose is to provide a 
%  a systematic way of keeping track-record of what is being done, when multiple datasets
%  are being clipped and then stitched together to form one dataset, as in
%  Lissajous experiments
%   
%  ?? - created.  
%  05/11/04 - Commented  
%           - added 'fields' argument

if (nargin < 3 | isempty(fields))
    fields = 's';
end
if (nargin < 2 | isempty(d2))
    joined = d1;
    warning('tjoin::Only one dataset is provided in input');
    return;
end

% a redundant copy of the information, to make the final dataset in the
% standard format as output of load_vrpn_tracking
joined.info = d1.info;
%save information of clipping limits and indices at this junction
if(isfield(d1.info,'joints')) %if d1 is already a joint dataset 
    len = length(d1.info.joints);
    joined.info.joints = d1.info.joints;
    i = len;
else
    i = 1;
    joined.info.joints(i,1) = d1.info;
end

i = i+1;
% all information from data1 joints is now inherited. 
% now inherid all information about data2 joints
if(isfield(d2.info,'joints')) % if d2 is already a joint dataset
    j = length(d2.info.joints);
    for k = 1:j
        joined.info.joints(i,1) = d2.info.joints(k,1);
        i = i+1;
    end
else
    joined.info.joints(i,1) = d2.info;
end

% join stageCommands field if we should
if(findstr(fields,'s'))
    d2.stageCom.actual_time = d2.stageCom.time;
    d2.stageCom.time = d2.stageCom.time - d2.stageCom.time(1,1) + d1.stageCom.time(end);
    d2.stageCom.x = d2.stageCom.x - d2.stageCom.x(1,1) + d1.stageCom.x(end);
    d2.stageCom.y = d2.stageCom.y - d2.stageCom.y(1,1) + d1.stageCom.y(end);
    d2.stageCom.z = d2.stageCom.z - d2.stageCom.z(1,1) + d1.stageCom.z(end);
    
    joined.stageCom.time = [d1.stageCom.time; d2.stageCom.time];
    joined.stageCom.x = [d1.stageCom.x;d2.stageCom.x];
    joined.stageCom.y = [d1.stageCom.y;d2.stageCom.y];
    joined.stageCom.z = [d1.stageCom.z;d2.stageCom.z];
end
% join qpd field if we should
if(findstr(fields,'q'))
    d2.qpd.actual_time = d2.qpd.time;
    d2.qpd.time = d2.qpd.time - d2.qpd.time(1,1) + d1.qpd.time(end);
    d2.qpd.x = d2.qpd.x - d2.qpd.x(1,1) + d1.qpd.x(end);
    d2.qpd.y = d2.qpd.y - d2.qpd.y(1,1) + d1.qpd.y(end);
    d2.qpd.z = d2.qpd.z - d2.qpd.z(1,1) + d1.qpd.z(end);
    
    joined.qpd.time = [d1.qpd.time; d2.qpd.time];
    joined.qpd.x = [d1.qpd.x;d2.qpd.x];
    joined.qpd.y = [d1.qpd.y;d2.qpd.y];
    joined.qpd.z = [d1.qpd.z;d2.qpd.z];
end
% join stageReport field if we should
if(findstr(fields,'r'))
    d2.stageReport.time = d2.stageReport.time - d2.stageReport.time(1,1) + d1.stageReport.time(end);
    d2.stageReport.x = d2.stageReport.x - d2.stageReport.x(1,1) + d1.stageReport.x(end);
    d2.stageReport.y = d2.stageReport.y - d2.stageReport.y(1,1) + d1.stageReport.y(end);
    d2.stageReport.z = d2.stageReport.z - d2.stageReport.z(1,1) + d1.stageReport.z(end);
    
    joined.stageReport.time = [d1.stageReport.time; d2.stageReport.time];
    joined.stageReport.x = [d1.stageReport.x;d2.stageReport.x];
    joined.stageReport.y = [d1.stageReport.y;d2.stageReport.y];
    joined.stageReport.z = [d1.stageReport.z;d2.stageReport.z];
end
% join position error field if we should
if(findstr(fields,'e'))
    d2.posError.actual_time = d2.posError.time;
    d2.posError.time = d2.posError.time - d2.posError.time(1,1) + d1.posError.time(end);
    d2.posError.x = d2.posError.x - d2.posError.x(1,1) + d1.posError.x(end);
    d2.posError.y = d2.posError.y - d2.posError.y(1,1) + d1.posError.y(end);
    d2.posError.z = d2.posError.z - d2.posError.z(1,1) + d1.posError.z(end);
    
    joined.posError.time = [d1.posError.time; d2.posError.time];
    joined.posError.x = [d1.posError.x;d2.posError.x];
    joined.posError.y = [d1.posError.y;d2.posError.y];
    joined.posError.z = [d1.posError.z;d2.posError.z];
end
% join bead positions field if we should
if(findstr(fields,'b'))
    d2.beadpos.actual_time = d2.beadpos.time;
    d2.beadpos.time = d2.beadpos.time - d2.beadpos.time(1,1) + d1.beadpos.time(end);
    d2.beadpos.x = d2.beadpos.x - d2.beadpos.x(1,1) + d1.beadpos.x(end);
    d2.beadpos.y = d2.beadpos.y - d2.beadpos.y(1,1) + d1.beadpos.y(end);
    d2.beadpos.z = d2.beadpos.z - d2.beadpos.z(1,1) + d1.beadpos.z(end);
    
    joined.beadpos.time = [d1.beadpos.time; d2.beadpos.time];
    joined.beadpos.x = [d1.beadpos.x;d2.beadpos.x];
    joined.beadpos.y = [d1.beadpos.y;d2.beadpos.y];
    joined.beadpos.z = [d1.beadpos.z;d2.beadpos.z];
end