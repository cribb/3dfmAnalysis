function v = ms(d)
% 3DFM function  
% Math 
% last modified 05/07/04 
%  
%  This function computes the mean-square of d.
%
%     v = ms(d);
%   
%  where "d" is any value.
%  
%  Notes:  
%   
%  11/19/02 - created; jcribb 
%  05/07/04 - added documentation; jcribb

  v = mean(d.^2);
