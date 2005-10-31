function [Ftable, xpos, ypos, errtable, step] = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um, granularity, window_size)
% 3DFM function  
% Magnetics
% last modified 08/16/05 (jcribb)
%  
% Run a 2D force calibration using data from EVT_GUI.
%  
%  [Ftable, errtable, step] =  forcecal2d(files, viscosity, bead_radius, ...
%                                         poleloc, calib_um, granularity, window_size); 
%   
%  where "Ftable" is the average force computed for each pixel.
%        "xpos" are the xpositions in the Ftable
%        "ypos" are the ypositions in the Ftable
%        "errtable" is the standard error (std(X)/sqrt(N)) for Ftable.
%        "step" is the stepsize for each pixel.  Each pixel is assumed square.
%        "F" is the output 2D force grid linearly interpolated by beads in "files"
%        "files" is a string containing the file name(s) for analysis (wildcards ok)
%        "viscosity" is the calibration fluid viscosity in [Pa s]
%        "bead_radius" is the radius of the probe particles in [m]
%        "poleloc" is the pole location, i.e. [pole_x, pole_y] in [pixels]
%        "calib_um" is the microns per pixel calibration factor.
%        "granularity" is the binning for 2D force determination
%        "window_size" is an integer describing the derivative's time-step, tau
%
%  01/??/05 - created; jcribb.  
%  06/16/05 - added documentation. cleaned up code. fixed bug in
%  force-distance 1D plot.
%  06/20/05 - commented out linear-interp code for 2D plot and added
%  2D binning force calibration.  This can take a LONG time to compute if
%  the granularity is set too low (<4)
%   

    if nargin < 7 | isempty(window_size)
        window_size = 1;
    end
    
    video_tracking_constants;
    
    % for every file, get its filename and reduce the dataset to a single table.
    d = load_video_tracking(files,[],'pixels',calib_um,'absolute','yes','table');
	
    % for each beadID, compute its velocity:magnitude and force:magnitude.
	for k = 0 : get_beadmax(d)

        temp = get_bead(d, k);

        if(length(temp)>window_size) % avoid taking the derivative for any track 
                                     % whose number of points is less than the 
                                     % window size of the derivative.

            [dxydt, newt, newxy] = windiff(temp(:,X:Y),temp(:,TIME),window_size);		
            vel = dxydt;            
            velmag = magnitude(vel);
            force = 6*pi*viscosity*bead_radius*velmag*calib_um*1e-6;
            
		end
            
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
    
    % output variables
    x = finalxy(:,1);
    y = finalxy(:,2);
    F = finalF;
    
    % set up for generic plotting
    warning off MATLAB:griddata:DuplicateDataPoints; 

    x_grid = 1:648; 
    y_grid = 1:484; 
    
    sfile = strrep(files, '.raw', '');
    sfile = strrep(sfile, '.vrpn', '');
    sfile = strrep(sfile, '.mat', '');
    sfile = strrep(sfile, '.evt', '');
    mipfile = [sfile, '.MIP.bmp'];
    
    try 
        myMIP = mip(mipfile);
    catch
        myMIP = 0;
    end
    
    % now, for the plots...
	figure;
    subplot(1,3,1);
    imagesc(x_grid * calib_um, y_grid * calib_um, myMIP); 
    colormap(copper(256));
    hold on;
		plot(x * calib_um,y * calib_um,'.');
    hold off;
    axis([0 648*calib_um 0 484*calib_um]);
	xlabel('x [\mum]'); ylabel('y [\mum]'); set(gca, 'YDir', 'reverse');
    
    newr = magnitude((x-poleloc(1)),(y-poleloc(2)));
    subplot(1,3,2);
    plot(newr, F*1e12, '.');
    grid on;
	xlabel('r'); ylabel('force (pN)');
    set(gcf, 'Position', [65 675 1354 420]);
    drawnow;

    subplot(1,3,3);
    loglog(newr, F*1e12, '.');
    grid on;
	xlabel('r'); ylabel('force (pN)');
%     set(gcf, 'Position', [65 675 1354 420]);
    drawnow;
    
    % now set up the binning process
    warning off MATLAB:divideByZero; % if there is no data in a bin, it's a divide by zero. we don't care about that.
    
	width = 648;
	height = 484;
	
% 	granularity = 4;
	
	col_bins = [1 : granularity : width];
	row_bins = [1 : granularity : height];
	
	for k = 1 : length(col_bins)-1
		for m = 1 : length(row_bins)-1
            idx = find( x >= col_bins(k) & x < col_bins(k+1) ...
                      & y >= row_bins(m) & y < row_bins(m+1));
            im_mean(m,k) = mean(F(idx));
            im_stderr(m,k) = std(F(idx))/sqrt(length(idx));        
        end
	end

    xpos = (col_bins(1:end-1) - poleloc(1)) * calib_um;
    xpos = xpos(:);
    ypos = (row_bins(1:end-1) - poleloc(2)) * calib_um;
    ypos = ypos(:);
        
    % plot the binning outputs 
	figure; 
	subplot(1,2,1);
	imagesc(xpos, ypos, im_mean * 1e12);
    title('Mean Calibrated Force (pN)');
	xlabel('\mum'); ylabel('\mum');
	colormap(hot);
	colorbar; 
	
	subplot(1,2,2);
	imagesc((col_bins - poleloc(1))* calib_um, (row_bins - poleloc(2)) * calib_um, im_stderr./im_mean);
    title('Standard Error / Mean');
	xlabel('\mum'); ylabel('\mum');
	colormap(hot);
	colorbar;     
    set(gcf, 'Position', [65 153 1353 420]);
    
    % to do the surface, we have to remap some matrices
    sx = repmat(xpos, 1, length(ypos))'; 
    sx = reshape(sx, length(xpos)*length(ypos), 1);
    sy = repmat(ypos, 1, length(xpos)); 
    sy = reshape(sy, length(xpos)*length(ypos), 1);    
    sF = reshape(im_mean, length(xpos)*length(ypos), 1);

    idx = isfinite(sF);
    sx = sx(idx);
    sy = sy(idx);
    sF = sF(idx);
    
	[xi,yi] = meshgrid(xpos, ypos);
	zi = griddata(sx, sy, sF * 1e12, xi, yi);
    
    figure;
	surf(xi, yi, zi);
	colormap(hot);
	zlabel('force (pN)');
	
	figure; 
	imagesc(xpos, ypos, zi);
	colormap(hot);
	colorbar;         

    % output variables
    Ftable   = im_mean * 1e12;
    errtable = im_stderr * 1e12;
    step     = calib_um * granularity;
    
