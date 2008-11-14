function p = tetra(r)
% TETRA Returns pole locations of xy-axis aligned tetrahedral pole geom with pole distances r from the field point at the origin    
%
% 3DFM Function 
% magnets/simforces
% last modified 11/14/08 (krisford)

% tetra(r) -- Returns pole locations of xy-axis aligned tetrahedral pole
% geometry with pole distances r from the field point at the origin.
rt13 = sqrt(1/3);
rt23 = sqrt(2/3);
p = r.*[rt23,0,-rt13; -rt23,0,-rt13; 0,rt23,rt13; 0,-rt23,rt13];
