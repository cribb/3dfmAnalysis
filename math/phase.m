function v = phase(A,B)
% 3DFM function  
% Math 
% last modified 05/07/04 
%  
%  This function computes the phase angle of A & B.  Different from
%  Matlab's angle in that you don't have to use complex variables.
%
%     v = phase(A,B);
%   
%  where "A" and "B" are vector components in (x,y) coordinate system.
%  
%  Notes:  
%   
%  11/19/02 - created; jcribb 
%  05/07/04 - added documentation; jcribb
%  05/21/05 - reduced noise at phase wrap-arounds by using atan2

    v = atan2(B,A);
    
    
