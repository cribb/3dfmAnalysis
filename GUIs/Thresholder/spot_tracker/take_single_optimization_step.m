% Optimize starting at the specified location to find the best-fit disk.
% Take only one optimization step.  Return whether we ended up finding a
% better location or not.  Return new location in any case.  One step means
% one step in X,Y, and radius space each.  The boolean parameters tell
% whether to optimize in each direction (X, Y, and Radius).
%--------------------------------------------------------------------------

function v = take_single_optimization_step(image, do_x, do_y, do_r)

    % declare globals
    global rad radacc radstep x y pixelacc pixelstep fitness invert TRUE FALSE;

	new_fitness = 0;
	betterxy = FALSE;           % Do we find a better location?
	betterrad = FALSE;          % Do we find a better radius?
	 
    % Try going in +/- x and see if we find a better location
	if (do_x)
        
        x = x + pixelstep;                   % Try going a step in +x
        
        new_fitness = check_fitness(image);
        tolerance = 0.9883;
        
        if ( fitness < new_fitness * tolerance )
            fitness = new_fitness;
            betterxy = TRUE;
        else
            x = x - 2 * pixelstep;           % Try going a step in -x
        end
        
        new_fitness = check_fitness(image);  
        if ( fitness < new_fitness * tolerance)
            fitness = new_fitness;
            betterxy = TRUE;
        else
            x = x + pixelstep;               % Back to where we started in x
        end
        
	end
	
    % Try going in +/- y and see if we find a better location
	if (do_y)
        
        y = y + pixelstep;                    % Try going a step in +y
        
        new_fitness = check_fitness(image);
        if ( fitness < new_fitness * tolerance)
            fitness = new_fitness;
            betterxy = TRUE;
        else
            y = y - 2 * pixelstep;           % Try going a step in -y
        end
        
        new_fitness = check_fitness(image);    
        if ( fitness < new_fitness * tolerance)
            fitness = new_fitness;
            betterxy = TRUE;
        else
            y = y + pixelstep;               % Back to where we started in y
        end
        
	end

    % Try going in +/- one radius and see if we find a better location
	if (do_r)
        
        rad = rad + radstep;                  % Try going a step in +rad
        
        new_fitness = check_fitness(image);
        if ( fitness < new_fitness )
            fitness = new_fitness;
            betterrad = TRUE;
        else
            rad = rad - 2 * radstep;          % Try going a step in -rad
        end
        
        new_fitness = check_fitness(image);   
        if ( rad >= 1 ) & ( fitness < new_fitness )
            fitness = new_fitness;
            betterrad = TRUE;
        else
            rad = rad + radstep;             % Back to where we started in rad
        end
        
	end
    
	% fprintf('\n%d %d %d %f   %d %d %d\n',x,y,rad,fitness,double(betterxy),double(betterrad),double(betterxy | betterrad));

    v = (betterxy | betterrad);