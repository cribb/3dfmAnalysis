function vel = sphere_flow(vd, theta, a, r);
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

    if (rows(theta) == 1) & (rows(theta) == rows(r))
        theta = theta';
    end

    % Calculates the velocity of fluid at a polar coordinate wrt the
    % sphere's center, i.e. [0 0].  The velocity at this point is a vector
    % with two components:  along the radial component of the coordinate system 
    % is vr, while the azimuthal component is vtheta.
	vr = -vd * cos(theta) * (1 - (3*a)./(2*r) + (a.^3)./(2*r.^2));
	vtheta = vd * sin(theta) * (1 - (3*a)./(4*r) - (a.^3)./(4*r.^2));
    
    % The velocity vector results in a component that is parallel
    % to the unit vector, vr, and a component that is normal to the unit
    % vector, vtheta.  The unit vector in this case is aligned with the
    % input, r, which is the radius of the measurement location.
    vel = vr + j*vtheta;
    
    % plot the results     
    if length(theta) > 1 & length(r) > 1
 
        % extract the locations of the measurements in the cartesian coordinate 
        % system for plotting purposes    
		X = r'*cos(theta');
		Y = r'*sin(theta');
        
        h=figure;
        surf(X, Y, abs(vel'));
        colormap(winter(256));
        colorbar;

        % this turns off mesh lines on surface (they may get into the way here)
        set(get(gca, 'Children'), 'EdgeColor', 'flat')
    end