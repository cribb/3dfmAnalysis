function clipped = mclip(mag,ts,te)
% 3DFM function  
% GUI Analysis 
% last modified 05/18/04 
%  
% This function clips the magnet data according to given time limits in seconds
% It also stores the information about the original dataset and limits
% where the clipping was performed
%  
%  clipped = mclip(mag,ts,te)
%   
%  where clipped : dataset after clipping has been performed
%          mag      : dataset having magnet excitations 
%                     fields - mag.analogs,  mag.time
%          ts     : Starting time for the clip in seconds ( fractions allowed e.g 4.347)
%          te     : Ending time for the clip in seconds (fractions allowed)
%          
%  Notes:  
%   
%  This function is being called from analysis.m GUI. The main purpose is to provide a 
%  a systematic way of keeping track-record of what is being done, when multiple datasets
%  are being clipped and then stitched together to form one dataset, as in
%  Lissajous experiments
%   
%  ?? - created.  
%  05/18/04 - Commented    

if(~isfield(mag,'sectime'))
    mag.sectime = mag.time(:,1) + mag.time(:,2)*1e-6;
end

if(nargin < 3)
    disp('no clipping was performed');
    ts = 0;
    te = max(mag.sectime) - mag.sectime(1,1);
    is = 1;
    ie = length(mag.sectime);
else   
    is = max(find(mag.sectime - mag.sectime(1,1) - ts <= 0.5));
    ie = max(find(mag.sectime - mag.sectime(1,1) - te <= 0.5));
end

clipped.clip.time_offset = mag.sectime(1,1);
clipped.clip.tstart = ts;
clipped.clip.tend = te;
clipped.clip.istart = is;
clipped.clip.t_at_istart = mag.sectime(is,1)-mag.sectime(1,1);
clipped.clip.iend = ie;
clipped.clip.t_at_iend = mag.sectime(ie,1)-mag.sectime(1,1);

% ts-clipped.clip.t_at_istart
% te-clipped.clip.t_at_iend
clipped.sectime = mag.sectime(is:ie);
clipped.analogs = mag.analogs(is:ie,:);
magnets = clipped;
% save('clipped_magnets','magnets');