function joined = mjoin(m1,m2)
% 3DFM function  
% GUI Analysis 
% last modified 05/18/04 
%  
% This function joins two datasets for the fields provided in arguement
%  
%  joined = mjoin(m1,m2)
%  
%  where joined : dataset as result of stitching of two inputs datasets
%          m1     : the first dataset 
%          m2     : the second dataset, to be appended to m1
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
%           
if(isfield(m1,'joints'))
    len = length(m1.joints);
    joined.joints = m1.joints;
    i = len+1;
else
    i = 1;
    joined.joints(i,1).time_offset = m1.clip.time_offset;
    joined.joints(i,1).tstart = m1.clip.tstart;
    joined.joints(i,1).tend = m1.clip.tend;
    joined.joints(i,1).istart = m1.clip.istart;
    joined.joints(i,1).iend = m1.clip.iend;  
    i = 2;
end

if(isfield(m2,'joints'))
    j = length(m2.joints);
    for k = 1:j
        joined.joints(i,1).time_offset = m2.joints(k,1).time_offset;
        joined.joints(i,1).tstart = m2.joints(k,1).tstart;
        joined.joints(i,1).tend = m2.joints(k,1).tend;
        joined.joints(i,1).istart = m2.joints(k,1).istart;
        joined.joints(i,1).iend = m2.joints(k,1).iend;
        i = i+1;
    end
else
    joined.joints(i,1).time_offset = m2.clip.time_offset;
    joined.joints(i,1).tstart = m2.clip.tstart;
    joined.joints(i,1).tend = m2.clip.tend;
    joined.joints(i,1).istart = m2.clip.istart;
    joined.joints(i,1).iend = m2.clip.iend;    
end

m2.sectime = m2.sectime - m2.sectime(1,1) + m1.sectime(end);
joined.sectime = [m1.sectime ; m2.sectime];
joined.analogs = [m1.analogs ; m2.analogs];
