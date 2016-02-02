function [] = video_sim(in_struct,grid)
%VIDEO_SIM creates a simulated video of fluorescent beads moving
%through a Newtonian fluid
%
%3DFM function
%video/sim_bead_video
%last modified 8.5.2015 (ptlee)
%
%This function will simulate videos of fluorescent beads moving through a
%Newtonian fluid as several tiff image frames. 
%
%Video_sim will not create a directory for the frames - it will save them
%in the current directory. 
%
%The resulting frames will be created as matrices of 8-bit integers and saved as tiff images.
%
%
%
%Takes a structure that specifies the parameters for the simulation as an input.
%Its fields include:
%       in_struct.numpaths = number of bead paths.  Default: 10.
%       in_struct.bead_radius = bead radius in [m].  Default: 0.5e-6.
%       in_struct.frame_rate = frame rate of camera in [fps].  Default: 30.
%       in_struct.duration = duration of video in [s].  Default: 60.
%       in_struct.field_width = width of video frame in [px].  Default: 648.
%       in_struct.field_height = height of video frame in [px].  Default: 484.
%       in_struct.calib_um = conversion unit in [microns/pixel].  Default: 0.152.
%       in_struct.scale = scaling factor for the field height and width.  Default: 1.
%       in_struct.intensity = maximum intensity for the final image.  Default: 250.
%               Maximum intensity cannot be greater than 255 (frames are
%               created as matrices of 8-bit integers).
%       in_struct.background = mean intensity value, image matrix, or image
%               filename to be used as a background for the video.  Default: mean
%               intensity of 10.
%       in_struct.SNR = signal-to-noise ratio for the video.  Default: 10. 
%       in_struct.seed = seed value to give to random number generator.
%               If this value is absent, the generator uses the 
%               system time as the seed.
%       in_struct.viscosity = solution viscosity in [Pa s].  Default: 0.023 (2 M sucrose).
%       in_struct.tempK = temperature of fluid in [K].  Default: 300.
%       in_struct.xdrift_vel = x-drift in [meters/frame].  Default: 0.
%       in_struct.ydrift_vel = y-drift in [meters/frame].  Default: 0.
%       in_struct.rad_confined = the particle's radius of confinement in [m]. Default: Inf.
%       in_struct.alpha = anomalous diffusion constant. Default: 1.
%       in_struct.modulus = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
% Second input "grid" is a 'y'/'n' input. The simulated video can contain
% stationary particles organized into a grid ('y') or random diffusing
% particles ('n'). The stationary grid videos cannot contain a prime number
% of particles.


video_tracking_constants;

%Verify that all parameters have been specified, give default value to any
%that have not been chosen
in_struct = param_check(in_struct);
logentry('All parameters set');
    numpaths     = in_struct.numpaths;
    bead_radius  = in_struct.bead_radius;    % [m]
    frame_rate   = in_struct.frame_rate;     % [frames/sec]
    duration     = in_struct.duration;       % [sec]
    field_width  = in_struct.field_width;    % [pixels]
    field_height = in_struct.field_height;   % [pixels]
    calib_um     = in_struct.calib_um;       % [um/pixel]
    scale        = in_struct.scale;          % [scaling factor]
    intensity    = in_struct.intensity;      % [max intensity of image]
    background   = in_struct.background;     % [mean intensity, image matrix, or filename]
    SNR          = in_struct.SNR;
    seed         = in_struct.seed;           %  #ok<NASGU>
    viscosity    = in_struct.viscosity;      % [Pa s]
    tempK        = in_struct.tempK;          % [K]
    xdrift_vel   = in_struct.xdrift_vel;     % [m/frame]
    ydrift_vel   = in_struct.ydrift_vel;     % [m/frame]
    rad_confined = in_struct.rad_confined;   % [m]
    alpha        = in_struct.alpha;          % slope of loglog(MSD) plot
    modulus      = in_struct.modulus;        % [Pa]


    calib_um_scaled = calib_um/scale;
    

    svde_struct.seed         = seed;
    svde_struct.numpaths     = numpaths;
    svde_struct.viscosity    = viscosity;
    svde_struct.bead_radius  = bead_radius;
    svde_struct.frame_rate   = frame_rate;
    svde_struct.duration     = duration;
    svde_struct.tempK        = tempK;
    svde_struct.field_width  = scale*field_width;
    svde_struct.field_height = scale*field_height;
    svde_struct.calib_um     = calib_um_scaled;
    svde_struct.xdrift_vel   = xdrift_vel;
    svde_struct.ydrift_vel   = ydrift_vel;
    svde_struct.rad_confined = rad_confined;
    svde_struct.alpha        = alpha;
    svde_struct.modulus      = modulus;

    
%Based on what type of input background is this function will create a
%matrix for the background, determine how much noise is necessary for the
%parameters, and determine how much more noise needs to be added
%[background_mat,bg_mean,noise,need_noise] = create_background(background,intensity,SNR,field_height,field_width);
[background_mat,bg_mean,noise,add_noise] = create_background(background,intensity,SNR,field_height,field_width);

    
%Simulate the trajectories
traj = sim_video_diff_expt([],svde_struct,grid);


xtraj = traj(:,X);
ytraj = traj(:,Y);

xtraj_corrected = xtraj/scale;
ytraj_corrected = ytraj/scale;

traj_to_save = traj;
traj_to_save(:,X) = xtraj_corrected;
traj_to_save(:,Y) = ytraj_corrected;

[~,folder] = fileparts(pwd);
vrpnfilename = [folder '_expected'];
save_vrpnmatfile(vrpnfilename,traj_to_save,'pixels',calib_um);

%Determine the number of frames in the video
numframes = frame_rate*duration;
logentry(['Number of frames: ' num2str(numframes)]);
%Another way to do this: numframes = length(xtraj)/numpaths;


bead_r_m = bead_radius;
bead_r_um = bead_r_m*1000000;
bead_r_nm = bead_r_um*1000;
% bead_pix_r = bead_r_um/calib_um_scaled;
logentry(['Bead diameter is ' num2str(bead_r_nm*2) ' nm']);


%Calculate st dev of gaussians from bead radius
[stdev_gaussian] = lookup_radius(bead_radius,calib_um);

%Calculate scalar for gaussian function
signal = intensity-bg_mean-(noise);
a = signal/255;


%Check to make sure that there will not be bleaching
overall_I = bg_mean + signal + (noise);
if overall_I >= 255
    error('Photobleaching will occur at this level of intensity--cannot simulate video.');
end


%may be a better way to do this part - instead of 2 for loops make the 
%'center' input to new_guass a vector instead of a point
frames = 0; 
blank = zeros((field_height*scale),(field_width*scale));
for i = 1:numframes
    %Create a blank frame to start with (rows, columns)
    paths = blank;
    
    %Simulate each spot in the frame
    for spot = 1:numframes:(length(xtraj)-0); %changed from -1 to -0 for bg frame gaussian
        paths = paths + gauss2d(blank,((scale^2)*stdev_gaussian),[xtraj(frames+spot),ytraj(frames+spot)],a);
    end
    
    frame = 255.*paths;
    frame = uint8(frame);
    
    %Downsample the frame to the correct size
    if scale ~= 1
        frame = imresize(frame,(1/scale));
    end
    
    %Generate noise on the frame and add a background
    noisy_bg = uint8(add_noise .* randn(field_height,field_width));% + bg_mean);
    %balance_bg = uint8(repmat(extra_bg,field_height,field_width));
    frame = frame + noisy_bg + background_mat; % - balance_bg;
    
    %Save the frame 
    filename = ['frame_' sprintf('%04d',i-1) '.tif'];
    imwrite(frame, filename, 'Tiff');
    frames = frames+1;
    logentry(['Created frame ' sprintf('%04d',i-1)]);
end

logentry('Created final frames');
end


function out = param_check(in)

    if ~isfield(in, 'numpaths') || isempty(in.numpaths)
        in.numpaths = 10;
    end
    
    if ~isfield(in, 'bead_radius') || isempty(in.bead_radius)
        in.bead_radius = 0.5e-6;  % [m]
    end
    
    if ~isfield(in, 'frame_rate') || isempty(in.frame_rate)
        in.frame_rate = 30;       % [frames/sec]
    end

    if ~isfield(in, 'duration') || isempty(in.duration)
        in.duration = 60;        % [sec]
    end
    
    if ~isfield(in, 'field_width') || isempty(in.field_width)
        in.field_width = 648;     % [pixels]
    end

    if ~isfield(in, 'field_height') || isempty(in.field_height)
        in.field_height = 484;    % [pixels]
    end
    
    if ~isfield(in, 'calib_um') || isempty(in.calib_um)
        in.calib_um = 0.152;      % [um/pixel]
    end
    
    if ~isfield(in, 'scale') || isempty(in.scale)
        in.scale = 1;   % [scaling factor]
    end
    
    if ~isfield(in, 'intensity') || isempty(in.intensity)
        in.intensity = 250;   % [max intensity of signal]
    end
    
    if ~isfield(in, 'background') || isempty(in.background)
        in.background = 10;   % [average intensity value]
    end
    
    if ~isfield(in, 'SNR') || isempty(in.SNR)
        in.SNR = 10;
    end    
    
    if ~isfield(in, 'seed') || isempty(in.seed)
        in.seed = sum(100000*clock);
    end
    
    if ~isfield(in, 'viscosity') || isempty(in.viscosity)
        in.viscosity = 0.023;     % [Pa s]
    end

    if ~isfield(in, 'tempK') || isempty(in.tempK)
        in.tempK = 300;        % [K]
    end

    if ~isfield(in, 'xdrift_vel') || isempty(in.xdrift_vel)
        in.xdrift_vel = 0;   % [m/frame]
    end

    if ~isfield(in, 'ydrift_vel') || isempty(in.ydrift_vel)
        in.ydrift_vel = 0;   % [m/frame]
    end
    
    if ~isfield(in, 'rad_confined') || isempty(in.rad_confined)
        in.rad_confined = Inf;   % [m]
    end
    
    if ~isfield(in, 'alpha') || isempty(in.alpha)
        in.alpha = 1;   % [unitless]
    end

    if ~isfield(in, 'modulus') || isempty(in.modulus)
        in.modulus = 0;   % [Pa]
    end
    
    out = in;
    
return;
end


function [background_mat,bg_mean,noise,add_noise] = create_background(background,intensity,SNR,field_height,field_width)

if (isnumeric(background) && (length(background) <=1 || length(background) <=3)) == 1
    bg_mean = background;
    logentry(['Mean background intensity = ' num2str(bg_mean) '. Background is a matrix of ' num2str(bg_mean) 's.']);
    noise = (intensity-bg_mean)/SNR;
    add_noise = noise;
    %extra_bg = 0;
    background_mat = uint8(zeros(field_height,field_width));
    
elseif (isnumeric(background) && length(background) > 3) == 1;
    logentry('Background is an image matrix.');
    background_mat = double(background);
    bg_dim = size(background_mat);
    if bg_dim(1) ~= field_height || bg_dim(2) ~= field_width
        error('Background size does not match frame size.');
    end
    bg_mean = mean(background_mat(:));
    logentry(['Mean background intensity = ' num2str(bg_mean) '.']);
    existingnoise = std(background_mat(:));
    noise = (intensity-bg_mean)/SNR;
    %extra_bg = bg_mean;
    background_mat = uint8(background_mat);
%     if existingnoise > noise
%         error('Too much noise in the background for this SNR.');
%     else add_noise = noise - existingnoise;
%     end
    add_noise = noise;
    imwrite(background_mat,'background.tif','tiff');
    
elseif ischar(background) == 1 ;
    if exist(background, 'file') ~= 2
        error('Background image file does not exist. Please add file to Matlab path.');
    end
    logentry('Background is an image file.');
    background_mat = double(imread(background));
    bg_dim = size(background_mat);
    if bg_dim(1) ~= field_height || bg_dim(2) ~= field_width
        error('Background size does not match frame size.');
    end
    bg_mean = mean(background_mat(:));
    logentry(['Mean background intensity = ' num2str(bg_mean) '.']);
    existingnoise = std(background_mat(:));
    noise = (intensity-bg_mean)/SNR;
    %extra_bg = bg_mean;
    background_mat = uint8(background_mat);
%     if existingnoise > noise
%         error('Too much noise in the background for this SNR.');
%     else add_noise = noise - existingnoise;
%     end
    add_noise = noise;
    imwrite(background_mat,'background.tif','tiff');
end
% imwrite(background_mat,'background.tif','tiff');
end