function v = percent_recovery(x)
% 3DFM function  
% Rheology 
% last modified 08/10/05 (jcribb)
%  
% This function computes the percent recovery of the vector, x.
%  
%  [v] = percent_recovery(x);  
%   
%  07/16/05 - created (jcribb) 
% 

    v = (max(x) - x(end)) / (max(x) - x(1)) * 100;
    
    