function clipped = tclip(d,ts,te,fields,fsave)
% 3DFM function  
% GUI Analysis 
% last modified 06/22/04 
%  
% This function clips the data according to given time limits in seconds
% It also stores the information about the original dataset and limits
% where the clipping was performed
%  
%  clipped = tclip(d,ts,te,save)
%   
%  where clipped : dataset after clipping has been performed
%          d      : dataset in the same format as of output of load_vrpn_tracking.m
%          ts     : Starting time for the clip in seconds ( fractions allowed e.g 4.347)
%          te     : Ending time for the clip in seconds (fractions allowed)
%          fields : a string that contains letter-combination represeting fields that 
%                   are desired to be in the clipped dataset
%                   'a' : ALL [default]
%                   's' : stage command
%                   'q' : qpd and laser intensity
%                   'r' : stage report
%                   'e' : position error
%                   'b' : bead position
%                   The order of the letters doesn't matter
%                   Since jacobian does not require much space, it is
%                   provided in every clipped dataset.
%          fsave  : ['yes' | {'no'}] 
%                   -Flag specifying if the clipped data needs to be saved 
%                   automatically [defaulted to 'no']
%          
%  Notes:  
%   
%  This function is being called from analysis.m GUI. The main purpose is to provide a 
%  a systematic way of keeping track-record of what is being done, when multiple datasets
%  are being clipped and then stitched together to form one dataset, as in
%  Lissajous experiments
  
% Find the start and stop indices from the given time limits for
% lowbandwidth data
if nargin < 4     fsave = 'no';  end
if nargin < 3 | isemtpy(varargin{3})   fields = 'a';  end % Clip all fields
isl = max(find(d.stageCom.time - d.stageCom.time(1,1) - ts <= 0.0005));
iel = max(find(d.stageCom.time - d.stageCom.time(1,1) - te <= 0.0005));
% Find the start and stop indices from the given time limits for
% highbandwidth data
ish = max(find(d.qpd.time - d.qpd.time(1,1) - ts <= 0.00005));
ieh = max(find(d.qpd.time - d.qpd.time(1,1) - te <= 0.00005));

if(findstr(fields,'a'))
    fields = 'sqreb';
end
% if the original dataset has a field named 'info', than all that 
% information should be inherited into the clipped dataset.
if(isfield(d,'info')) 
    clipped.info = d.info;    
    if(isfield(d.info,'clips'))%if the data being clipped has already been clipped atleast once 
        ind = length(d.info.clips) + 1;
    else %the data is original and it hasnot been clipped yet.
        ind = 1;
    end
end
% Now save information about clipping of this dataset
clipped.info.clips(ind).time_offset = d.stageCom.time(1,1);
clipped.info.clips(ind).tstart = d.stageCom.time(isl);
clipped.info.clips(ind).tend = d.stageCom.time(iel);
clipped.info.clips(ind).istartLowf = isl;
clipped.info.clips(ind).iendLowf = iel;
clipped.info.clips(ind).istartHighf = ish;
clipped.info.clips(ind).iendHighf = ieh;

if(isfield(d,'jacobian'))%Do not clip jacobian time values
    clipped.jacobian = d.jacobian;
end
% Now perform clipping for the dataset
if(findstr(fields,'s'))
    clipped.stageCom.time = d.stageCom.time(isl:iel);
    clipped.stageCom.x = d.stageCom.x(isl:iel);
    clipped.stageCom.y = d.stageCom.y(isl:iel);
    clipped.stageCom.z = d.stageCom.z(isl:iel);
end

if(findstr(fields,'q'))
    clipped.qpd.time = d.qpd.time(ish:ieh);
    clipped.qpd.q1 = d.qpd.q1(ish:ieh);
    clipped.qpd.q2 = d.qpd.q2(ish:ieh);
    clipped.qpd.q3 = d.qpd.q3(ish:ieh);
    clipped.qpd.q4 = d.qpd.q4(ish:ieh);
    
    clipped.laser.time = d.laser.time(ish:ieh);
    clipped.laser.intensity = d.laser.intensity(ish:ieh);
end

if(findstr(fields,'r'))
    if(isfield(d,'stageReport'))
        clipped.stageReport.time = d.stageReport.time(ish:ieh);
        clipped.stageReport.x = d.stageReport.x(ish:ieh);
        clipped.stageReport.y = d.stageReport.y(ish:ieh);
        clipped.stageReport.z = d.stageReport.z(ish:ieh);
    else
        warning('StageReport field was requested to be clipped, but it was not found in the original data set.');
    end
end
if(findstr(fields,'e'))
    if(isfield(d,'posError'))
        clipped.posError.time = d.posError.time(ish:ieh);
        clipped.posError.x = d.posError.x(ish:ieh);
        clipped.posError.y = d.posError.y(ish:ieh);
        clipped.posError.z = d.posError.z(ish:ieh);    
    else
        warning('posError field was requested to be clipped, but it was not found in the original data set.');
    end
end
if(findstr(fields,'b'))
    if(isfield(d,'beadpos'))
        clipped.beadpos.time = d.beadpos.time(ish:ieh);
        clipped.beadpos.x = d.beadpos.x(ish:ieh);
        clipped.beadpos.y = d.beadpos.y(ish:ieh);
        clipped.beadpos.z = d.beadpos.z(ish:ieh);
    else
        warning('beadpos field was requested to be clipped, but it was not found in the original data set.');
    end
end
dc = clipped;
disp('Clipping was peformed successfully.')
if(findstr(fsave,'y'))
    disp('Now saving to a .mat file...');
    save(['clip_',d.info.orig.name],'dc');
    disp(['Clipped data saved as ','clip_',d.info.orig.name]);
end