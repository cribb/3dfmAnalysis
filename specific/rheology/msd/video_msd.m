function vmsd = video_msd(files, window, frame_rate, calib_um, make_plot, winedge)
% VIDEO_MSD computes mean square displacements of an aggregate number of video tracked beads via the Stokes-Einstein relation 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%
% This function computes the mean square displacements of an aggregate number of video 
% tracked beads via the Stokes-Einstein relation and allows for the option of plotting
% MSD vs. window size (tau).
%
% [vmsd] = video_msd(files, window, frame_rate, calib_um, make_plot)
%
% where "files" is the filename containing the video tracking data (wildcards ok).
%       "window" is a scalar denoting the number of window sizes desired from 
%                the minimum and maximum available (with repeats filtered out), 
%                or is a vector containing the exact window sizes of tau when 
%                computing the MSD. 
%       "frame_rate" is the video tracking frame rate in [frames / second].
%       "calib_um" is the microns per pixel conversion unit
%       "make_plot" gives the option of producing a plot of MSD versus tau.
%
% Notes: - No arguments will run a 2D MSD on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = 50
%        - default calib_um = 0.152 microns/pixel
%        - default make_plot = yes
%


% initializing arguments
if (nargin < 1) || isempty(files)  
    files = '*.mat'; 
end;

if (nargin < 2) || isempty(window)  
    window = 50;  
end;

if (nargin < 3) || isempty(frame_rate)  
    frame_rate = []; 
end;

if (nargin < 4) || isempty(calib_um)  
    calib_um = 0.152; 
end;

if nargin < 6 || isempty(winedge)
    winedge = 1;
end

% load the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;


% determine whether or not we have to load these data from disk or not
if ~isnumeric(files)
    % load video data
    v = load_video_tracking(files, frame_rate, 'm', calib_um, 'relative', 'yes', 'table');
else
    % in this case, we assume that the incoming units are in their intended
    % form
    v = files;
    % v(:,X:Z) = v(:,X:Z) * calib_um * 1e-6;
end

% handle windows vector, if a scalar, create evenly spaced windows
if length(window) == 1
    window = unique(floor(logspace(0,round(log10(max(v(:,FRAME)))), window)));
end


% for every bead
beadID = unique(v(:,ID))';

tau = NaN(length(window), length(beadID));
mymsd = NaN(length(window), length(beadID));
counts = NaN(length(window), length(beadID));
% myr2 = NaN * zeros(length(window), length(beadID), max(v(:,FRAME)+1));

tau = NaN * ones(length(window), length(beadID));
mymsd = NaN * ones(length(window), length(beadID));

% myr2 = NaN * zeros(length(window), length(beadID), max(v(:,FRAME)+1));


for k = 1 : length(beadID);
    TIME   = 1; 
    ID     = 2; 
    FRAME  = 3; 
    X      = 4; 
    Y      = 5; 
    Z      = 6;
    
    b = get_bead(v, beadID(k));    
    
    % call up the MSD kernel-function to compute the MSD for each bead    
    [tau_ msd_ nbead r2] = msd(b(:, TIME), b(:, X:Y), window, winedge);
    
    tau(:,k) = tau_; 
    mymsd(:,k) = msd_;
    counts(:,k) = nbead;
    [ro, cl] = size(r2);
    myr2(1:ro, k, 1:cl) = r2;

end;


% trim the data by removing window sizes that returned no data
sample_count = sum(~isnan(mymsd),2);

idx = find(sample_count > 0);
tau = tau(idx,:);
mymsd = mymsd(idx,:);
counts = counts(idx,:);
sample_count = sample_count(idx);


% output structure
vmsd.tau = tau;
vmsd.msd = mymsd;
vmsd.r2 = myr2;
vmsd.n = sample_count;
vmsd.ns = counts;

% creation of the plot MSD vs. tau
if (nargin < 5) || isempty(make_plot) || strncmp(make_plot,'y',1)  
    plot_msd(vmsd, [], 'me'); 
end;

return;


