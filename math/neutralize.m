function v = neutralize(data)
% 3DFM function  
% Math 
% last modified 06/20/03 
%  
% This function neutralizes a datset (subtracts the mean)  
%  
%  [output] = neutralize(data);  
%   
%  where "data" is any 2-D matrix. 
%  
%  Notes:  
%   
%   
%  09/10/03 - created, jcribb
%   
% 


[rows cols] = size(data);
v = data - repmat(mean(data,1),rows,1);;

