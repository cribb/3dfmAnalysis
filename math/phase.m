function v = phase(A,B)
% 3DFM function  
% Math 
% last modified 05/07/04 
%  
%  This function computes the phase angle of A & B.
%
%     v = rms(A,B);
%   
%  where "A" and "B" are vector components in (x,y) coordinate system.
%  
%  Notes:  
%   
%  11/19/02 - created; jcribb 
%  05/07/04 - added documentation; jcribb

    v = atan(B./A);
    
    
