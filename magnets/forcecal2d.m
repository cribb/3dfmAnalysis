function [x_out,y_out,F] = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um)
% 3DFM function  
% Math 
% last modified 06/16/05 
%  
% run a sample velocity profile using data from EVT_GUI
%  
%  [x, y, F] = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um);  
%   
%  where "x & y" are coordinates in units of pixels
%        "F" is the output 2D force grid linearly interpolated by beads in "files"
%        "files" is a string containing the file name(s) for analysis (wildcards ok)
%		 "viscosity" is the calibration fluid viscosity in [Pa s]
%        "bead_radius" is the radius of the probe particles in [m]
%        "poleloc" is the pole location, i.e. [pole_x, pole_y] in [pixels]
%        "calib_um" is the microns per pixel calibration factor.
%  
%  01/??/05 - created.  
%  06/16/05 - added documentation. cleaned up code. fixed bug in
%  force-distance 1D plot.
%   
    
    video_tracking_constants;
    
    % derivative window size
    window_size = 12;
    
    % for every file, get its filename and reduce the dataset to a single table.
    d = load_video_tracking(files,[],'pixels',calib_um,'absolute','yes','table');
	
	max_beadID = max(d(:,ID));
	
    % for each beadID, compute it's velocity and concatenate it to the
    % current data table as new columns [olddata vel_magnitude vel_angle].
	for k = 0 : max_beadID

        temp = get_bead(d, k);

        if(length(temp)>window_size) % avoid taking the derivative for any track 
                                     % whose number of points is less than the 
                                     % window size of the derivative.

            [dxydt, newt, newxy] = windiff(temp(:,X:Y),temp(:,TIME),window_size);
		
            vel = dxydt;
            
            velmag = magnitude(vel);

            force = 6*pi*viscosity*bead_radius*velmag*calib_um*1e-6;

            % setup the output variables
            if ~exist('finalxy');  
                finalxy = newxy;
            else
                finalxy = [finalxy ; newxy];
            end
            
            if ~exist('finalF');
                finalF = force;
            else
                finalF = [finalF ; force];
            end
            
        end
	end
	
    % set up for plotting
    warning off MATLAB:griddata:DuplicateDataPoints; 

    x = finalxy(:,1);
	y = finalxy(:,2);
	z = finalF*1e12;
    
    x_out = 1:648; 
    y_out = 1:484; 
    
    myMIP = mip('*.MIP.bmp');
    
	[xi,yi] = meshgrid(x_out, y_out);
	zi = griddata(x, y, z, xi, yi);
        
    % now, for the plots...
	figure;
    subplot(1,2,1);
    imagesc(myMIP); 
    colormap(copper(256));
    hold on;
		plot(x,y,'.');
    hold off;
    axis([0 648 0 484]);
	xlabel('x [pixels]'); ylabel('y [pixels]'); set(gca, 'YDir', 'reverse');
    
    newr = magnitude((x-poleloc(1)),(y-poleloc(2)));
    subplot(1,2,2);
    plot(newr, z, '.');
    grid on;
	xlabel('r'); ylabel('force (pN)');

    figure;
	plot3(finalxy(:,1), finalxy(:,2), finalF, '.');
    colormap(hot);
	zlabel('force (pN)');
    
    figure; 
	imagesc(x_out,y_out,zi);
	colormap(hot);
	colorbar; 
        
    % provide force as output table
	F = zi;

