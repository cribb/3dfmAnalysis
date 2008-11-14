function p = hexaplane(r);
% HEXAPLANE returns pole locations of hexagonal-plane aligned pole  
%
% 3DFM Function 
% magnets/simforces
% last modified 11/14/08 (krisford)

% hexaplane(r) -- Returns pole locations of hexagonal-plane aligned pole
% pieces (jcribb)

p = r .* [          0,            1,          0  ; ...
           -sin(pi/3),    cos(pi/3),          0  ; ...
           -sin(pi/3),   -cos(pi/3),          0  ; ...
                    0,           -1,          0  ; ...
            sin(pi/3),   -cos(pi/3),          0  ; ...
            sin(pi/3),    cos(pi/3),          0  ];
    


