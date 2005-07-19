function v = percent_recovery(x)
% 3DFM function  
% Rheology 
% last modified 07/19/05 (jcribb)
%  
% This function computes the percent recovery of the vector, x.
%  
%  [v] = percent_recovery(x);  
%   
%  10/30/02 - created (jcribb)  
% 

    v = min(x) / max(x) * 100;
    