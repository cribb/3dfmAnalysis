function outs = pan_sim_newt_run(fileroot, wells, passes, simstruct)
% PAN_SIM_NEWT_RUN simulates a Panoptes run, creating a dataset for a Newtonian fluid.
%
% Panoptes function 
% 
% This function creates a dataset for a set of conditions defined for Panoptes, 
% our high-throughput microscope.
%
% function outs = pan_sim_newt_run(fileroot, wells, passes, simstruct)
%
% where "outs" is a dummy output set to zero
%       "fileroot" defines the location for tracking data and metadata files
%       "wells" defines the systed used, is either 'Monoptes' or 'Panoptes'
%       "passes" if 'y' matlab closes after finishing the analysis
%       "simstruct" is the input structure, with default settings as follows:
%                    simstruct.pass     = 1;
%                    simstruct.well     = [1:96];
%                    simstruct.numpaths = 10;
%                    simstruct.viscosity = 1;     % [Pa s]
%                    simstruct.bead_radius = 0.5e-6;        % [m]
%                    simstruct.frame_rate = 54;             % [frames/s]
%                    simstruct.duration = 60;               % [s]
%                    simstruct.tempK = 300;                 % [K]
%                    simstruct.field_width = 648;           % [pixels]
%                    simstruct.field_height = 488;          % [pixels]
%                    simstruct.calib_um = 0.171;            % [um/pixel];
%                    simstruct.xdrift_vel = 0;              % [m/frame];
%                    simstruct.ydrift_vel = 0;              % [m/frame];
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can be used manually from the matlab command line interface.
%

% sets the root filename in case one was not presented during the function call
if nargin < 1 || isempty(fileroot)
    fileroot = 'testfile';
end

% Default wells identified as wells 1 through 10
if nargin < 2 || isempty(wells)
    wells = [1:10]; %#ok<*NBRAK>
end

% assume one pass of the plate as the default
if nargin < 3 || isempty(passes)
    passes = 1;
else 
    passes = 1:passes;
end

% default values for the simulation structure
if nargin < 4 || isempty(simstruct)
    simstruct.numpaths = 10;
    simstruct.viscosity = 1;     % [Pa s]
    simstruct.bead_radius = 0.5e-6;        % [m]
    simstruct.frame_rate = 54;             % [frames/s]
    simstruct.duration = 60;               % [s]
    simstruct.tempK = 300;                 % [K]
    simstruct.field_width = 648;           % [pixels]
    simstruct.field_height = 488;          % [pixels]
    simstruct.calib_um = 0.171;            % [um/pixel];
    simstruct.xdrift_vel = 0;              % [m/frame];
    simstruct.ydrift_vel = 0;              % [m/frame];
end

simstruct = param_check(simstruct);
% 
% fn = fieldnames(simstruct);
% 
% % expand along the field that has our variable values
% for k = 1:length(fn)
%     sz(k,1) = length(getfield(simstruct,fn{k}));
% end
% 
% idx = find( sz(:,1) == max(sz(:,1)) );
% 
% for k = 1:length(fn)
%     
%     tmp = getfield(simstruct,fn{k});
%     
%     if k ~= idx  && size(tmp,1) == 1 && size(tmp,2) == 1
%         simstruct = setfield(simstruct,fn{k}, repmat(tmp, 1, sz(idx) ) );
%     end
%     
% end

for w = 1:length(wells)
    
    for p = 1:length(passes)
        
        filename = [fileroot '_video' '_pass' num2str(passes(p)) '_well' num2str(wells(w)) '_TRACKED.vrpn.mat'];
            
        mystruct.numpaths  = simstruct.numpaths;
        mystruct.viscosity = simstruct.viscosity;
        mystruct.bead_radius = simstruct.bead_radius;
        mystruct.frame_rate = simstruct.frame_rate;
        mystruct.duration = simstruct.duration;
        mystruct.tempK = simstruct.tempK;
        mystruct.field_width = simstruct.field_width;
        mystruct.field_height = simstruct.field_height;
        mystruct.calib_um   = simstruct.calib_um;
        mystruct.xdrift_vel = simstruct.xdrift_vel;
        mystruct.ydrift_vel = simstruct.ydrift_vel;        
        
        sim_video_diff_expt(filename, mystruct);
    end
end
        
outs = 0;

return;


function out = param_check(in)

    out = in;
    
    if ~isfield(out, 'seed') || isempty(out.seed)
        out.seed = sum(100000*clock);
    end
    
    if ~isfield(out, 'pass') || isempty(out.pass)
        out.pass = 1;
    end
    
    if ~isfield(out, 'well') || iempty(out.well)
        out.well = [1:96]; 
    end
    
    if ~isfield(out, 'numpaths') || isempty(out.numpaths)
        out.numpaths = 10;
    end
    
    if ~isfield(out, 'viscosity') || isempty(out.viscosity)
        out.viscosity = 0.01;     % [Pa s]
    end
    
    if ~isfield(out, 'bead_radius') || isempty(out.bead_radius)
        out.bead_radius = 0.5e-6;  % [m]
    end

    if ~isfield(out, 'frame_rate') || isempty(out.frame_rate)
        out.frame_rate = 30;       % [frames/sec]
    end

    if ~isfield(out, 'duration') || isempty(out.duration)
        out.duration = 60;        % [sec]
    end
    
    if ~isfield(out, 'tempK') || isempty(out.tempK)
        out.tempK = 300;        % [K]
    end

    if ~isfield(out, 'field_width') || isempty(out.field_width)
        out.field_width = 648;     % [pixels]
    end

    if ~isfield(out, 'field_height') || isempty(out.field_height)
        out.field_height = 484;    % [pixels]
    end

    if ~isfield(out, 'calib_um') || isempty(out.calib_um)
        out.calib_um = 0.179;      % [um/pixel]
    end

    if ~isfield(out, 'xdrift_vel') || isempty(out.xdrift_vel)
        out.xdrift_vel = 0;   % [m/frame]
    end

    if ~isfield(out, 'ydrift_vel') || isempty(out.ydrift_vel)
        out.ydrift_vel = 0;   % [m/frame]
    end

    % now that the gang is all here we need to make sure everything matches
    % in terms of vector sizes.
    fnames = fieldnames(out);
    
    % get the vector sizes    
    for k = 1:length(fnames);
        fname_sizes(k) = size(fnames{k}_;
    end
    
    % if they are not all the same size...
    if length(unique(fname_sizes)) > 1
        
    else
        % move along to the end
    end
    
    
return;