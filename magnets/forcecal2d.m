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
%  06/16/05 - added documentation.
%   

    
    video_tracking_constants;
    
    % turn off the divide by zero warning because there's a divide by zero
    % in the determination of the derivative
	warning off MATLAB:divideByZero;
    
    fp = dir(files);
    
    % derivative window size
    window_size = 12;
    
    % for every file, get its filename and reduce the dataset to a single table.
    d = load_video_tracking(files,[],'pixels',calib_um,'absolute','yes','table');
	
	beadID = d(:,ID);
	
    % for each beadID, compute it's velocity and concatenate it to the
    % current data table as new columns [olddata vel_magnitude vel_angle].
	for k = 0 : max(beadID)
        idx = find(beadID == k);
        temp = d(idx,:);
        
        if(length(idx)>window_size) % avoid any gaps in beadID numbers
            [dxydt, newt, newxy] = windiff(temp(:,X:Y),temp(:,TIME),window_size);
		
            vel = dxydt;
            
            velmag = magnitude(vel);
            velang = angle(vel); 
            
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
	
        % do some plotting
        x = finalxy(:,1);
		y = finalxy(:,2);
		z = finalF*1e12;
        
        x_out = 1:648; %min(x):range(x)/648:max(x);
        y_out = 1:484; %min(y):range(y)/484:max(y);
        
        myMIP = mip('*.MIP.bmp');
        
        warning off MATLAB:griddata:DuplicateDataPoints; 
		[xi,yi] = meshgrid(x_out, y_out);
		zi = griddata(x, y, z, xi, yi);
        
        
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
        plot(newr-newr(end), z, '.');
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

