% Find the best fit for the spot detector within the image, taking steps
% that are 1/4 of the bead's radius.  Stay away from edge effects by staying
% away from the edges of the image.
%---------------------------------------------------------------------------
function locate_good_fit_in_image(image)

    % declare globals
    global rad radacc radstep x y pixelacc pixelstep fitness invert TRUE FALSE;

    minx=0;
	maxx=320;
	miny=0;
	maxy=240;
	
% 	bestx=200;
% 	besty=210;
	bestfit = -1e10;
	
	newfit = 0;
	
	ilow =  floor( minx + 2 * rad + 1);
	ihigh=   ceil( maxx - 2 * rad - 1);
	jlow =  floor( miny + 2 * rad + 1);
	jhigh=   ceil( maxy - 2 * rad - 1);
	
	step = ceil( rad / 4 )
	
	if (step < 1)
        step = 1;
	end
	
	for m=ilow:step:ihigh
        for n = jlow:step:jhigh
            x = m;
            y = n;
            
            newfit = check_fitness(image);
            
            if bestfit < newfit
                bestfit = newfit;
                bestx = x;
                besty = y;
            end
        end
	end
	
	x = bestx;
	y = besty;
	fitness = newfit;