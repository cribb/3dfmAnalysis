function d = msd(files, window, dim, frame_rate, calib_um)
% 3DFM function  
% Rheology 
% last modified 01/25/07 (jcribb)
%  
% This function computes the mean-square displacements (via 
% the Stokes-Einstein relation) for an aggregate number of beads.
%  
%  [d] = msd;
%  [d] = msd(files, window, dim, frame_rate, calib_um);  
%   
%  where "calib_um" is the microns per pixel conversion unit
%        "frame_rate" is the video tracking frame rate in [frames / second].
%        "files" is the filename containing video tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%		 "dim" is the dimension of the input data (1D, 2D, or 3D).
%  
% Notes: - No arguments will run a 2D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - default dim = 2
%

if (nargin < 5) | isempty(calib_um) calib_um = 0.152; end;
if (nargin < 4) | isempty(frame_rate) frame_rate = []; end;
if (nargin < 3) | isempty(dim)      dim = 2;   end
if (nargin < 2) | isempty(window)   window = [1 2 5 10 20 50 100 200 500 1000 1001];  end
if (nargin < 1) | isempty(files)    files = '*.mat'; end

% load in the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;

% load video data
v = load_video_tracking(files, frame_rate, 'm', calib_um, 'relative', 'yes', 'table');

% for every bead
warning('off', 'MATLAB:divideByZero');
for beadID = 0 : get_beadmax(v);
    
    b = get_bead(v, beadID);    
    framemax = max(b(:,FRAME));
    
    % for every window size (or tau)
    for w = 1:length(window)
        
        %  for all frames
        A1 = b(1:end-window(w),X);
        A2 = b(1:end-window(w),Y);
        A3 = b(1:end-window(w),Z);

        B1 = b(window(w)+1:end,X);
        B2 = b(window(w)+1:end,Y);
        B3 = b(window(w)+1:end,Z);
        
        switch dim
            case 1
                r2 = ( B1 - A1 ).^2;
            case 2
                r2 = ( B1 - A1 ).^2 + ...
                     ( B2 - A2 ).^2 ;
            case 3
                r2 = ( B1 - A1 ).^2 + ...
                     ( B2 - A2 ).^2 + ...
                     ( B3 - A3 ).^2 ;
            otherwise
                error('dimension must be 1D, 2D, or 3D.');
        end        
 
        msd(w, beadID+1) = mean(r2);
        tau(w, beadID+1) = window(w) * mean(diff(b(:,TIME)));
    end   
end
warning('on', 'MATLAB:divideByZero');

% trim the data by removing window sizes that returned no data
sample_count = sum(~isnan(msd),2);
idx = find(sample_count > 0);
tau = tau(idx,:);
msd = msd(idx,:);
sample_count = sample_count(idx);

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);

mean_logtau = nanmean(logtau');
mean_logmsd = nanmean(logmsd');

ste_logtau = nanstd(logtau') ./ sqrt(sample_count');
ste_logmsd = nanstd(logmsd') ./ sqrt(sample_count');

    figure;
	errorbar(mean_logtau, mean_logmsd, ste_logmsd);
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;


% dlmwrite('file.msd.txt', [mean_logtau(:), mean_logmsd(:), ste_logtau(:), ste_logmsd(:)], '\t');
    
% outputs
% d.raw.tau = tau;
% d.raw.msd = msd;
% 
% d.mean.tau = 
d.tau = tau;
d.msd = msd;
d.error_msd = ste_logmsd(:);
d.n = sample_count; % because beadID's are indexed by 0.


