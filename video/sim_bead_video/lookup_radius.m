function [stdev_gaussian] = lookup_radius(bead_radius,calib_um)
%
%Bead_radius is the desired bead radius to be simulated in m. 
%
%Function is capable of calculating a standard deviation for the gauss2d
%function for any bead radius. 
%
%For bead radii of 100nm, 200nm, and 500nm the standard deviations were
%measured from experimental video provided by Dr. Sam Lai (these
%measurements will only be accurate for videos taken on his microscope).
%
%The input "bg" will result in a very large gaussian standard deviation
%used to simulate a frame with a very wide but dim gaussian to be used as a
%background for simulation videos.
%

switch(bead_radius)
    case 5e-8;
        stdev_gaussian = 1.3;
        
    case 1e-7;
        stdev_gaussian = 1.4;
        
    case 2.5e-7;
        stdev_gaussian = 2.6;
        
    case 5e-7;
        stdev_gaussian = 5.2;
        
    case 1e-6;
        stdev_gaussian = 10.4;
        
    case 'bg' %gaussian background frames
        stdev_gaussian = 30000;
        
    otherwise 
        stdev_gaussian = bead_radius*(1/calib_um)*1e6;
end
end