function v = cummean(x)
% 3DFM function  
% Math 
% last modified 04/08/04 
%  
% This function computes the cumulative mean for a vector x.
%  
%  v = cummean(x);  
%   
%  where "x" is any vector.
%  
%  Notes:  
%  - Useful in stochastic model analysis.
%
%   
%  04/08/04 - created; jcribb  
%   
%  


N = [1:length(x)]';

v = cumsum(x)./N;


