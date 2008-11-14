function p = hexa(r)
% HEXA returns pole locations for axis aligned cubic geom. w/pole distance r from the field pt. at the origin 
%
% 3DFM Function 
% magnets/simforces
% last modified 11/14/08 (krisford)

% hexa(r) -- returns pole locations for axis aligned cubic geometry with
% pole distance r from the field point at the origin

p = r.*[-1,0,0 ; 1,0,0 ; 0,-1,0 ; 0,1,0 ; 0,0,-1 ; 0,0,1];

