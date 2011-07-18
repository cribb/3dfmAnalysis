function varargout = sim_video_diff_expt(filename, in_struct)

video_tracking_constants; 

if nargin < 2 || isempty(in_struct)
    logentry('Model parameters are not set.  Will create the default simulation.');
    in_struct = [];
end

if ~exist('filename', 'var') || isempty(filename)
    logentry('Not saving data to file.');
end

in_struct = param_check(in_struct);

    seed         = in_struct.seed;
    numpaths     = in_struct.numpaths;
    viscosity    = in_struct.viscosity;      % [Pa s]
    bead_radius  = in_struct.bead_radius;    % [m]
    frame_rate   = in_struct.frame_rate;     % [frames/sec]
    duration     = in_struct.duration;       % [sec]
    tempK        = in_struct.tempK;          % [K]
    field_width  = in_struct.field_width;    % [pixels]
    field_height = in_struct.field_height;   % [pixels]
    calib_um     = in_struct.calib_um;       % [um/pixel]
    xdrift_vel   = in_struct.xdrift_vel;     % [m/frame]
    ydrift_vel   = in_struct.ydrift_vel;     % [m/frame]

    
% simulation test
simout = [];


    
    % time vector
    t = (1/frame_rate) * [1:(frame_rate*duration)]' - (1/frame_rate); 
    
    % vector of frame ID's
    fr = [1:(frame_rate*duration)]';
    
    % xy tracker locations with zero offset
    xy = sim_newt_fluid(viscosity, bead_radius, frame_rate, duration, tempK, 2, numpaths);
    
    % create random starting locations (offsets) within the prescribed field
    position_offsets = repmat(rand(1,2,numpaths), [frame_rate*duration,1,1]).* ...
                       repmat([field_width field_height],[frame_rate*duration,1,numpaths]) .* ...
                       (calib_um / 1e6);

    % apply the random starting location 
    xy = xy + position_offsets;
    
    % drift vector for independent drift velocities in x and y
    accumulated_drift = cumsum( repmat([xdrift_vel ydrift_vel], ...
                                       [frame_rate*duration, 1, ...
                                       numpaths] ) );
    % apply the drift 
    xy = xy + accumulated_drift;
    
    % extraneous columns in the vrpn.mat format
    zrpy = zeros(frame_rate*duration,4);

for k = 1:numpaths;     
    % vector of tracker ID's
    id = ones(frame_rate*duration,1)*k; 
    

    % add this tracker's data to the output table
    simout = [simout; t, id,  fr,  xy(:,:,k), zrpy];
end;

% convert physical locations to pixel locations to simulate expt
simout(:,X:Y) = simout(:,X:Y) / (calib_um/1e6);  % puts into pixels

% Clip data to "camera" field
% idx = find( simout(:,X) >=            0  & ...
%             simout(:,X) <=  field_width  & ...
%             simout(:,Y) >=            0  & ...
%             simout(:,Y) <= field_height  );
% simout = simout(idx,:);

if exist('filename', 'var') && ~isempty(filename)
    save_evtfile(filename, simout, 'pixels', 1);
%     csvwrite([filename '.csv'], simout);
    logentry(['Saved data to file: ' filename]);
end

switch nargout
    case 1
        varargout{1} = simout;
    case 2
        varargout{1} = simout;
        varargout{2} = in_struct;            
end;

return;


function out = param_check(in)

    if ~isfield(in, 'seed') || isempty(in.seed)
        in.seed = sum(100000*clock);
    end
    
    if ~isfield(in, 'numpaths') || isempty(in.numpaths)
        in.numpaths = 10;
    end
    
    if ~isfield(in, 'viscosity') || isempty(in.viscosity)
        in.viscosity = 0.01;     % [Pa s]
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
        in.calib_um = 0.179;      % [um/pixel]
    end

    if ~isfield(in, 'xdrift_vel') || isempty(in.xdrift_vel)
        in.xdrift_vel = 0;   % [m/frame]
    end

    if ~isfield(in, 'ydrift_vel') || isempty(in.ydrift_vel)
        in.ydrift_vel = 0;   % [m/frame]
    end

    out = in;
    
return;

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'sim_video_diff_expt: '];
     
     fprintf('%s%s\n', headertext, txt);
