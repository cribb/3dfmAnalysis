function p = trigplane(r);
% trigplane(r) -- Returns pole locations of trigonal-plane aligned pole
% pieces (jcribb)

p = r .* [0, 1, 0 ; -sin(pi/6), -cos(pi/6), 0 ; sin(pi/6), -cos(pi/6), 0];

