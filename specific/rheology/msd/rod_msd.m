function d = rod_msd(files, window, dim)
% 3DFM function  
% Rheology 
% last modified 06/29/05 (jcribb)
%  
% This function computes the mean-square displacements (via 
% the Stokes-Einstein relation) for an aggregate number of beads.
%  
%  [d] = msd;
%  [d] = msd(files, window, dim);  
%   
%  where "files" is the filename containing video tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%		 "dim" is the dimension of the input data (2D).
%  
% Notes: - No arguments will run a 2D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - default dim = 2
%

if (nargin < 3) | isempty(dim)    dim = 2;   end
if (nargin < 2) | isempty(window) window = [1 2 5 10 20 50 100 200 500 1000 1001];  end
if (nargin < 1) | isempty(files)  files = '*.mat'; end

% load in the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;

% load video data
v = load_video_tracking(files, [], 'm', 0.152, 'relative', 'yes', 'table');

% for every bead
for beadID = 0 : get_beadmax(v);
    
    b = get_bead(v, beadID);    
    framemax = max(b(:,FRAME));

    % for every window size (or tau)
    for w = 1:length(window)
        
        %  for all frames
        A1 = b(1:end-window(w),X);
        A2 = b(1:end-window(w),Y);
        A3 = b(1:end-window(w),Z);
        AYAW = b(1:end-window(w),YAW) * pi/180;
        
        B1 = b(window(w)+1:end,X);
        B2 = b(window(w)+1:end,Y);
        B3 = b(window(w)+1:end,Z);
        BYAW = b(window(w)+1:end,YAW) * pi/180;
        
        S  = sqrt( ( B1 - A1 ).^2 + ( B2 - A2 ).^2 ) ;
         
        alpha = atan2( (B2-A2) , (B1 - A1) );
        theta = AYAW;
        phi = 90 - theta - alpha;
                
        msd_parallel = (S .* sin(phi)).^2; % ./ (2*window(w));
        msd_normal = (S .* cos(phi)).^2; % ./ (2*window(w));
        msd_radial = (BYAW - AYAW).^2; % / (4 * window(w));         
 
        msd_p(w, beadID+1) = mean(msd_parallel);
        msd_n(w, beadID+1) = mean(msd_normal);
        msd_r(w, beadID+1) = mean(msd_radial);
        
        tau(w, beadID+1) = window(w) * mean(diff(b(:,TIME)));
    end   
end

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd_p = log10(msd_p);
logmsd_n = log10(msd_n);
logmsd_r = log10(msd_r);

mean_logtau = mean(logtau,2);
mean_logmsd_p = mean(logmsd_p,2);
mean_logmsd_n = mean(logmsd_n,2);
mean_logmsd_r = mean(logmsd_r,2);

ste_logtau = std(logtau,0,2) ./ sqrt(cols(tau));
ste_logmsd_p = std(logmsd_p,0,2) ./ sqrt(cols(msd_p));
ste_logmsd_n = std(logmsd_n,0,2) ./ sqrt(cols(msd_n));
ste_logmsd_r = std(logmsd_r,0,2) ./ sqrt(cols(msd_r));

	figure;
	errorbar(repmat(mean_logtau,1,3), [mean_logmsd_p mean_logmsd_n mean_logmsd_r], ...
                          [ste_logmsd_p ste_logmsd_n ste_logmsd_r]);
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;

%     figure;
%     plot(
    
% outputs
d.tau = tau;
d.msd_p = msd_p;
d.msd_n = msd_n;
d.msd_r = msd_r;
d.n = get_beadmax(v)+1; % because beadID's are indexed by 0.


