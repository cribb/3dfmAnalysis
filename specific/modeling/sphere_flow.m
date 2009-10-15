function [vel,h] = sphere_flow(vd, a, X, Y)
% 3DFM function  
% Modeling 
% last modified 05/09/05
%  
% This function models the fluid flow around a sphere.  The fluid (or the
% sphere) is assumed to move at a constant, unidirectional velocity.  No-
% slip boundary conditions are assumed at the sphere's surface and the
% surrounding solution is assumed to extend to infinity beyond the bead.
% All units are assumed SI. Reference:  Random Walks in Biology.
%  
%  [vel] = sphere_flow(vd, theta, a, r);  
%   
%  where "vd" is the constant velocity of fluid (or sphere)
%        "theta" is angle locations around sphere 
%		 "a" is the diameter of the modeled sphere
%        "r" is radial distances from sphere
%  
%  05/09/05 - created; jcribb.
%  

    
    [Xgrid,Ygrid] = meshgrid(X, Y);

    XYgrid = Xgrid + i*Ygrid;

    idx = find(abs(XYgrid) <= a);
    XYgrid(idx) = 0;
    
    theta = angle(XYgrid);
    r = abs(XYgrid);
    

    vr = -vd * cos(theta) .* (1 - (3*a)./(2*r) + (a.^3)./(2*r.^3));
	vtheta = vd * sin(theta) .* (1 - (3*a)./(4*r) - (a.^3)./(4*r.^3));
    
    gammadot = vd * sqrt( cos(theta).^2 .* (r.^-1 - (3/4)*a*r.^-2 - (1/4) * a^3*r.^-4).^2 ...
                        + sin(theta).^2 .* ((3/2)*a*r.^-2 - (3/2)*a^3*r.^-4).^2 );
                    
    VX = vr .* cos(theta) - vtheta .* sin(theta);
    VY = vr .* sin(theta) + vtheta .* cos(theta);
    
    % plot the results     
    if length(theta) > 1 || length(r) > 1        
        
        h=figure;

        [sx, sy] = meshgrid([min(min(Y)):(max(max(Y))-min(min(Y)))/10:max(max(Y))]' , max(max(X)));
        quiver(X, Y, VX, VY);
    end
    
    VX(idx) = 0;
    VY(idx) = 0;

    % The velocity vector results in a component that is parallel
    % to the unit vector, vr, and a component that is normal to the unit
    % vector, vtheta.  The unit vector in this case is aligned with the
    % input, r, which is the radius of the measurement location.
    vel.theta = theta;
    vel.r     = r;
    vel.vr    = vr;
    vel.vtheta= vtheta;
    vel.x = X;
    vel.y = Y;
    vel.vx= VX;
    vel.vy= VY;
    vel.gammadot = gammadot;
    
%     vel.VX = VX;
%     vel.VY = VY;
    
    