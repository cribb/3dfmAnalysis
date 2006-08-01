function v = laser_msd_crossover(filemask, window)
% 3DFM function  
% Rheology 
% Created July 31, 2006 (kvdesai)
%  
% This function computes the mean-square displacements (via the 
% Stokes-Einstein relation) for an aggregate number of beads tracked by laser.
% It computes msd for the bead position relative to specimen, bead
% position relative to laser and stage position. All three msd curves are
% plotted on the same graph to visualize the cross-over and determine the
% feedback bandwidth.
%  
%  d = laser_msd_crossover;
%  d = laser_msd_crossover(files, window);  
%   
%  where "files" is the filename containing laser tracking data (wildcards ok) 
%        "window" is a vector containing window sizes of tau when computing MSD. 
%		 3 Dimension is assumed.

%     
% Notes: - No arguments will run a 3D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default files = '*.mat'
%        - default window = [1 2 3 5 7] points in 6 decades from 10^0 to 10^5.
%        - For now only 3D msd is supported for cross over

if (nargin < 2) | isempty(window)   
    window = reshape([1 2 3 5 7]'*[1E0, 1E1, 1E2, 1E3, 1E4, 1E5],1,[]); end
if (nargin < 1) | isempty(filemask)    filemask = '*.mat'; end
dbstop if error
files = dir(filemask);

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
    
	d = load_laser_tracking(files(fid).name, 'be', flags);      
    clear b p s;
    b = d.data.beadpos; %Bead position in specimen coordinate frame
    p = d.data.posError;%Bead position within laser
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
    s(:,TIME) = b(:,TIME); s(:,[X,Y,Z]) = p(:,[X,Y,Z]) - b(:,[X,Y,Z]);% Stage position
    
    [msdb(fid,:), taub(fid,:)] = msdbase([b(:,TIME),b(:,[X,Y,Z])],Tau);
    [msdp(fid,:), taup(fid,:)] = msdbase([p(:,TIME),p(:,[X,Y,Z])],Tau);
    [msds(fid,:), taus(fid,:)] = msdbase([s(:,TIME),s(:,[X,Y,Z])],Tau);

end
% First figure out how many nonNaN elements are there for each Tau (column)
n = sum(~isnan(msdb)); %This would be same for bead, error, and stage.
mmsdb = nanmean(msdb); mmsdp = nanmean(msdp); mmsds = nanmean(msds);
ste_db = nanstd(msdb)./sqrt(n);
ste_dp = nanstd(msdp)./sqrt(n);
ste_ds = nanstd(msds)./sqrt(n);
mtaub = nanmean(taub);mtaup = nanmean(taup);mtaus = nanmean(taus);

% outputs

v.taub = taub; v.taup = taup; v.taus = taus;
v.msdb = msdb; v.msdp = msdp; v.msds = msds;
v.mtaub = mtaub; v.mtaup = mtaup; v.mtaus = mtaus;
v.mmsdb = mmsdb; v.mmsdp = mmsdp; v.mmsds = mmsds;
v.ste_db = ste_db; v.ste_dp = ste_dp; v.ste_ds = ste_ds;
v.n = n; 

% Now plot results
figure
logerrorbar(v.mtaus, v.mmsds, v.ste_ds,'.-g'); hold on;
logerrorbar(v.mtaup, v.mmsdp, v.ste_dp,'.-r'); hold on;
logerrorbar(v.mtaub, v.mmsdb, v.ste_db,'.-b'); hold off;
axis tight;
set(gca,'xtick',reshape([1]'*[1E-4, 1E-3, 1E-2, 1E-1, 1E0 1E1],1,[]));
set(gca,'ytick',reshape([1]'*[1E-6, 1E-5, 1E-4, 1E-3, 1E-2, 1E-1, 1E0 1E1],1,[]));
h = findobj(gca,'Marker','.');
legend(h,'Bead wrt specimen(P_S)','Bead wrt laser (P_L)','Stage (S_L)' );
xlabel('Window Length ({\tau})     [Seconds]');
ylabel('MSD      [Micron^2]');
pretty_plot;
return






