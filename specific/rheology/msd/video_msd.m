function vmsd = video_msd(files, window, frame_rate, calib_um, make_plot, xtra_output)
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
%       "xtra_output" is 'r2' to output r-squared values, or 'r' to output
%                     sign-preserved displacements.
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
if nargin < 6 || isempty(xtra_output) || contains(xtra_output, 'n')
    calc_r2 = 0;
    calc_r = 0;
elseif contains(xtra_output, 'r2')
    calc_r2 = 1;
    calc_r = 0;
elseif contains(xtra_output, 'r')
    calc_r = 1;
    calc_r2 = 0;
else
    error('xtra_output not defined correctly');
end

if (nargin < 1) || isempty(files)  
    logentry('No files defined. Exiting now.')
    
    if length(window) > 1
        empty_set = NaN(size(window));
    elseif length(window) == 1
        empty_set = NaN(window,1);
    end
    
    vmsd.trackerID = empty_set;
    vmsd.tau = empty_set;
    vmsd.msd = empty_set;
    if calc_r2
        vmsd.r2 = [];
    end
    if calc_r
        vmsd.r = [];
    end
%     vmsd.n = empty_set;
    vmsd.Nestimates = empty_set;
    vmsd.window = empty_set;
    return;
end

if (nargin < 2) || isempty(window)  
    window = 50;  
end

if (nargin < 3) || isempty(frame_rate)  
    frame_rate = []; 
end

if (nargin < 4) || isempty(calib_um)  
    calib_um = 0.152; 
end



% load the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;


% determine whether or not we have to load these data from disk or not
if ~isnumeric(files)
    % load video data
    v = load_video_tracking(files, frame_rate, 'm', calib_um, 'relative', 'yes', 'matrix');
else
    % in this case, we assume that the incoming units are in their intended
    % form
    v = files;
    
%     if calib_um ~= 1 % assume inputs are 
%         v(:,X:Z) = v(:,X:Z) * calib_um * 1e-6;
%     end
    
end

% We want to identify a set of strides to step across for a given set of 
% images (frames).  We would like them to be spread evenly across the 
% available frames (times) in the log scale sense.  To do this we generate
% a logspace range, eliminate any repeated values and round them 
% appropriately, getting a list of strides that may not be as long as we
% asked but pretty close. 
if length(window) == 1
   percent_duration = 1;
   window = msd_gen_taus(max(v(:,FRAME)), window, percent_duration);
end


% for every bead
beadIDs = unique(v(:,ID))';

tau    = NaN(length(window), length(beadIDs));
mymsd  = NaN(length(window), length(beadIDs));
Nestimates = NaN(length(window), length(beadIDs));

        if calc_r2
            myr2   = NaN(max(v(:,FRAME)+1), length(window), length(beadIDs));
        elseif calc_r
            % the 2 here refers to the number of coordinates,being just X and Y
            myr    = NaN(max(v(:,FRAME)+1), 2, length(window), length(beadIDs));   
        end
                
for k = 1 : length(beadIDs)
    
    b = get_bead(v, beadIDs(k));    
    
%     first_positions_X(1,k) = b(1,X) / (calib_um * 1e-6);
%     first_positions_Y(1,k) = b(1,Y) / (calib_um * 1e-6);
    
    % call up the MSD kernel-function to compute the MSD for each bead    
    if calc_r2 || calc_r
        [tau_, msd_, nest_, r]  = msd(b(:, TIME), b(:, X:Y), window(~isnan(window)));
    else
        [tau_, msd_, nest_]    = msd(b(:, TIME), b(:, X:Y), window(~isnan(window)));
    end
    
    tau(1:length(tau_),k) = tau_; 
    mymsd(1:length(msd_),k) = msd_;
    Nestimates(1:length(nest_),k) = nest_;
    
    if calc_r
        [ntimes, ncoords, nwindows] = size(r);
        myr(1:ntimes, 1:ncoords, 1:nwindows, k) = r;
        q = myr(1:ntimes, 1:ncoords, 1:nwindows, k);
    end    
    
    if calc_r2
        myr2 = r.^2;
        myr2 = squeeze(sum(myr2,2));
    end
end


% trim the data by removing window sizes that returned no data
% sample_count = sum(~isnan(mymsd),2);

% idx = find(sample_count > 0);
% tau = tau(idx,:);
% mymsd = mymsd(idx,:);
% Nestimates = Nestimates(idx,:);
% sample_count = sample_count(idx);


% output structure
vmsd.trackerID = reshape(beadIDs, 1, length(beadIDs));
% vmsd.firstposX = first_positions_X;
% vmsd.firstposY = first_positions_Y;
vmsd.tau = tau;
vmsd.msd = mymsd;
if calc_r
    vmsd.r = myr;
elseif calc_r2
    vmsd.r2 = myr2;
end
% vmsd.n = sample_count;
vmsd.Nestimates = Nestimates;
vmsd.window = window;

% creation of the plot MSD vs. tau
if (nargin < 5) || isempty(make_plot) || strncmp(make_plot,'y',1)  
    plot_msd(vmsd, [], 'ame'); 
end

% fprintf('size(vmsd): %i,  %i\n',size(vmsd.msd));
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
     headertext = [logtimetext 'video_msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    