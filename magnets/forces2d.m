function [newxy,F] = forces2d(video_tracking_data, viscosity, bead_radius, calib_um, window_size);

    video_tracking_constants;
    
    temp = video_tracking_data;    

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