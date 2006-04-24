function v = laser_msd(filemask, window, dim)
% 3DFM function  
% Rheology 
% last modified 04/13/06 (kvdesai)
%  
% This function computes the mean-square displacements (via 
% the Stokes-Einstein relation) for an aggregate number of beads tracked by laser.
%  
%  [d] = laser_msd;
%  [d] = laser_msd(files, window, dim);  
%   
%  where "files" is the filename containing video tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%		 "dim" is the dimension of the input data (1D, 2D, or 3D).
%  
% Notes: - No arguments will run a 3D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - default dim = 3
%

if (nargin < 3) | isempty(dim)      dim = 3;   end
if (nargin < 2) | isempty(window)   window = [1 2 5 10 20 50 100 200 500 1000 1001];  end
if (nargin < 1) | isempty(filemask)    filemask = '*.mat'; end

files = dir(filemask);

% load laser data flags
flags.inmicrons = 0;  % set output to meters
flags.keepuct = 0;    % set time to seconds since experiment started 
flags.keepoffset = 0; 
flags.matoutput = 1;  % sets bead position data to output as txyz

% mapping columns of bead position data to constants for readibility
TIME = 1;
X = 2;
Y = 3;
Z = 4;

filemax = length(files);

% for every bead (i.e. every file)
for fid = 1 : filemax
    
	d = load_laser_tracking(files(fid).name, 'b', flags);    

    b = d.data.beadpos;

    if isfield(d,'drift')
        drift_vector = d.drift.beadpos;
        drift_est_x = polyval(drift_vector(:,1), b(:,1));
        drift_est_y = polyval(drift_vector(:,2), b(:,1));
        drift_est_z = polyval(drift_vector(:,3), b(:,1));

        b(:,X) = b(:,X) - drift_est_x;
        b(:,Y) = b(:,Y) - drift_est_y;
        b(:,Z) = b(:,Z) - drift_est_z;
    end

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
 
        msd(w, fid) = mean(r2);
        tau(w, fid) = window(w) * mean(diff(b(:,TIME)));
    end   
end

% setting up axis transforms for the figure plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.

logtau = log10(tau);
logmsd = log10(msd);

mean_tau = nanmean(tau');
mean_msd = nanmean(msd');

log_mean_tau = log10(mean_tau);
log_mean_msd = log10(mean_msd);

sample_count = sum(~isnan(logmsd),2);

ste_logtau = nanstd(logtau') ./ sqrt(sample_count');
ste_logmsd = nanstd(logmsd') ./ sqrt(sample_count');

	figure;
	errorbar(log_mean_tau, log_mean_msd, ste_logmsd, '.-');
	xlabel('log_{10}(\tau) [s]');
	ylabel('log_{10}(MSD) [m^2]');
	grid on;
	pretty_plot;

% dlmwrite('file.msd.txt', [log_mean_tau(:), log_mean_msd(:), ste_logtau(:), ste_logmsd(:)], '\t');
    
    
% outputs
v.tau = tau;
v.msd = msd;
v.error_msd = ste_logmsd(:);
v.n = sample_count; % because beadID's are indexed by 0.


