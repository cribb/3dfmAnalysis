function v = odd(A);
% 3DFM function  
% Math 
% last modified 11/19/02 
%  
%  This function chooses the odd elements of a vector
%
%     v = odd(A);
%   
%  where "A" is any vector 
%  
%  Notes:  
%   
%  11/19/02 - created, jcribb 
%  05/04/04 - added documentation 
%  



% Have to take care of MatLab's 1 indexing problem
% In that case, the first element it will pull out
% in the odd case is 3.
v(1) = A(1);

if mod(length(A/2),2)
    % If a remainder exists, then vector A has odd length
    
    for k=1:length(A)/2
        v(k+1) = A(2*k + 1);
    end

else
    % If there is no remainder, then vector A has even length
    
    for k=1:(length(A)/2)-1
        v(k+1) = A(2*k + 1);
    end
    
end