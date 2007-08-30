function vmsd = video_msd_bc(files, window, frame_rate, calib_um, make_plot)
% 3DFM function
% Rheology
% last modified 07/06/07 (blcarste)
%
% This function computes the mean square displacements of an aggregate number of video 
% tracked beads via the Stokes-Einstein relation and allows for the option of plotting
% MSD vs. window size (tau).
%
% [vmsd] = video_msd(files, window, frame_rate, calib_um, make_plot)
%
% where "files" is the filename containing the video tracking data (wildcards ok).
%       "window" is a vector containing window sizes of tau when computing MSD. 
%       "frame_rate" is the video tracking frame rate in [frames / second].
%       "calib_um" is the microns per pixel conversion unit
%       "make_plot" gives the option of producing a plot of MSD versus tau.
%
% Notes: - No arguments will run a 2D MSD on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - default calib_um = 0.152 microns/pixel
%        - default make_plot = yes
%


% initializing arguments
if (nargin < 1) | isempty(files)  files = '*.mat'; end;
if (nargin < 2) | isempty(window)  window = [1 2 5 10 20 50 100 200 500 1000 1001];  end;
if (nargin < 3) | isempty(frame_rate)  frame_rate = []; end;
if (nargin < 4) | isempty(calib_um)  calib_um = 0.152; end;


% load the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;


% load video data
v = load_video_tracking(files, frame_rate, 'm', calib_um, 'relative', 'yes', 'table');


% for every bead
for beadID = 0 : get_beadmax(v);
    
    b = get_bead(v, beadID);    
    framemax = max(b(:,FRAME));
    
    % call up the MSD program to compute the MSD for each bead
    [tau(:, beadID+1), mymsd(:, beadID+1)] = msd(b(:, TIME), b(:, X:Z), window);

end;


% trim the data by removing window sizes that returned no data
sample_count = sum(~isnan(mymsd),2);
idx = find(sample_count > 0);
tau = tau(idx,:);
mymsd = mymsd(idx,:);
sample_count = sample_count(idx);


% output structure
vmsd.tau = tau;
vmsd.msd = mymsd;
vmsd.n = sample_count;

% creation of the plot MSD vs. tau
if (nargin < 5) | isempty(make_plot) | findstr(make_plot,'y')  plot_msd(vmsd); end;


