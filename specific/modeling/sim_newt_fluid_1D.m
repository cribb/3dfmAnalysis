function x = sim_newt_fluid_1D(viscosity, bead_radius, sampling_rate, duration, temp)
% 3DFM function  
% Rheology 
% last modified 11/17/04 
%  
% This function outputs the stochastic 1D displacement over time for a bead in
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
    A = sqrt(2*D*time_step);
    v = A * randn(sampling_rate * duration, 1);

    x =  cumsum(v);
    
