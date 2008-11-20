function gamma_dot_max = shear_rate_max(vd, bead_radius)
% SHEAR_RATE_MAX Computes maximum shear rate experienced by a bead immersed in a fluid and subjected to an external force 
%
% 3DFM function
% specific/rheology/driven_bead
% last modified 11/20/08 (krisford)
%  
% Computes the maximum shear rate experienced by a bead immersed in a fluid 
% and subjected to an external force.  The equations used to derive this
% relationship are found in Howard Berg's _Random Walks in Biology_, page 55.
% The maximum shear rate is at an angle of pi/2 (or symmetrically at 3pi/2), 
% where a zero angle runs in the direction of the bead's velocity vector.  
% These are the only angles at which the bead experiences shear forces 
% exclusively.  Other angles would include an extensional component (and a 
% zero or 180 degree angle would experience exclusively extensional or 
% compressional flow).
%
%  gamma_dot_max = shear_rate_max(vd, bead_radius)
%   
%  where "gamma_dot_max" is the maximum shear rate in [s^-1]
%        "vd" is the velocity vector of the bead in [m/s]
%		 "bead_radius" is in [m]
%  

theta = pi/2;

gamma_dot_max = 3 * vd .* sin(theta) ./ (2*bead_radius);

