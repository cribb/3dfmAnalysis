function [stdev_gaussian] = lookup_radius(bead_radius,calib_um)
%add if statements for various cameras?
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