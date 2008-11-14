function p = trigplane(r);
% TRIGPLANE Returns pole locations of hexagonal-plane aligned pole
%
% 3DFM Function 
% magnets/simforces
% last modified 11/14/08 (krisford)

% hexaplane(r) -- Returns pole locations of hexagonal-plane aligned pole
% pieces (jcribb)

p = r .* [         0,           1,             0 ; ...
          -sin(pi/6),  -cos(pi/6),             0 ; ...
           sin(pi/6),  -cos(pi/6),             0 ];

