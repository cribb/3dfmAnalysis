function [x_out,y_out,F] = fcd_forcecal2d(files, viscosity, bead_radius, poleloc, calib_um)
% run a sample velocity profile using data from FCD_GUI

    % turn off the divide by zero warning because there's a divide by zero
    % in the determination of the derivative
	warning off MATLAB:divideByZero;
    
    fp = dir(files);
    
    % for every file, get its filename and reduce the dataset to a single
    % table.
    for k = 1:length(fp)
        newd = load(fp(k).name);
		newd = newd.tracking;
        
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
	
	beadID = d(:,3);
	
    % for each beadID, compute it's velocity and concatenate it to the
    % current data table as new columns [olddata vel_magnitude vel_angle].
	for k = 0 : max(beadID)
        idx = find(beadID == k);
        temp = d(idx,:);
        
        vel = compute_velocity(temp(:,7), temp(:,4), temp(:,5));
        force = 6*pi*viscosity*bead_radius*vel(:,1)*calib_um*1e-6;

        if(length(idx)>0) % avoid any gaps in beadID numbers
            d(idx, 8:9) = [force vel(:,1)];
        end
	end
	
        % do some plotting
        x = (d(:,4) - poleloc(1)) * calib_um;
		y = (d(:,5) - poleloc(2)) * calib_um;
		z = d(:,8)*1e12;
        x_out = min(x):range(x)/100:max(x);
        y_out = min(y):range(y)/75:max(y);
        
        warning off MATLAB:griddata:DuplicateDataPoints; 
		[xi,yi] = meshgrid(x_out, y_out);
		zi = griddata(x, y, z, xi, yi);
        
        figure;
        plot(d(:,9),'.');
        
		figure;
        subplot(2,2,1);
		plot(x,y,'.');
		xlabel('x'); ylabel('y');

        subplot(2,2,2);
        plot3(x, y, z, '.');
        grid on;
		xlabel('x'); ylabel('y');
		zlabel('force (pN)');

        subplot(2,2,3);
        surf(zi);
        colormap(hot);
		zlabel('force (pN)');

        subplot(2,2,4);
		imagesc(zi);
		colormap(hot);
		colorbar;
        
    % provide force as output table
	F = zi;

%==============================================
function v = compute_velocity(t, x, y)

    coords = [x y];
   
    window_size = 5;
    
    dxy = [zeros(window_size,2) ; mydiff(coords,window_size)];
    dt = [zeros(window_size,1) ; mydiff(t, window_size)];
        
    vel = dxy./repmat(dt,1,2);
    
    velmag = sqrt(vel(:,1).^2 + vel(:,2).^2);
    velang = atan2(vel(:,2), vel(:,1)); 
    
    v(:,1) = velmag;
    v(:,2) = velang;

    
%==============================================
function v = mydiff(x, window_size)
    
	A = x(1:end-window_size,:);
	B = x(window_size+1:end,:);
	
	v = B-A;


