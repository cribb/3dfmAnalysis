function v = rms(d)
% 3DFM function  
% Math 
% last modified 05/07/04 
%  
%  This function computes the root-mean-square of d.
%
%     v = rms(d);
%   
%  where "d" is any value.
%  
%  Notes:  
%   
%  11/19/02 - created; jcribb 
%  05/07/04 - added documentation; jcribb


  v = sqrt(mean(d.^2));
