function v = sim_newt_fluid_evt(outfile, sampling_rate, duration, ...
                                numpaths, viscosity, bead_radius, ...
                                calibum, temp)
%  SIM_NEWT_FLUID_EVT Generates simulation of 2D Newtonian fluid in evt format
% 
%  3DFM function
%  Rheology/modeling
%  last modified 2009.06.03 (jcribb)
% 
%  Using a random walk, SIM_NEWT_FLUID_EVT uses SIM_NEWT_FLUID to simulate
%  a defined number of paths (numpaths).  The use defines the sampling rate
% (sampling_rate)
%  
%  v = sim_newt_fluid_evt(outfile, sampling_rate, duration, numpaths, ...
%                         viscosity, bead_radius, calibum, temp)
%  
  
    video_tracking_constants;

    if nargin < 8 || isempty(temp)
        temp = 298;
    end

    if nargin < 7 || isempty(calibum)
        calibum = 0.152;
    end

    if nargin < 6 || isempty(bead_radius)
        bead_radius = 0.5e-6;
    end

    if nargin < 5 || isempty(viscosity)
        viscosity = 1e-3;
    end

    if nargin < 4 || isempty(numpaths)
        numpaths = 50;
    end

    if nargin < 3 || isempty(duration)
        duration = 60;
    end

    if nargin < 2 || isempty(sampling_rate)
        sampling_rate = 120;   
    end


    if nargin < 1 
        logentry('Unrecoverable error, No output file specified. Exiting now.');
        return;
    elseif isempty(outfile)
        logentry(['No output file was generated because of empty filename.'] ...
                 ['  Instead, output will only go to base workspace.']);
    end

    id = [0 : numpaths-1]';
    t = [0 : 1/sampling_rate : (duration-1/sampling_rate)];
    frame = [0 : length(t)-1];
    
    dim = 2;
    xy = sim_newt_fluid(viscosity, bead_radius, sampling_rate, duration, temp, dim, numpaths);
    
    xy = xy * 1e6 / calibum; % Convert to pixels because sim_newt_fluid outputs in meters.

    numTableRows = numpaths*duration*sampling_rate;

    tmp_t  = repmat(t,numpaths,1);
    tmp_f  = repmat(frame, numpaths,1); 
    tmp_id = repmat(id, duration*sampling_rate, 1);

    tmp_x  = squeeze(xy(:,1,:))';
    tmp_y  = squeeze(xy(:,2,:))';

    table          = zeros(numTableRows, 9);
    table(:,TIME)  = tmp_t(:);
    table(:,FRAME) = tmp_f(:);
    table(:,ID)    = tmp_id(:);
    table(:,X)     = tmp_x(:);
    table(:,Y)     = tmp_y(:);

    tracking.spot3DSecUsecIndexFramenumXYZRPY = table;
    save(outfile, 'tracking');

    v = table;

return;

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'sim_newt_fluid_evt: '];
     
     fprintf('%s%s\n', headertext, txt);
