function v = iseven(num)
% 3DFM function  
% Math 
% last modified 11/19/02 
%  
%  This function returns a 1 if even, 0 if not (odd)
%
%     v = odd(A);
%   
%  where "A" is any value.
%  
%  Notes:  
%   
%  11/17/03 - created; jcribb 
%  05/04/04 - added documentation; jcribb
%  
   if mod(num, 2) == 0
       v = 1;
   else
       v = 0;
   end
   
   