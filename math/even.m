function v = even(A)
% 3DFM function  
% Math 
% last modified 11/19/02 
%  
%  This function returns even elements of vector A
%
%    v = even(A);
%   
%  where "A" is any vector 
%  
%  Notes:  
%   
%  11/19/02 - created, jcribb 
%  05/04/04 - added documentation 
%  


for k = 1 : length(A)/2
    v(k) = A(2*k);
end