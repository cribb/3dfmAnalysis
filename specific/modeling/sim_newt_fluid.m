function x = sim_newt_fluid(viscosity, bead_radius, sampling_rate, duration, temp, dim, numpaths, seed)
% 3DFMAnalysis function  
% Rheology 
% last modified 04/24/2006 (jcribb)
%  
% This function outputs the stochastic displacement over time for a bead in
% a Newtonian fluid for a temperature in Kelvin. The viscosity of the fluid, 
% the radius of the bead, the sampling_rate, and the duration of the data 
% collection are all needed for the approximation.  To get a theoretical
% power spectrum for the same fluid (where sampling_rate -> inf and duration ->
% inf) look at sim_newt_ps.
%  
%  [displacement] = sim_newt_fluid(viscosity, bead_radius, sampling_rate,
%                                  duration, temp, dim, numpaths, seed);  
%   
%  where "viscosity" is in [Pa sec] 
%        "bead_radius" is in [m] 
%		 "sampling_rate" is in [Hz] 
%        "duration" is in [s]
%        "temp" is in [K]
%        "dim" is the dimension of diffusion (usually 1D, 2D, 3D)
%        "numpaths" is the number of discrete particle paths you wish to model
%        "seed" is the value to send the random-number generator.  If one is not selected, the system clock will be used to generate a unique one
%  
%  Notes:  
%   
%  - For results that truly approximate the bulk response of the material,
%  you need lots of repeats and averaging.
%   

if nargin < 8
    seed = [];
end

    v = sim_newt_steps(viscosity, bead_radius, sampling_rate, duration, temp, dim, numpaths, seed);

    x =  cumsum(v);
    