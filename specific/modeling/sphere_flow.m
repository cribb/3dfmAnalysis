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
	vr = -vd * cos(theta) * (1 - (3*a)./(2*r) + (a.^3)./(2*r.^3));
	vtheta = vd * sin(theta) * (1 - (3*a)./(4*r) - (a.^3)./(4*r.^3));
    
    % plot the results     
    if length(theta) > 1 & length(r) > 1
 
        MXtheta = repmat(theta, size(r));
        MXr = repmat(r, size(theta));
        
        r = MXr;
        theta = MXtheta;
        
        % extract the locations of the measurements in the cartesian coordinate 
        % system for plotting purposes    
		X =  r .* cos(theta);
		Y =  r .* sin(theta);
        U = vr .* cos(theta) - vtheta .* sin(theta);
        V = vr .* sin(theta) + vtheta .* cos(theta);
 
        Z = sqrt(vr.^2 + vtheta.^2);
        
        h=figure(100);
%         surface(X, Y, Z);
% 
%         colormap(hot(256));
%         colorbar;
%         % this turns off mesh lines on surface (they may get into the way here)
%         set(get(gca, 'Children'), 'EdgeColor', 'flat')
%         hold on;       

        [sx, sy] = meshgrid([min(min(Y)):(max(max(Y))-min(min(Y)))/10:max(max(Y))]' , max(max(X)));
        quiver(X, Y, U, V, 0.4);
%         streamlines(X,Y,U,V);

    end
    
    % The velocity vector results in a component that is parallel
    % to the unit vector, vr, and a component that is normal to the unit
    % vector, vtheta.  The unit vector in this case is aligned with the
    % input, r, which is the radius of the measurement location.
    vel.theta = theta;
    vel.r     = r;
    vel.vr    = vr;
    vel.vtheta= vtheta;
%     vel.U = U;
%     vel.V = V;
    
    