function v = sim_newt_fluid_3D(viscosity, bead_radius, sampling_rate, duration, temp)
% 3DFM function  
% Rheology 
% last modified 11/17/04 
%  
% This function outputs the stochastic 3D displacement over time for a bead in
% a Newtonian fluid for a temperature in Kelvin. The viscosity of 
% the fluid, the radius of the bead, the sampling_rate, and the duration of the data 
% collection are all needed for the approximation.  To get a theoretical power 
% spectrum for the same fluid (where sampling_rate -> inf and duration -> inf) look
% at sim_newt_ps.
%  
%  [displacement] = sim_newt_fluid(viscosity, bead_radius, sampling_rate, duration);  
%   
%  where "viscosity" is in [Pa sec] 
%        "bead_radius" is in [m] 
%		 "sampling_rate" is in [Hz] 
%        "duration" is in [s]
%  
%  Notes:  
%   
%  - For results that truly approximate the bulk response of the material,
%  you need lots of repeats and averaging.
%   
%  11/17/04 - created; jcribb.
%  05/09/05 - added documentation.   
%  

	% randomize state of random number generator
	rand('state',sum(10000*clock));

    time_step = 1 / sampling_rate;    
    k = 1.3806e-23;   % boltzmann's constant
    
    gamma = 6 * pi * viscosity * bead_radius;        
    D = k * temp / gamma;
    A = sqrt(6*D*time_step);

    % construct the magnitude of the random walk vector
    mags = A * randn(sampling_rate * duration, 1);
    
    % construct the angles of the random walk vector;
    theta = 2*pi * rand(sampling_rate * duration,1);
    phi = 2*pi * rand(sampling_rate * duration,1);

    % construct the random walk
    x = cumsum(mags .* cos(phi) .* cos(theta));
    y = cumsum(mags .* sin(phi) .* sin(theta));
    z = cumsum(mags .* sin(phi));
    
    v = [x y z];
    

