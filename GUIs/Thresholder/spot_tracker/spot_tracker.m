function [newx,newy,newrad] = spot_tracker(image,current_x,current_y,current_rad,my_invert)
	
	global rad; 	         % Current radius of the disk
	global radacc;           % Minimum radius step size to try
	global radstep;          % Current radius step
	global x y;              % Current best-fit position of the disk
	global pixelacc;         % Minimum step size in X,Y
	global pixelstep;        % Current X,Y pixel step size
	global fitness;          % Current value of match for the disk
	global invert;           % Do we look for a dark spot on a black background?
	global TRUE; 
	global FALSE;
	
    TRUE  = int32(1);
    FALSE = int32(0);
    

    pixelacc = 0.25;
    radacc = 0.25;
    invert = my_invert;
    fitness = -1e10;
    
    x = current_x;
    y = current_y;
    rad = current_rad;
    
	% Make sure the parameters make sense
    if ( rad <= 0 )
        warning('Invalid Radius, Using 1.0.');
        rad = 1.0;
	end
	
	if ( pixelacc <= 0 )
        warning('Invalid pixel accuracy, using 0.25.');
        pixelacc = 0.25;
	end
	
	if ( radacc <= 0 )
        warning('Invalid radius accuracy, using 0.25.');
        radacc = 0.25;
	end
	
	% Set the initial step sizes for radius and pixels
	pixelstep = 2.0;
	if ( pixelstep < 4 * pixelacc )
        pixelstep = 4 * pixelacc;
	end
	
	radstep = 2.0;
	if ( radstep < 4 * radacc )
        radstep = 4 * radacc;
	end

    % Now, do the optimization
    optimize_xy(image);
    
    % Output the new position & radius
    newx = x;
    newy = y;
    newrad = rad;

