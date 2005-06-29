function d = msd(files, window, dim)
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
%		 "dim" is the dimension of the input data (1D, 2D, or 3D).
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
if (nargin < 1) | isempty(files)  files = '*.evt.mat'; end

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
        
        % for every frame
        for fnum = 1 : (framemax - window(w) - 1)
            switch dim
                case 1
                    r2(fnum) = ( b(fnum+window(w), X) - b(fnum, X))^2;
                case 2
                    r2(fnum) = ( b(fnum+window(w), X) - b(fnum, X))^2 + ...
                               ( b(fnum+window(w), Y) - b(fnum, Y))^2 ;
                case 3
                    r2(fnum) = ( b(fnum+window(w), X) - b(fnum, X))^2 + ...
                               ( b(fnum+window(w), Y) - b(fnum, Y))^2 + ...
                               ( b(fnum+window(w), Z) - b(fnum, Z))^2 ;                               
                otherwise
                    error('dimension must be 1D, 2D, or 3D.');
            end
        end
        
        msd(w, beadID+1) = mean(r2);
        tau(w, beadID+1) = window(w) * mean(diff(b(:,TIME)));
    end   
end

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
logtau = log10(tau);
logmsd = log10(msd);
mean_logtau = mean(logtau,2);
mean_logmsd = mean(logmsd,2);
ste_logtau = std(logtau,0,2) ./ sqrt(cols(tau));
ste_logmsd = std(logmsd,0,2) ./ sqrt(cols(msd));

	figure;
	errorbar(mean_logtau, mean_logmsd, ste_logmsd);
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;

% outputs
d.tau = tau;
d.msd = msd;
d.n = get_beadmax(v)+1; % because beadID's are indexed by 0.


