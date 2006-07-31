function v = forcecal2d(files, viscosity, bead_radius, poleloc, calib_um, granularity, window_size, interp)
% 3DFM function  
% Magnetics
% last modified 07/31/06 (jcribb)
%  
% Run a 2D force calibration using data from EVT_GUI.
%  
%  [Ftable, errtable, step] =  forcecal2d(files, viscosity, bead_radius, ...
%                                         poleloc, calib_um, granularity, window_size); 
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
        d = load_video_tracking(files,[],'m',calib_um,'absolute','yes','table');
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

    x_bins(:,1) = [1 : granularity : width]' * calib_um * 1e-6;
    y_bins(:,1) = [1 : granularity : height]' * calib_um * 1e-6;

    x_bins = x_bins - poleloc(1);
    y_bins = y_bins - poleloc(2);
    
    %% Computation of Forces %%
    
    % for each beadID, compute its velocity:magnitude and force:magnitude.
	for k = 0 : get_beadmax(d)

        temp = get_bead(d, k);
        
        [newxy,force] = forces2d(temp(:,TIME), temp(:,X:Y), viscosity, bead_radius, window_size);
            
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
    
    %% Procedure for Binning of forces %%
    [force_map, error_map] = bin2d( finalxy(:,1), finalxy(:,2), finalF, x_bins, y_bins);
    
    % output variables in SI units
    step     = granularity * calib_um * 1e-6;

    if strcmp(interp, 'on')
        v.force_map_interp = interp_forces2d(x_bins, y_bins, force_map);
    end

    % output variables to structure, v
    v.force_map = force_map;
    v.error_map = error_map;
    v.x_bins = x_bins;
    v.y_bins = y_bins;
    v.step = step;
    v.poleloc = poleloc;
    
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

    
