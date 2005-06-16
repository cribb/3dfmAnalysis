function [x_out,y_out,F] = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um)
% run a sample velocity profile using data from EVT_GUI

    % turn off the divide by zero warning because there's a divide by zero
    % in the determination of the derivative
	warning off MATLAB:divideByZero;
    
    fp = dir(files);
    
    % derivative window size
    window_size = 12;
    
    % for every file, get its filename and reduce the dataset to a single table.
    for k = 1:length(fp)
        newd = load_video_tracking(fp(k).name,[],'pixels',calib_um,'absolute','yes','table');
        
        % we don't want to repeat any beadIDs as we concatenate the
        % datasets from each filename in the stack.  To avoid this, we add
        % the max(beadID) to the newdata's beadID and then we concatenate.
        if exist('d')
            beadmax = max(newd(:,3));
            newd(:,3) = newd(:,3) + beadmax;            
            d = [d ; newd];   
        else
            d = newd;
        end
    end
    
    % prefit the output data table with two additional columns of zeros, to
    % fill in later.
	d = [d zeros(length(d), 2)];
	
	beadID = d(:,2);
	
    % for each beadID, compute it's velocity and concatenate it to the
    % current data table as new columns [olddata vel_magnitude vel_angle].
	for k = 0 : max(beadID)
        idx = find(beadID == k);
        temp = d(idx,:);
        
        if(length(idx)>window_size) % avoid any gaps in beadID numbers
%             vel = compute_velocity(temp(:,1), temp(:,4), temp(:,5), window_size);
		
            [dxydt, newt, newxy] = windiff(temp(:,4:5),temp(:,1),window_size);
		
            vel = dxydt;
            
            velmag = magnitude(vel);
            velang = angle(vel); 
            
            force = 6*pi*viscosity*bead_radius*velmag*calib_um*1e-6;

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
        axis([0 649 0 484]);
		xlabel('x [pixels]'); ylabel('y [pixels]'); set(gca, 'YDir', 'reverse');
        
        newr = magnitude((x-poleloc(1)),(y-poleloc(2)));
        subplot(1,2,2);
        plot(newr-newr(end), z, '.');
        grid on;
		xlabel('r'); ylabel('force (pN)');

%         subplot(2,2,3);
        figure;
		plot3(finalxy(:,1), finalxy(:,2), finalF, '.');
        colormap(hot);
		zlabel('force (pN)');
        
        figure; 
%         subplot(2,2,4);
		imagesc(x_out,y_out,zi);
		colormap(hot);
		colorbar; 
        
    % provide force as output table
	F = zi;

%==============================================
% function v = compute_velocity(t, x, y, window_size)
% 
%     coords = [x y];
%     
%     [dxy, newt, newxy] = windiff(coords,t,window_size);
% 
%     vel = dxy./repmat(dt,1,2);
%     
%     velmag = sqrt(vel(:,1).^2 + vel(:,2).^2);
%     velang = atan2(vel(:,2), vel(:,1)); 
%     
%     v(:,1) = velmag;
%     v(:,2) = velang;

    
