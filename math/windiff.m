function [dydx, newx] = windiff(y, x, window_size)
% 3DFM function  
% Math 
% last modified 10/26/04 
%  
% This function computes a 'windowed' numerical derivative dy/dx
% of window-length window_size.  It returns the derivative as dydx, and
% also returns the grid, newx, on which the derivative was calculated.
%  
%  [dydx, newx] = windiff(y, x, window_size)
%   
%  where "x" is a datastream's independent variable
%        "y" is a datastream's dependent variable
%        "window_size" is a number of array elements between the two points used to
%                      compute the derivative.
%  
%  10/11/04 - created; jcribb.  
%  10/23/04 - added the independent variable, x, so that its grid is computed properly; jcribb
%  10/26/04 - fixed a bug in calculation; jcribb.
%  11/17/04 - updated documentation, switched outputs to be more consistent.
%


	A = y(1:end-window_size,:);
	B = y(window_size+1:end,:);
  	C = x(1:end-window_size,:);
	D = x(window_size+1:end,:);
    
    dy = (B-A);
    dx = (D-C);
    
    dydx = dy./dx;
    newx = mean([C D], 2);

