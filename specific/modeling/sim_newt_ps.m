function [f,ps] = sim_newt_ps(viscosity, bead_radius, sampling_rate, duration, temp)
% 3DFM function  
% Rheology 
% last modified 11/17/04 
%  
% This function outputs the power spectrum for a bead in a Newtonian fluid.
% The viscosity of the fluid, the radius of the bead, the sampling_rate, 
% and the duration of the data collection are all needed for the approximation.
% To get a stochastic time dataset for the same fluid look at sim_newt_fluid_1D.
%  
%  [freq,ps] = sim_newt_ps(viscosity, bead_radius, sampling_rate, duration, temp);  
%   
%  where "viscosity" is in [Pa sec] 
%        "bead_radius" is in [m] 
%		 "sampling_rate" is in [Hz] 
%        "duration" is in [s]
%        "temp" is in [K]
%   
%  11/17/04 - created; jcribb.
%  05/09/04 - added documentation.
%  

    time_step = 1 / sampling_rate;    
    k = 1.3806e-23;   % boltzmann's constant
    
    icept = log10( ( k*temp ) / ( 6 * pi^3 * viscosity * bead_radius ) );
    
    f = [ 1/duration : 1/duration : sampling_rate/2 ];
    
    log10ps = -2 * log10(f) + icept;
    
    ps = 10.^log10ps;