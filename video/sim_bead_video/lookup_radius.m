function [stdev_gaussian] = lookup_radius(bead_radius)
%add if statements for various cameras?
switch(bead_radius)
    case 5e-8;
        stdev_gaussian = 1.3;
        
    case 1e-7;
        stdev_gaussian = 1.4;
        
    case 2.5e-7;
        stdev_gaussian = 2.6;
        
end
end