function v = pole_distances(data)
% 3DFM function  
% Image Analysis 
% last modified 11/18/2003 
%  
% This function computes the distances from each point inputted to every
% other present point.  Pole_distances receives an entire dataset at once.
%  
%  [output] = pole_distances(data)
%   
%  where "data" is a two-column matrix containing x,y coordinates of
%               something (e.g. in an image )
%  
%  Notes:  
%   
%  - The output variable is a square matrix where the side length   
%    is equal to the number of datapoints passed to pole_distances.
%   
%  11/18/03 - created, jcribb.
%   
%  

	[rows cols] = size(data);
    	
	for m = 1 : rows
 
        for n = 0 : (rows-1)
           
            dists(m,n+1) = sqrt( (data(m,1)-data(n+1,1))^2 + (data(m,2)-data(n+1,2))^2 );
            
        end
        
	end

	v = dists;