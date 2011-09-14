function [vx,vy] = vortex_vectors(x,y,vlx,vly,gamma,vortex_type)
% 3DFMAnalysis function  
% Modeling/Levy_flights 
%  
% This function generates the VX and VY components of a velocity vector field 
% that has within its boundaraies vortices located at VLX and VLY
% positions.  The vortex type may be 'irrotational' or 'rotational':
% Irrotational vortices, a.k.a. free vortices, are those in which fluid is 
% drawn down a drain (tub, whirlpool).  The other type, rotational vortices, 
% are also called force vortices, which occurs when the fluid just circulates.  
% The strength of each vortex is encapulated within 'gamma' but is really 
% the circulation strength in a irrotational vortex and the angular velocity 
% in rotational.
%   Refer to the function 'VorticesStream' as example code that uses
%   'vortex_vectors'. 
%  
% [vx,vy] = vortex_vectors(x,y,vlx,vly,gamma,vortex_type)
%   
%  where "vx"  x-component of velocity vector field in [units]
%        "vy"  y-component of velocity vector field in [units]
%		 "vlx" x-locations for all defined vortices in [units]
%        "vly" y-locations for all defined vortices in [units]
%        "gamma"  circulation strength in [units] 
%        "vortex_type" can be 'irrotational' or 'rotational'
%

vx = zeros(size(x));
vy = zeros(size(x));
vel = zeros(size(x));

% plot out original vector field
for i = 1:length(gamma(:))
    r1 = sqrt((x - vlx(i)).^2 + (y - vly(i)).^2);
    theta = atan2((x-vlx(i)), (y-vly(i))) + pi/2;
    
    if strcmp(vortex_type, 'irrotational')
        
        r1(r1==0) = gamma(i);
        
        vel = gamma(i)./(2*pi*r1);
    else
        vel = 2*pi*gamma(i).*r1;
    end

    vx = vx + vel.*sin(theta);
    vy = vy + vel.*cos(theta);
end

% check for "Infs" and "NaNs" to make everyone play nice.
id1 = isinf(abs(vx));
vx(id1) = 0;
id2 = isinf(abs(vy));
vy(id2) = 0;
id3 = isnan(vx);
vx(id3) = 0;
id4 = isnan(vy);
vy(id3) = 0;

return;
