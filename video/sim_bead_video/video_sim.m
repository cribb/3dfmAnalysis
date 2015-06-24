function [] = video_sim(in_struct)
%Will create frames in the current directory, must create directory before
%using function
%Uses 8-bit integers

%Verify that all parameters have been specified, give default value to any
%that have not been chosen

video_tracking_constants;


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
    signal       = in_struct.signal;         % [max intensity of signal]
    background   = in_struct.background;     % [max intensity value]
    SNR          = in_struct.SNR;
    seed         = in_struct.seed;           %  #ok<NASGU>
    viscosity    = in_struct.viscosity;      % [Pa s]
    tempK        = in_struct.tempK;          % [K]
    xdrift_vel   = in_struct.xdrift_vel;     % [m/frame]
    ydrift_vel   = in_struct.ydrift_vel;     % [m/frame]
    rad_confined = in_struct.rad_confined;   % [m]
    alpha        = in_struct.alpha;          % slope of loglog(MSD) plot
    modulus      = in_struct.modulus;        % [Pa]



svde_struct.seed         = seed;
svde_struct.numpaths     = numpaths;
svde_struct.viscosity    = viscosity;
svde_struct.bead_radius  = bead_radius;
svde_struct.frame_rate   = frame_rate;
svde_struct.duration     = duration;
svde_struct.tempK        = tempK;
svde_struct.field_width  = field_width;
svde_struct.field_height = field_height;
svde_struct.calim_um     = calib_um;
svde_struct.xdrift_vel   = xdrift_vel;
svde_struct.ydrift_vel   = ydrift_vel;
svde_struct.rad_confined = rad_confined;
svde_struct.alpha        = alpha;
svde_struct.modulus      = modulus;


%Simulate the trajectories
traj = sim_video_diff_expt('expected',svde_struct); 
%named the vrpn file 'expected' for now, is this necessary to save in the future?
xtraj = traj(:,X);
ytraj = traj(:,Y);


%Determine the number of frames in the video
numframes = frame_rate*duration;
logentry(['number of frames: ' num2str(numframes)]);
%Another way to do this: numframes = length(xtraj)/numpaths;


%Calculate st dev of gaussians from bead radius
bead_r_m = bead_radius;
bead_r_um = bead_r_m*1000000;
bead_pix_r = bead_r_um/calib_um;
logentry(['bead radius is ' num2str(bead_pix_r) ' pixels']);

%Calculate noise (standard deviation of background) from SNR and signal
noise = (signal - background)/SNR;


%Calculate scalar for gaussian function
a = signal/255;


%Check to make sure that there will not be bleaching
total_I = signal+background+(2*noise);
if total_I >= 255
    error('Photobleaching will occur, cannot simulate video.');
end


%may be a better way to do this part - instead of 2 for loops make the 
%'center' input to new_guass a vector instead of a point
frames = 0;
blank = zeros((field_height*scale),(field_width*scale));
for i = 1:numframes
    %Create a blank frame to start with (rows, columns)
    paths = blank;
    
    %Simulate each spot in the frame
    for spot = 1:numframes:(length(xtraj)-1);
        paths = paths + gauss2d(blank,bead_pix_r,[xtraj(frames+spot),ytraj(frames+spot)],a);
    end
    
    frame = uint8(255.*paths);
    
    %Downsample the frame to the correct size
    frame = image_downsample(frame,scale);
    
    %Generate noise on the frame
    rand_noise = uint8(background + noise .* randn(field_height,field_width));
    frame = frame + rand_noise;
    
    %Add background
    
    %Save the frame 
    filename = ['frame_' sprintf('%04d',i-1) '.tif'];
    imwrite(frame, filename, 'Tiff');
    frames = frames+1;
    logentry(['created frame ' sprintf('%04d',i-1)]);
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
    
    if ~isfield(in, 'signal') || isempty(in.signal)
        in.signal = 200;   % [max intensity of signal]
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