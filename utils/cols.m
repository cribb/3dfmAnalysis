function v = cols(X);
% 3DFM function  
% Utilities 
% last modified 02/25/2004
%  
% This function returns the number of columns in a matrix.
%  
%  [v] = cols(X);
%   
%  where "X" is a matrix.
%  
%  02/25/2004 - created; jcribb


    [r c p] = size(X);

    v = c;
