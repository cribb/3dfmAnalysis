function v = pole_center(data)
% 3DFM function  
% Image Analysis 
% last modified 11/18/03 
%  
% This function determines the distance to each pole from the 
% geometric center.
%  
%  output = pole_center(data);  
%   
%  where "data" is a two-column matrix containing x,y coordinates of
%               something (e.g. in an image)
%  
%  Notes:  
%   
%  - The output variable is a vector containing pole distances from center.
%    Its length is equal to the number of datapoints passed to pole_center.
%   
%  11/18/03 - created, jcribb.
% 
%  
     center_point = mean(data);
     
     data = neutralize(data);
     
     x = data(:,1);
     y = data(:,2);
     
     dist_from_center = sqrt(x.^2 + y.^2);
     
     v = dist_from_center;