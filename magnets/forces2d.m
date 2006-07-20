function [newxy,F] = forces2d(video_tracking_table, viscosity, bead_radius, calib_um, window_size);
% 3DFM function  
% Magnetics 
% last modified 07/20/06 
%  
% This function computes 2d forces on beads in Newtonian fluid using Stokes
% drag.
%  
%  [newxy,F] = forces2d(video_tracking_table, viscosity, bead_radius, calib_um, window_size);
%   
%  where "newxy" are the x and y positions on the new grid
%        "F" is the computed force in [N]
%        "video_tracking_table" is the data table returned from load_video_tracking
%        "viscosity" of the Newtonian standard solution in [Pa s]
%        "bead_radius" in [m]
%        "calib_um" is the length calibration factor in [microns/pixel]
%        "window_size" is an integer describing the derivative's time-step, tau
%   


    video_tracking_constants;
    
    temp = video_tracking_table;    

    if(length(temp)>window_size) % avoid taking the derivative for any track 
                                 % whose number of points is less than the 
                                 % window size of the derivative.

        [dxydt, newt, newxy] = windiff(temp(:,X:Y),temp(:,TIME),window_size);		
        vel = dxydt;            
        velmag = magnitude(vel);
        F = (6*pi) * viscosity * bead_radius * velmag * calib_um * 1e-6;
    else
        newxy = [];
        F = [];
    end
    
    