function [newtime,newdata] = clipper(time, data, start, stop)
% CLIPPER Clips a dataset to include only points between "start" and "stop"
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%  
% This function clips a dataset from start time to stop_time.  This
% is useful as the user does not need array indices in order to clip 
% data.
%  
%  [newtime,newdata] = clipper(time, data, start, stop);
%   
%  where "time" is a vector of timestamps in units of seconds
%        "data" is a matrix of datapoints in arbitrary units
%	       "start" is the start time of WANTED DATA in seconds
%        "stop" is the stop time of WANTED DATA in seconds
%  


indices = find( (time > start) & (time < stop) );

newtime = time(indices);
newdata = data(indices,:);
