function p = hexa(r)
% hexa(r) -- returns pole locations for axis aligned cubic geometry with
% pole distance r from the field point at the origin

p = r.*[-1,0,0 ; 1,0,0 ; 0,-1,0 ; 0,1,0 ; 0,0,-1 ; 0,0,1];

