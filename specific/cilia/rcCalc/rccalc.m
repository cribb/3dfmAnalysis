%This function takes an input of 3 points and caculates the arc length and radius
%of curvature. If given only two points it outputs 0 for the radius of curvature
%and outputs the length of the line.


function [rc, arc_length] = rccalc(points)

%calculate length of the three sides
a = sqrt((points(1,1)-points(2,1))^2+(points(1,2)-points(2,2))^2);
c = sqrt((points(1,1)-points(3,1))^2+(points(1,2)-points(3,2))^2);
b = sqrt((points(2,1)-points(3,1))^2+(points(2,2)-points(3,2))^2);

%calculate radius of curvature using a circumscribed circle around triangle
%formula from wolfram math world. <http://mathworld.wolfram.com/Circumradius.html>
rc = a*b*c/(sqrt((a+b+c)*(b+c-a)*(c+a-b)*(a+b-c)));

%Determin weather the the angle across from c is acute or obtuse.

alpha = acos((a^2+b^2-c^2)/(2*a*b));

theta = acos((2*rc^2-c^2)/(2*rc^2));

%calculate arc angle using law of cosines then arc length
%taking into account the two cases weather or not the
%circumcenter lies inside or outside the triangle
    if alpha < pi/2
        arc_length = rc*(2*pi-theta);
    else
        arc_length = rc*theta;

    end
