function v = pole_regularity(pole_distance_matrix)
% 3DFM function  
% Image Analysis 
% last modified 11/19/03 
%  
% This function determines the "regularity" of a pole-set.  It assumes that
% the goal of a pole-configuration is a regular polygon with all equal sides
% and equal angles.
%  
%  output = pole_regularity(pole_distance_matrix);  
%   
%  where "pole_distance_matrix" is a square matrix containing pole lengths.
%         You can use the output of the "pole_distances" function here.
%  
%  Notes:  
%   
%   - The output variable is a scalar value between 0 and 1 where 1 is a
%     perfectly regular set of pole pieces.
%   
%  11/19/03 - created, jcribb.
%   
%  

	data = pole_distance_matrix;
    
    [rows cols] = size(data);
    
    for n = 1 : (rows - 1)
        dists(n) = data(n, n+1);    
    end
    
    dists(rows) = data(rows, 1);
        
    regularity = 1 - (std(dists)/mean(dists));
    
    
    v = regularity;    