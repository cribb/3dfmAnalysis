function [] = video_sim(folder,in_struct,mean,variance,scale_c,scale_r)

in_struct = param_check(in_struct);

spot_sim(folder,in_struct);

numframes = in_struct.frame_rate*in_struct.duration;

%Downsample
for m = 1:numframes
    filename = ['frame_' sprintf('%04d',m-1) '.tif'];
    image_downsample(filename,scale_c,scale_r);
end

%Need to add backgrounds

generate_noise_tif('frame_',in_struct,mean,variance);

logentry('created final frames');
end


function out = param_check(in)

    if ~isfield(in, 'seed') || isempty(in.seed)
        in.seed = sum(100000*clock);
    end
    
    if ~isfield(in, 'numpaths') || isempty(in.numpaths)
        in.numpaths = 10;
    end
    
    if ~isfield(in, 'viscosity') || isempty(in.viscosity)
        in.viscosity = 0.023;     % [Pa s]
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
    
    if ~isfield(in, 'tempK') || isempty(in.tempK)
        in.tempK = 300;        % [K]
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