function x = sim_boltzmann_solid(modulus, bead_radius, sampling_rate, duration, temp, dim)
% 3DFM function  
% Rheology 
% last modified 10/10/2010 (jcribb)
%  
% This function outputs the stochastic displacement over time for a bead in
% a Newtonian fluid for a temperature in Kelvin. The viscosity of the fluid, 
% the radius of the bead, the sampling_rate, and the duration of the data 
% collection are all needed for the approximation.  To get a theoretical power 
% spectrum for the same fluid (where sampling_rate -> inf and duration -> inf) look
% at sim_newt_ps.
%  
%  [displacement] = sim_newt_fluid(viscosity, bead_radius, sampling_rate, duration, temp, dim);  
%   
%  where "viscosity" is in [Pa sec] 
%        "bead_radius" is in [m] 
%		 "sampling_rate" is in [Hz] 
%        "duration" is in [s]
%        "temp" is in [K]
%        "dim" is the dimension of diffusion (usually 1D, 2D, 3D)
%  
%  Notes:  
%   
%  - For results that truly approximate the bulk response of the material,
%  you need lots of repeats and averaging.
%   

    
	% randomize state of random number generator
	rand('state',sum(100000*clock));

    time_step = 1 / sampling_rate;    
    k = 1.3806e-23;   % boltzmann's constant
    
    gamma = 6 * pi * bead_radius * modulus;        

    D = k * temp / gamma;

    A = sqrt(2*D);

    x = A * randn(sampling_rate * duration, dim);
    