% Check the fitness of the disk against an image, at the current parameter settings.
% Return the fitness value there.  This is done by multiplying the image values within
% one radius of the center by 1 and the image values beyond that but within 2 radii
% by -1 (on-center, off-surround).  If the test is inverted, then the fitness value
% is inverted before returning it.  The fitness is normalized by the number of pixels
% tested (pixels both within the radii and within the image).

% Be careful when selecting the surround fraction below.  If the area in the off-
% surround is larger than the on-area, the code seeks for dark surround more than
% for bright center, effectively causing it to seek an inverted patch that is
% that many times as large as the radius (switches dark-on-light vs. light-on-dark
% behavior).

% XXX Assuming that we are looking at a smooth function, we should do linear
% interpolation and sample within the space of the disk kernel, rather than
% point-sampling the nearest pixel.
%-----------------------------------------------------------------------------------
function v = check_fitness(image)

    % declare globals
    global rad radacc radstep x y fitness pixelacc pixelstep invert TRUE FALSE;
	
	pixels = 0;
	my_fitness = 0;
	surroundfac = 1.2;
	centerr2 = rad * rad;
	surroundr2 = centerr2 * surroundfac * surroundfac;
	dist2 = 0;
    
	ilow = floor( x - surroundfac * rad);
	ihigh=  ceil( x + surroundfac * rad);
	jlow = floor( y - surroundfac * rad);
	jhigh=  ceil( y + surroundfac * rad);
	
    [rows cols] = size(image);

	for m = jlow : jhigh
        for n = ilow : ihigh
            dist2 = (m - y) * (m - y) + (n - x) * (n - x);

            if (m > rows) | (n > cols)
                val = 0;
            else
                val = double(image(m,n));
            end

            % See if we are in the inner disk
            if (dist2 <= centerr2)
                pixels = pixels + 1;
                my_fitness = my_fitness + val;
            % See if we are within the outer disk (surroundfac * rad)
            elseif ( dist2 <= surroundr2 )    
                pixels = pixels + 1;
                my_fitness = my_fitness - val;
            end
            
		end
	end
	
    % fprintf('\ncenterr2= %f    surroundr2= %f    pixels= %f    val= %f   my_fitness= %f ', centerr2, surroundr2, pixels, val, my_fitness);
    
	if ( invert)
        my_fitness = -my_fitness;
	end
	
	if (pixels > 0)
        my_fitness = my_fitness / pixels;
	end

    % fprintf('\n v = %f', my_fitness);

    v = my_fitness;

    

