function v = cols(X)
% COLS Returns the number of columns in a matrix.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%  
% This function returns the number of columns in a matrix.
%  
%  [v] = cols(X);
%   
%  where "X" is a matrix.
%  

    [r c p] = size(X);

    v = c;
