function [newxy,F] = forces2d(t, xy, viscosity, bead_radius, window_size);
% 3DFM function  
% Magnetics 
% last modified 07/31/06 
%  
% This function computes 2d forces on beads in Newtonian fluid using Stokes
% drag.
%  
%  [newxy,F] = forces2d(t, xy, viscosity, bead_radius, window_size);
%   
%  where "newxy" are the x and y positions on the new grid
%        "F" is the computed force in [N]
%        "t" is a vector of timestamps in [s]
%        "xy" is a matrix containing [x;y] positions in [m]
%        "viscosity" of the Newtonian standard solution in [Pa s]
%        "bead_radius" in [m]
%        "window_size" is an integer describing the derivative's time-step, tau
%   

    if(length(t)>window_size) % avoid taking the derivative for any track 
                                 % whose number of points is less than the 
                                 % window size of the derivative.

        [vel_xy, newt, newxy] = windiff(xy, t, window_size);		

        velmag = magnitude(vel_xy);
        F = (6*pi) * viscosity * bead_radius * velmag;
    else
        newxy = [];
        F = [];
    end
      
