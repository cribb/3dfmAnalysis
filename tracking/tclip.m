function clipped = tclip(d,ts,te,fsave)
% 3DFM function  
% GUI Analysis 
% last modified 05/20/04 
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
%          fsave   : [optional] 'yes' | 'no' -Flag specifying if the clipped data needs to be saved 
%                   automatically [defaulted to 'no']
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
%           - renamed name d.stage to d.stageCom % 
%  05/19/04 - added extra argument to provide choice of saving the result
  
% Find the start and stop indices from the given time limits for
% lowbandwidth data
if nargin < 4
    fsave = 'no';
end
isl = max(find(d.stageCom.time - d.stageCom.time(1,1) - ts <= 0.05));
iel = max(find(d.stageCom.time - d.stageCom.time(1,1) - te <= 0.05));
% Find the start and stop indices from the given time limits for
% highbandwidth data
ish = max(find(d.qpd.time - d.qpd.time(1,1) - ts <= 0.00005));
ieh = max(find(d.qpd.time - d.qpd.time(1,1) - te <= 0.00005));

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

% Now perform clipping for the dataset
clipped.stageCom.time = d.stageCom.time(isl:iel);
clipped.stageCom.x = d.stageCom.x(isl:iel);
clipped.stageCom.y = d.stageCom.y(isl:iel);
clipped.stageCom.z = d.stageCom.z(isl:iel);

clipped.qpd.time = d.qpd.time(ish:ieh);
clipped.qpd.q1 = d.qpd.q1(ish:ieh);
clipped.qpd.q2 = d.qpd.q2(ish:ieh);
clipped.qpd.q3 = d.qpd.q3(ish:ieh);
clipped.qpd.q4 = d.qpd.q4(ish:ieh);

clipped.laser.time = d.laser.time(ish:ieh);
clipped.laser.intensity = d.laser.intensity(ish:ieh);

if(isfield(d,'stageReport'))
    clipped.stageReport.time = d.stageReport.time(ish:ieh);
    clipped.stageReport.x = d.stageReport.x(ish:ieh);
    clipped.stageReport.y = d.stageReport.y(ish:ieh);
    clipped.stageReport.z = d.stageReport.z(ish:ieh);
end
if(isfield(d,'posError'))
    clipped.posError.time = d.posError.time(ish:ieh);
    clipped.posError.x = d.posError.x(ish:ieh);
    clipped.posError.y = d.posError.y(ish:ieh);
    clipped.posError.z = d.posError.z(ish:ieh);
end
if(isfield(d,'beadpos'))
    clipped.beadpos.time = d.beadpos.time(ish:ieh);
    clipped.beadpos.x = d.beadpos.x(ish:ieh);
    clipped.beadpos.y = d.beadpos.y(ish:ieh);
    clipped.beadpos.z = d.beadpos.z(ish:ieh);
end
if(isfield(d,'jacobian'))%Do not clip jacobian time values
    clipped.jacobian = d.jacobian;
end
dc = clipped;
disp('Clipping was peformed successfully.')
if(findstr(fsave,'y'))
    disp('Now saving to a .mat file...');
    save(['clip_',d.info.orig.name],'dc');
    disp(['Clipped data saved as ','clip_',d.info.orig.name]);
end