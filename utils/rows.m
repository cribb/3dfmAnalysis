function v = rows(X);
% 3DFM function  
% Utilities 
% last modified 05/09/2005
%  
% This function returns the number of rows in a matrix.
%  
%  [v] = rows(X);
%   
%  where "X" is a matrix.
%  
%  05/09/2005 - created; jcribb


    [r c p] = size(X);

    v = r;
