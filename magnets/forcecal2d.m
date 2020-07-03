function v = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um, granularity, window_size, interp)
% 3DFM function  
% Magnetics
% last modified 08/07/06 (jcribb)
%  
% Run a 2D force calibration using data from EVT_GUI.
%  
%  v = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um, granularity, window_size, interp)
%   
%  where "files" is a string containing the file name(s) for analysis
%          (wildcards ok) OR a previously loaded and defined video tracking
%          structure/variable/dataset.
%        "viscosity" is the calibration fluid viscosity in [Pa s]
%        "bead_radius" is the radius of the probe particles in [m]
%        "poleloc" is the pole location, i.e. [pole_x, pole_y] in [pixels]
%        "calib_um" is the microns per pixel calibration factor.
%        "granularity" is the binning for 2D force determination
%        "window_size" is an integer describing the derivative's time-step, tau
%        "interp" is 'on' or 'off', and performs 2d interpolation between spatial datapoints.
%
% The output structure, v, contains the following fields:
%        "force_map" is the average force computed for each pixel.
%        "error_map" are the xpositions in the Ftable
%        "x_bins" are the x-positions in the force_map & error_map
%        "y_bins" are the ypositions in the force_map & error_map 
%        "step" is the stepsize for each pixel.  Each pixel is assumed square.
%        "poleloc" is the pole location in [meters]
%

    % handle the argument list
    if ( nargin < 8 | isempty(interp) );
        logentry('Interpolation choice not defined.  Assuming no interpolation between spatial values is desired.');
        interp = 'off';
    end
        
    if ( nargin < 7 | isempty(window_size) );
        logentry('No window size defined.  Setting default window_size of 1');
        window_size = 1;   
    end;
    
    if ( nargin < 6 | isempty(granularity) ); 
        logentry('No granularity defined.  Setting granularity to 16 pixels.');
        granularity = 16;  
    end;  
        
    if exist('files') & ischar(files)
        % for every file, get its filename and reduce the dataset to a single table.
        d = load_video_tracking(files,[],'m',calib_um,'absolute','yes','matrix');
    else
        % This could be bad.  There is no check for what data are contained
        % in 'files.'  Weird errors may happen if the correct data
        % structure (i.e. the video tracking table structure) is not used.
        d = files;
    end
    
    % handle the constants used in the computations.  
    video_tracking_constants;
    
    % image size in pixels
    width = 648;
    height = 484;	

    % We would like to start with everything in SI units to keep scaling 
    % errors at a minimum 
    
    % pole location given in pixels, converted to meters
    poleloc = poleloc * calib_um * 1e-6;

    % x and y bins converted to meters
    x_bins(:,1) = [1 : granularity : width]' * calib_um * 1e-6;
    y_bins(:,1) = [1 : granularity : height]' * calib_um * 1e-6;
    
    %% Computation of Forces %%
    
    % for each beadID, compute its velocity:magnitude and force:magnitude.
    trackerlist = unique(d(:,ID));
	for k = 1 : length(trackerlist)

        temp = get_bead(d, trackerlist(k));

        % NOTE: Can edit out calculation of "Force", as it's depricated by
        % component calculations
        [newxypos,force,fxy] = forces2d(temp(:,TIME), temp(:,X:Y), viscosity, bead_radius, window_size);
            
        % setup the output variables
        if ~exist('finalxypos');  
            finalxypos = newxypos;
        else
            finalxypos = [finalxypos ; newxypos];
        end

% Depricated by indep x and y calculations
%         if ~exist('finalF');
%             finalF = force;
%         else
%             finalF = [finalF ; force];
%         end
        
        if ~exist('finalFx');
            finalFx = fxy(:,1);
        else
            finalFx = [finalFx ; fxy(:,1)];            
        end                
        
        if ~exist('finalFy');
            finalFy = fxy(:,2);
        else
            finalFy = [finalFy ; fxy(:,2)];            
        end                
    end
    
    %% Procedure for Binning of forces %%
% Depricated by following two lines    [force_map, error_map]  = bin2d( finalxypos(:,1), finalxypos(:,2), finalF, x_bins, y_bins);
    [Fx_map, xerror_map]    = bin2d( finalxypos(:,1), finalxypos(:,2), finalFx, x_bins, y_bins);
    [Fy_map, yerror_map]    = bin2d( finalxypos(:,1), finalxypos(:,2), finalFy, x_bins, y_bins);
    force_map = sqrt(Fx_map.^2 + Fy_map.^2);
    error_map = sqrt(xerror_map.^2 + yerror_map.^2);
    
    
    % output variables in SI units
    step     = granularity * calib_um * 1e-6;

    if strcmp(interp, 'on')
        v.force_map_interp = interp_forces2d(x_bins, y_bins, force_map);
        v.Fx_map_interp    = interp_forces2d(x_bins, y_bins, Fx_map);
        v.Fy_map_interp    = interp_forces2d(x_bins, y_bins, Fy_map);
    end

    x_bins = x_bins - poleloc(1);
    y_bins = y_bins - poleloc(2);
    
    % output variables to structure, v
    v.force_map  = force_map;
    v.Fx_map     = Fx_map;
    v.Fy_map     = Fy_map;
    v.error_map  = error_map;
    v.x_bins     = x_bins;
    v.y_bins     = y_bins;
    v.step       = step;
    v.poleloc    = poleloc;
    v.forces_xy  = fxy; 
    
%% PLOTTING CODE %%
plot_forcecal2d(x_bins, y_bins, force_map, error_map, 'fe');

if strcmp(interp, 'on')
    plot_forcecal2d(x_bins, y_bins, v.force_map_interp, [], 'sf');
end

%%%%
%% extraneous functions
%%%%


%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'forcecal2d: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return    

    
