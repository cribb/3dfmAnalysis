function v = linear_line(t, x)
% 3DFM function  
% Math 
% last modified 02/26/04 
%  
% This function returns linear regression line, sampled at t.  Very useful for
% quickly removing drift from datasets (e.g. no_drift_x = x - linear_line(t,x);)
%  
%  v = linear_line(t, x);  
%   
%  where (t, x) are values for t, and x(t).
%  
%  Notes:  
%   
%  02/26/2004 - created function; jcribb
%   
%  


 [P,S] = polyfit(t, x, 1);
 
 v = polyval(P, t);
 
 