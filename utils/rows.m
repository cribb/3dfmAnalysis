function v = rows(X)
% ROWS Returns the number of rows in a matrix.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%
% This function returns the number of rows in a matrix.
%  
%  [v] = rows(X);
%   
%  where "X" is a matrix.
%

    [r c p] = size(X);

    v = r;
