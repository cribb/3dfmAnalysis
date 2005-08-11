function v = laser_forcecal(tracking_log_file, magnet_log_file, dominant_pole, bead_radius, viscosity)
% 3DFM function  
% Magnetics
% last modified 08/10/05 
%  
% Laser force calibration routine for the 3dfm.
%  
%  [v] = laser_forcecal(tracking_log_file, magnet_log_file, dominant_pole, bead_radius, viscosity) 
%   
%  where "tracking_log_file" is the 3dfm tracking log filename
%        "magnet_log_file" is the 3dfm magnet log filename
%		 "dominant_pole" is the identity of the dominant pole in the 3dfm
%        "bead_radius" is the radius of hte tracked bead in [m]
%        "viscosity" is the viscosity of the calibrator fluid in [Pa s]
%  

% handle argument list
if (nargin < 5) | isempty(viscosity);      viscosity = 1.6;       end;
if (nargin < 4) | isempty(bead_radius);    bead_radius = 0.5e-6;  end;
if (nargin < 3) | isempty(dominant_pole);  dominant_pole = 4;     end;

% first, load the datastreams
d = load_vrpn_tracking(tracking_log_file, 'm');
m = load(magnet_log_file);
m = m.magnets;

% easier time variables
beadtime = d.beadpos.time;
magtime = m.time;

% merge the two-column timestamps for magnet timestamps
% into one column... matlab gives us enough precision to keep us happy.
magtime = magtime(:,1) + magtime(:,2) * 1e-6;

% determine the minimum time recorded by either of these 
% files and use that as t-zero
mintime = min([beadtime ; magtime]);
maxtime = max([beadtime ; magtime]);

% get vector positions and compute radial vector position
x = d.beadpos.x;
y = d.beadpos.y; 
z = d.beadpos.z;
r = magnitude(x, y, z);

%     % code for separate subplots 
%     figure;
%     subplot(2, 1, 2);
%     stairs(magtime - mintime, m.analogs(:,dominant_pole), 'k-');
%     axis([0, maxtime - mintime, min(m.analogs(:,dominant_pole))*0.90, max(m.analogs(:,dominant_pole))*1.1]);
%     subplot(2, 1, 1); hold on;
%     plot(beadtime - mintime, r * 1e6, 'b-');
%     axis([0, maxtime - mintime, min(r * 1e6)*0.90, max(r * 1e6)*1.1]);

    % code for single plot with secondary y-axis 
    figure;
    [ax, h1, h2] = plotyy(beadtime - mintime, r * 1e6, magtime - mintime, m.analogs(:,dominant_pole), 'plot', 'stairs');
    title('Force Calibration, laser tracking');   
    xlabel('time [s]');
    set(get(ax(1),'Ylabel'),'String','radial displacement [\mum]');
	set(get(ax(2),'Ylabel'),'String','dominant coil [V]');
    pretty_plot;
    
warning off MATLAB:polyfit:RepeatedPointsOrRescale;

count = 1;
drift = [0 0 0];

% Start processing the magnet log entries and create force table.
for k = 1 : ( length(magtime) - 1 );

    % for how long do we need to ignore points due to disynchrony?
    buffer = 0; % seconds
    
    idx = find(beadtime >= (magtime(k) + buffer) & beadtime < (magtime(k+1) - buffer));
    
    N = length(idx);
    
    % how many laser points do we want to require for fitting?
    % just going to guess for now
    thresh = 100;
    
    if (N > thresh)
        
        dcoil_voltage = m.analogs(k, dominant_pole);
        
        % approximate velocity on each axis by using slope of linear fit.
        fitx = polyfit(beadtime(idx), x(idx), 1);
        fity = polyfit(beadtime(idx), y(idx), 1);
        fitz = polyfit(beadtime(idx), z(idx), 1);
        fitr = polyfit(beadtime(idx), r(idx), 1);
        
        vel = [ fitx(1) fity(1) fitz(1) ];
        unc = [ uncertainty_in_slope(beadtime(idx), x(idx), fitx), ... 
                uncertainty_in_slope(beadtime(idx), y(idx), fity), ...
                uncertainty_in_slope(beadtime(idx), z(idx), fitz) ] ;
        
        if dcoil_voltage == 0
%             drift = vel;
        else    
%             vel = vel - drift;
        end
                    
        bead_velocity = fitr(1);
        
        force = 6 * pi * bead_radius * viscosity * vel;
        uncertainty_in_force = 6 * pi * bead_radius * viscosity * unc;
        
        force_table(count, 1) = min(beadtime(idx)) - mintime;
        force_table(count, 2) = max(beadtime(idx)) - mintime;
        force_table(count, 3) = N;
        force_table(count, 4) = dcoil_voltage;   % reporting voltage
        force_table(count, 5) = magnitude(force);
        force_table(count, 6) = magnitude(uncertainty_in_force);

        count = count + 1;

        % code for separate subplots
        % plot(beadtime(idx) - mintime, polyval(fit, beadtime(idx)) * 1e6, 'r-');
        
        % code for single plot with secondary axis
        hold on; 
            plot(beadtime(idx) - mintime, polyval(fitr, beadtime(idx)) * 1e6, 'r-');
        hold off;    
    end   
        
end

    if ~exist('force_table')
        error('There is no congruence in time for the magnet and tracking files');
    end

v = force_table;

