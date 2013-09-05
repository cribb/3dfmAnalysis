function XY = sim_boltzmann_solid(modulus, bead_radius, sampling_rate, duration, temp, dim, numpaths)
% 3DFM function  
% Rheology 
% last modified 09/4/13 (yingzhou)
%  
% This function outputs the stochastic displacements over time for a bead in
% a boltzmann solid for a temperature in Kelvin. The modulus of the fluid, 
% the radius of the bead, the sampling_rate, and the duration of the data 
% collection are all needed for the approximation.  
%  
%  [displacement] = sim_boltzmann_solid(modulus, bead_radius, sampling_rate, duration, temp, dim)  
%   
%  where "modulus" is in [Pa] water is 2.2e9 Pa, glass is 35-55e9 Pa
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

XY=[];

for n=1:numpaths    
	% randomize state of random number generator
	rand('state',sum(100000*clock));

    time_step = 1 / sampling_rate;    
    k = 1.3806e-23;   % boltzmann's constant
    
    gamma = 6 * pi * bead_radius * modulus;        

    D = k * temp / gamma;

    A = sqrt(2*D);

    xy = A * randn(sampling_rate * duration, dim);
    
    xy0 = xy(1,:);
    
    xy0 = repmat(xy0, sampling_rate*duration, 1); 
    
    xy(:,:) = xy(:,:)- xy0;  %subtracts the randomized offsets from all displacement values so that the position at time=0 is (0,0)
    
    XY(:,:,n)=xy;

end    
    