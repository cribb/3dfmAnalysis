% Continue to optimize until we can't do any better (the step size drops
% below the minimum).  Only try moving in X and Y, not changing the radius
%-----------------------------------------------------------------------
function optimize_xy(image)

    % declare globals
    global rad radacc radstep x y pixelacc pixelstep fitness invert TRUE FALSE;

    % set the step sizes to a large value to start with
    pixelstep = 2;
    

    % find out what our current value is (presumably this is a new image
    fitness = check_fitness(image);
    
    % Try with ever-smaller steps until we reach the smallest size and can't do any better
    while(TRUE)
        
        % Repeat the optimization steps until we can't do any better        
        while (take_single_optimization_step(image, TRUE, TRUE, FALSE));
        end
        
        % Try and see if reducing the step sizes helps
        if ( pixelstep > pixelacc )
            pixelstep = pixelstep / 2;
        else
            break;
        end
    end
    
