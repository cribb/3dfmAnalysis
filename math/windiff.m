function [dy,dx] = windiff(y, x, window_size)
% 3DFM function  
% Math 
% last modified 10/23/04 
%  
% This function computes a 'windowed' numerical derivative dy/dx
% of window-length window_size.
%  
%  v = windiff(x, window_size)
%   
%  where "x" is a datastream, dx,  (such as bead position) sampled on an even
%            grid (such as time), dt.
%        "window_size" is a number of array elements between the two points used to
%                      compute the derivative.
%  
%  10/11/04 - created; jcribb.  
%  10/23/04 - added the independent variable, x, so that it is computed properly; jcribb

	A = y(1:end-window_size,:);
	B = y(window_size+1:end,:);
  	C = x(1:end-window_size,:);
	D = x(window_size+1:end,:);
    
    dy = (B-A);
    dx = mean([C D], 2);

