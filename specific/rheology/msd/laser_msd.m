function v = laser_msd(filemask, window, dim)
% LASER_MSD computes mean-square displacements (via Stokes-Einstein relation) for an aggregate number of beads tracked by laser
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
% This function computes the mean-square displacements (via the 
% Stokes-Einstein relation) for an aggregate number of beads tracked by laser.
%  
%  d = laser_msd;
%  d = laser_msd(files, window, dim);  
%   
%  where "files" is the filename containing laser tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%		 "dim" is the dimension of the input data (1, 2, or 3). 
%  "d" is the output containing following structures
%       .msd 
%       .tau
%       .error_msd
%       .n
%    .msd, .tau, .error_msd, and .n each have following fields depending upon
%       the dimensions selected:
%       If dim = 1 then fields: .x, .y, .z
%       If dim = 2 then fields: .xy, .yz, .zx
%       If dim = 3 then fields: .r
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
dbstop if error
files = dir(filemask);
ALLOW = 0.1; % Percentage variation allowed in the sample intervals

% set flags for loading laser data
flags.inmicrons = 1;  % set output units to microns
flags.keepuct = 0;    % set time to seconds since experiment started 
flags.keepoffset = 0; 
flags.matoutput = 1;  % sets bead position data to output as txyz matrix
flags.filterstage = 1; % Filter HF noise from MCL stage sensed positions 
% mapping columns of bead position data to constants for readibility
TIME = 1;
X = 2;
Y = 3;
Z = 4;

filemax = length(files);
Tau = window*1E-4;
% for every bead (i.e. every file)
for fid = 1 : filemax
    
	d = load_laser_tracking(files(fid).name, 'b', flags);    

    b = d.data.beadpos;    

    % First subtract out the drift
    if isfield(d,'drift')
        drift_vector = d.drift.beadpos;
        drift_est_x = polyval(drift_vector(:,X-1), b(:,1));
        drift_est_y = polyval(drift_vector(:,Y-1), b(:,1));
        drift_est_z = polyval(drift_vector(:,Z-1), b(:,1));

        b(:,X) = b(:,X) - drift_est_x;
        b(:,Y) = b(:,Y) - drift_est_y;
        b(:,Z) = b(:,Z) - drift_est_z;
    end
% NOTE: putting semantics (here, dimension info) into the data by using
% diffrent field names for 1D, 2D and 3D is horrible because it creates
% code dependencies within and across files. But, I don't see a better way
% to encode the semantics yet. 
    switch dim
% %         [msd,Tau] = msdbase(tpos, tau)
        case 1            
            [msd.x(fid,:) tau.x(fid,:)] = msdbase([b(:,1),b(:,X)],Tau);
            [msd.y(fid,:) tau.y(fid,:)] = msdbase([b(:,1),b(:,Y)],Tau);
            [msd.z(fid,:) tau.z(fid,:)] = msdbase([b(:,1),b(:,Z)],Tau);              
        case 2
            [msd.xy(fid,:) tau.xy(fid,:)] = msdbase([b(:,1),b(:,[X,Y])],Tau);
            [msd.yz(fid,:) tau.yz(fid,:)] = msdbase([b(:,1),b(:,[Y,Z])],Tau);
            [msd.zx(fid,:) tau.zx(fid,:)] = msdbase([b(:,1),b(:,[Z,X])],Tau);                        
        case 3
            [msd.r(fid,:) tau.r(fid,:)] = msdbase([b(:,1),b(:,[X,Y,Z])],Tau);            
    end
end

% Processed all files, now plot
switch dim
        case 1            
            n = sum(~isnan(msd.x));
            mmsd.x = nanmean(msd.x,1); ste_sd.x = nanstd(msd.x,1)./sqrt(n);
            mmsd.y = nanmean(msd.y,1); ste_sd.y = nanstd(msd.y,1)./sqrt(n);
            mmsd.z = nanmean(msd.z,1); ste_sd.z = nanstd(msd.z,1)./sqrt(n);
            
            mtau.x = nanmean(tau.x,1); ste_tau.x = nanstd(tau.x,1)./sqrt(n);
            mtau.y = nanmean(tau.y,1); ste_tau.y = nanstd(tau.y,1)./sqrt(n);
            mtau.z = nanmean(tau.z,1); ste_tau.z = nanstd(tau.z,1)./sqrt(n);
            
            logerrorbar(mmsd.x, mtau.x, ste_sd.x,'.-b'); hold on;
            logerrorbar(mmsd.y, mtau.y, ste_sd.y,'.-g'); hold on;
            logerrorbar(mmsd.z, mtau.z, ste_sd.z,'.-r'); hold off;            

            h = findobj(gca,'Marker','.');
            legend(h,'X','Y','Z' );
            xlabel('Window Length ({\tau})     [Seconds]');
            ylabel('MSD      [Micron^2]');
            pretty_plot;
        case 2            
            n = sum(~isnan(msd.xy));
            mmsd.xy = nanmean(msd.xy,1); ste_sd.xy = nanstd(msd.xy,1)./sqrt(n);
            mmsd.yz = nanmean(msd.yz,1); ste_sd.yz = nanstd(msd.yz,1)./sqrt(n);
            mmsd.zx = nanmean(msd.zx,1); ste_sd.zx = nanstd(msd.zx,1)./sqrt(n);
            
            mtau.xy = nanmean(tau.xy,1); ste_tau.xy = nanstd(tau.xy,1)./sqrt(n);
            mtau.yz = nanmean(tau.yz,1); ste_tau.yz = nanstd(tau.yz,1)./sqrt(n);
            mtau.zx = nanmean(tau.zx,1); ste_tau.zx = nanstd(tau.zx,1)./sqrt(n);
            
            logerrorbar(mmsd.xy, mtau.xy, ste_sd.xy,'.-b'); hold on;
            logerrorbar(mmsd.yz, mtau.yz, ste_sd.yz,'.-g'); hold on;
            logerrorbar(mmsd.zx, mtau.zx, ste_sd.zx,'.-r'); hold off;            

            h = findobj(gca,'Marker','.');
            legend(h,'XY','YZ','ZX' );
            xlabel('Window Length ({\tau})     [Seconds]');
            ylabel('MSD      [Micron^2]');
            pretty_plot;
            
        case 3
            n = sum(~isnan(msd.r));
            mmsd.r = nanmean(msd.r,1); ste_sd.r = nanstd(msd.r,1)./sqrt(n);            
            mtau.r = nanmean(tau.r,1); ste_tau.r = nanstd(tau.r,1)./sqrt(n);
            
            logerrorbar(mmsd.r, mtau.r, ste_sd.r,'.-b');
            
            h = findobj(gca,'Marker','.');
            legend(h,'Radial');
            xlabel('Window Length ({\tau})     [Seconds]');
            ylabel('MSD      [Micron^2]');
            pretty_plot;                
end

% outputs
v.tau = tau;
v.msd = msd;
v.ste_sd = ste_sd;
v.ste_tau = ste_tau;
v.n = n; 
return

%--------------------------------------------------------------------------
% Manually setting up values and errorbars for loglog plot. You cannot plot
% errorbars on a loglog plot, it seems, so we have to set it up here.
function [lmmsd lmtau ste_lmsd ste_ltau n] = setup_loglog(inmsd, intau)
nT = size(inmsd,2); % Number of taus
nF = size(inmsd,1); % Number of files
% Rows = files, columns = Taus
% First compute mean, then compute log of mean
mean_tau = nanmean(intau,1)'; % Mean across rows = mean across files
mean_msd = nanmean(inmsd,1)'; % nT x 1
lmtau = log10(mean_tau); %nT x 1
lmmsd = log10(mean_msd); %nT x 1

% Now compute standard error for the error bars on loglog plot
ltau = log10(intau); %nF x nT
lmsd = log10(inmsd); %nF x nT

% Now find out how many files are good at each Tau
for c = 1:nT
    n(c) = sum(~isnan(inmsd(:,c)) & ~isempty(inmsd(:,c)));
    ste_ltau(c) = nanstd(ltau(:,c))' ./ sqrt(n(c)); % nT x 1
    ste_lmsd(c) = nanstd(lmsd(:,c))' ./ sqrt(n(c)); % nT x 1
end





